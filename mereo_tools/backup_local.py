"""Backup local read-only dos bancos piloto (MEREO_*) — schema + dados em disco."""

from __future__ import annotations

import argparse
import base64
import gzip
import json
import shlex
import subprocess
import sys
import time
import uuid
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path
from typing import Any

from mereo_tools import db
from mereo_tools.config import load_mereo_config
from mereo_tools.db import use_database
from mereo_tools.ddl_extract import (
    DatabaseDdl,
    TableDef,
    extract_database_ddl,
    render_add_foreign_key,
    render_create_schema,
    render_create_table,
)

PILOT_DATABASES = ("MereoGR-Afya", "MereoGR-Staging", "MereoGR-Allos")
DEFAULT_OUT = Path("output/backups")

DEFAULT_SCHEMA_ONLY_PATTERNS = (
    "audit.AuditLogs",
    "dbo.AbpEntityChanges",
    "dbo.AbpEntityPropertyChanges",
    "dbo.AbpEntityChangeSets",
    "HangFire.*",
    "dbo.LOG_*",
    "dbo.SQL_TRACE",
    "dbo.TaskLog",
)


@dataclass
class BackupOptions:
    databases: list[str]
    out_dir: Path
    batch_size: int
    pause_batch: float
    pause_table: float
    pause_db: float
    resume: bool
    skip_empty: bool
    sample_limit: int | None
    sample_databases: frozenset[str]
    progress_every: int
    table_retry_attempts: int
    login_timeout: int
    accept_partial: frozenset[str]
    schema_only_patterns: tuple[str, ...]
    schema_only_databases: frozenset[str]


def _serialize(value: Any) -> Any:
    if value is None:
        return None
    if isinstance(value, (str, int, float, bool)):
        return value
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, uuid.UUID):
        return str(value)
    if isinstance(value, (bytes, bytearray)):
        return {"__binary__": base64.b64encode(value).decode("ascii")}
    return str(value)


def _serialize_row(row: dict[str, Any]) -> dict[str, Any]:
    return {k: _serialize(v) for k, v in row.items()}


def _table_data_path(out_db: Path, schema: str, table: str) -> Path:
    safe = f"{schema}__{table}".replace("/", "_")
    return out_db / "data" / f"{safe}.jsonl.gz"


def _progress_path(out_db: Path) -> Path:
    return out_db / "progress.json"


def _load_progress(path: Path) -> set[str]:
    if not path.exists():
        return set()
    data = json.loads(path.read_text())
    return set(data.get("completed_tables", []))


def _save_progress(path: Path, completed: set[str]) -> None:
    path.write_text(json.dumps({"completed_tables": sorted(completed)}, indent=2))


def _write_schema(out_db: Path, ddl: DatabaseDdl) -> None:
    schema_dir = out_db / "schema"
    schema_dir.mkdir(parents=True, exist_ok=True)

    lines: list[str] = [f"-- Backup schema: {ddl.database}", ""]
    for schema in ddl.schemas:
        lines.append(render_create_schema(schema))
        lines.append("GO")
        lines.append("")
    for table in ddl.tables:
        lines.append(render_create_table(table))
        lines.append("GO")
        lines.append("")
    for fk in ddl.foreign_keys:
        lines.append(render_add_foreign_key(fk))
        lines.append("GO")
        lines.append("")

    (schema_dir / "schema.sql").write_text("\n".join(lines), encoding="utf-8")
    (schema_dir / "ddl.json").write_text(
        json.dumps(
            {
                "database": ddl.database,
                "schemas": ddl.schemas,
                "table_count": len(ddl.tables),
                "fk_count": len(ddl.foreign_keys),
                "tables": [
                    {
                        "schema": t.schema,
                        "table": t.name,
                        "pk_columns": t.pk_columns,
                        "column_count": len(t.columns),
                    }
                    for t in ddl.tables
                ],
            },
            indent=2,
        ),
        encoding="utf-8",
    )


def _checkpoint_path(out_db: Path, schema: str, table: str) -> Path:
    safe = f"{schema}__{table}".replace("/", "_")
    return out_db / "data" / f".checkpoint__{safe}.json"


def _sql_literal(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, (int, float, Decimal)):
        return str(value)
    text = str(value).replace("'", "''")
    return f"N'{text}'"


def _keyset_where(pk_columns: list[str], last_pk: dict[str, Any]) -> str:
    if len(pk_columns) == 1:
        col = pk_columns[0].replace("]", "]]")
        return f"[{col}] > {_sql_literal(last_pk[pk_columns[0]])}"
    clauses: list[str] = []
    for i, col in enumerate(pk_columns):
        eq = " AND ".join(
            f"[{pk_columns[j].replace(']', ']]')}] = {_sql_literal(last_pk[pk_columns[j]])}"
            for j in range(i)
        )
        gt = f"[{col.replace(']', ']]')}] > {_sql_literal(last_pk[col])}"
        clauses.append(f"({eq} AND {gt})" if eq else f"({gt})")
    return "(" + " OR ".join(clauses) + ")"


def _pk_from_row(row: dict[str, Any], pk_columns: list[str]) -> dict[str, Any]:
    lower = {k.lower(): v for k, v in row.items()}
    out: dict[str, Any] = {}
    for pk in pk_columns:
        if pk in row:
            out[pk] = row[pk]
        elif pk.lower() in lower:
            out[pk] = lower[pk.lower()]
        else:
            raise KeyError(f"coluna PK {pk!r} ausente na linha exportada")
    return out


def _read_last_jsonl_gz_row(path: Path) -> dict[str, Any] | None:
    cmd = f"gzip -dc {shlex.quote(str(path))} | tail -1"
    proc = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=180)
    if proc.returncode != 0 or not proc.stdout.strip():
        return None
    return json.loads(proc.stdout)


def _load_checkpoint(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def _save_checkpoint(path: Path, *, last_pk: dict[str, Any], rows_exported: int) -> None:
    path.write_text(
        json.dumps({"last_pk": last_pk, "rows_exported": rows_exported}, indent=2),
        encoding="utf-8",
    )


def _needs_reconnect(exc: Exception) -> bool:
    msg = str(exc).lower()
    hints = (
        "not connected",
        "connection is closed",
        "connection was closed",
        "connection dead",
        "broken pipe",
        "20004",
        "20009",
        "timed out",
        "operation timed out",
        "unavailable",
        "connection reset",
    )
    return any(h in msg for h in hints)


def _fetch_batch(
    conn,
    database: str,
    table: TableDef,
    *,
    batch_size: int,
    offset: int,
    last_pk: dict[str, Any] | None,
    reconnect,
) -> list[dict[str, Any]]:
    cols = table.select_columns
    col_list = ", ".join(f"[{c.name}]" for c in cols)
    schema = table.schema.replace("]", "]]")
    name = table.name.replace("]", "]]")

    if table.pk_columns:
        order = ", ".join(f"[{c}]" for c in table.pk_columns)
        if last_pk is not None:
            where = _keyset_where(table.pk_columns, last_pk)
            sql = (
                f"SELECT TOP ({batch_size}) {col_list} FROM [{schema}].[{name}] WITH (NOLOCK) "
                f"WHERE {where} ORDER BY {order}"
            )
        else:
            sql = (
                f"SELECT TOP ({batch_size}) {col_list} FROM [{schema}].[{name}] WITH (NOLOCK) "
                f"ORDER BY {order}"
            )
    else:
        sql = (
            f"SELECT {col_list} FROM [{schema}].[{name}] WITH (NOLOCK) "
            f"ORDER BY (SELECT NULL) OFFSET {offset} ROWS FETCH NEXT {batch_size} ROWS ONLY"
        )

    last_exc: Exception | None = None
    active = conn
    max_attempts = 8
    for attempt in range(1, max_attempts + 1):
        try:
            with use_database(active, database):
                return db.fetchall(active, sql)
        except Exception as exc:
            last_exc = exc
            if _needs_reconnect(exc):
                print(f"\n    reconectando MEREO_* ({attempt}/{max_attempts})...", flush=True)
                active = reconnect()
            if attempt < max_attempts:
                time.sleep(min(30, 3 * attempt))
            else:
                raise last_exc
    raise last_exc  # type: ignore[misc]


def _inventory_row(database: str, schema: str, table: str) -> dict[str, Any] | None:
    inv = Path("output/groups/mereogr/databases") / database / "tables.jsonl"
    if not inv.exists():
        return None
    for line in inv.open(encoding="utf-8"):
        row = json.loads(line)
        if row.get("schema") == schema and row.get("table") == table:
            return row
    return None


def _row_count_hint(database: str, schema: str, table: str) -> int | None:
    row = _inventory_row(database, schema, table)
    if row is None:
        return None
    return int(row.get("row_count") or 0)


def _has_data_hint(database: str, schema: str, table: str) -> bool | None:
    count = _row_count_hint(database, schema, table)
    if count is None:
        return None
    return count > 0


def _count_jsonl_gz_lines(path: Path) -> int:
    count = 0
    with gzip.open(path, "rb") as gz:
        for _ in gz:
            count += 1
    return count


def _parse_table_list(raw: str) -> frozenset[str]:
    return frozenset(item.strip() for item in raw.split(",") if item.strip())


def _table_matches_pattern(schema: str, table: str, pattern: str) -> bool:
    if "." not in pattern:
        return False
    pat_schema, pat_table = pattern.split(".", 1)
    if pat_schema != schema and pat_schema != "*":
        return False
    if pat_table == "*":
        return True
    if pat_table.endswith("*"):
        return table.startswith(pat_table[:-1])
    return pat_table == table


def _is_schema_only_table(
    options: BackupOptions, database: str, schema: str, table: str
) -> bool:
    if not options.schema_only_patterns:
        return False
    if options.schema_only_databases and database not in options.schema_only_databases:
        return False
    return any(
        _table_matches_pattern(schema, table, pat) for pat in options.schema_only_patterns
    )


def _rows_in_backup_file(path: Path) -> int:
    if not path.exists() or path.stat().st_size <= 22:
        return 0
    return _count_jsonl_gz_lines(path)


def _mark_schema_only_table(
    out_db: Path, table: TableDef, *, schema_only_tables: list[str]
) -> None:
    dest = _table_data_path(out_db, table.schema, table.name)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(gzip.compress(b""))
    schema_only_tables.append(f"{table.schema}.{table.name}")


def _mark_accept_partial_table(
    out_db: Path,
    table: TableDef,
    *,
    partial_tables: list[dict[str, Any]],
) -> int:
    dest = _table_data_path(out_db, table.schema, table.name)
    ck = _checkpoint_path(out_db, table.schema, table.name)
    rows = 0
    if ck.exists():
        rows = int(_load_checkpoint(ck).get("rows_exported") or 0)
    elif dest.exists():
        rows = _rows_in_backup_file(dest)
    partial_tables.append(
        {
            "table": f"{table.schema}.{table.name}",
            "rows_exported": rows,
            "note": "accept-partial",
        }
    )
    return rows


def _row_cap(options: BackupOptions, database: str) -> int | None:
    if options.sample_limit is None or database not in options.sample_databases:
        return None
    return options.sample_limit


def _print_progress(
    *,
    table_idx: int,
    table_total: int,
    full_name: str,
    exported: int,
    target: int | None,
    tables_left: int,
    sampled: bool,
) -> None:
    if target and target > 0:
        pct = min(100.0, 100.0 * exported / target)
        detail = f"{exported:,}/{target:,} ({pct:.1f}%)"
    else:
        detail = f"{exported:,} linhas"
    mode = " [sample TOP]" if sampled else ""
    print(
        f"\r  [{table_idx}/{table_total}] {full_name}{mode}: {detail} | "
        f"faltam {tables_left} tbl neste banco    ",
        end="",
        flush=True,
    )


def _export_table(
    conn,
    database: str,
    table: TableDef,
    out_db: Path,
    *,
    options: BackupOptions,
    reconnect,
    table_idx: int = 0,
    table_total: int = 0,
    tables_left: int = 0,
) -> int:
    dest = _table_data_path(out_db, table.schema, table.name)
    dest.parent.mkdir(parents=True, exist_ok=True)
    full_name = f"{table.schema}.{table.name}"

    if options.skip_empty:
        hint = _has_data_hint(database, table.schema, table.name)
        if hint is False:
            dest.write_bytes(gzip.compress(b""))
            return 0

    cap = _row_cap(options, database)
    inventory_rows = _row_count_hint(database, table.schema, table.name)
    sampled = cap is not None
    if cap is not None and inventory_rows is not None and inventory_rows <= cap:
        cap = None
        sampled = False

    target: int | None
    if cap is not None:
        target = cap
    elif inventory_rows is not None and inventory_rows > 0:
        target = inventory_rows
    else:
        target = None

    total = 0
    offset = 0
    last_pk: dict[str, Any] | None = None
    use_keyset = bool(table.pk_columns)
    checkpoint = _checkpoint_path(out_db, table.schema, table.name)
    append_mode = False

    if options.resume and dest.exists() and dest.stat().st_size > 0:
        ck = _load_checkpoint(checkpoint)
        if ck:
            total = int(ck.get("rows_exported") or 0)
            last_pk = ck.get("last_pk")
            append_mode = total > 0
        else:
            last_row = _read_last_jsonl_gz_row(dest)
            if last_row and use_keyset:
                last_pk = _pk_from_row(last_row, table.pk_columns)
                total = _count_jsonl_gz_lines(dest)
                append_mode = total > 0
            else:
                offset = _count_jsonl_gz_lines(dest)
                append_mode = offset > 0
                total = offset
        if append_mode:
            if cap is not None and total >= cap:
                return total
            if use_keyset and last_pk:
                print(
                    f"\n  [{table_idx}/{table_total}] {full_name}: "
                    f"keyset retomando de {total:,} linhas (PK > {last_pk})...",
                    flush=True,
                )
            elif total > 0:
                print(
                    f"\n  [{table_idx}/{table_total}] {full_name}: retomando de {total:,} linhas...",
                    flush=True,
                )
    elif dest.exists():
        dest.unlink()
        checkpoint.unlink(missing_ok=True)

    mode = "ab" if append_mode else "wb"
    batch_num = 0
    show_progress = (target or 0) > 10_000 or cap is not None

    with gzip.open(dest, mode) as gz:
        while True:
            if cap is not None and total >= cap:
                break
            batch_size = options.batch_size
            if cap is not None:
                batch_size = min(batch_size, cap - total)

            rows = _fetch_batch(
                conn,
                database,
                table,
                batch_size=batch_size,
                offset=offset,
                last_pk=last_pk if use_keyset else None,
                reconnect=reconnect,
            )
            if not rows:
                break
            for row in rows:
                line = json.dumps(_serialize_row(row), ensure_ascii=False) + "\n"
                gz.write(line.encode("utf-8"))
            total += len(rows)
            if use_keyset:
                last_pk = _pk_from_row(rows[-1], table.pk_columns)
            else:
                offset += len(rows)
            batch_num += 1

            if use_keyset and last_pk is not None:
                _save_checkpoint(checkpoint, last_pk=last_pk, rows_exported=total)

            if show_progress and (
                batch_num == 1 or batch_num % options.progress_every == 0 or len(rows) < batch_size
            ):
                _print_progress(
                    table_idx=table_idx,
                    table_total=table_total,
                    full_name=full_name,
                    exported=total,
                    target=target,
                    tables_left=tables_left,
                    sampled=sampled,
                )

            if cap is not None and total >= cap:
                break
            if options.pause_batch > 0:
                time.sleep(options.pause_batch)

    if show_progress:
        print(flush=True)

    if total == 0 and not dest.exists():
        dest.write_bytes(gzip.compress(b""))
    checkpoint.unlink(missing_ok=True)
    return total


def _pending_tables(ddl: DatabaseDdl, completed: set[str]) -> list[TableDef]:
    pending: list[TableDef] = []
    for table in ddl.tables:
        full = f"{table.schema}.{table.name}"
        if full not in completed:
            pending.append(table)
    return pending


def _print_backup_plan(options: BackupOptions, conn) -> None:
    print("=== Plano de backup ===")
    for database in options.databases:
        try:
            ddl = extract_database_ddl(conn, database)
        except Exception as exc:
            print(f"  {database}: erro ao ler DDL ({exc})")
            continue
        out_db = options.out_dir / database
        completed = _load_progress(_progress_path(out_db)) if options.resume else set()
        pending = _pending_tables(ddl, completed)
        cap = _row_cap(options, database)
        cap_label = f", TOP {cap:,} linhas/tbl" if cap else ", export integral"
        print(f"  {database}: {len(pending)}/{len(ddl.tables)} tabelas pendentes{cap_label}")
        for table in pending[:8]:
            full = f"{table.schema}.{table.name}"
            rows = _row_count_hint(database, table.schema, table.name)
            dest = _table_data_path(out_db, table.schema, table.name)
            ck = _checkpoint_path(out_db, table.schema, table.name)
            partial = 0
            if ck.exists():
                partial = int(_load_checkpoint(ck).get("rows_exported") or 0)
            elif dest.exists() and dest.stat().st_size > 0:
                partial = -1  # parcial sem contagem rápida
            if partial > 0:
                rest = (rows - partial) if rows else None
                rest_s = f", faltam ~{rest:,}" if rest and rest > 0 else ""
                print(f"    - {full}: retomar {partial:,} linhas{rest_s}")
            elif partial == -1:
                print(f"    - {full}: retomar (parcial em disco)")
            elif rows is not None:
                eff = min(rows, cap) if cap and rows > cap else rows
                print(f"    - {full}: ~{eff:,} linhas")
            else:
                print(f"    - {full}")
        if len(pending) > 8:
            print(f"    ... +{len(pending) - 8} tabelas")
    print()


def backup_database(
    conn,
    ddl: DatabaseDdl,
    *,
    options: BackupOptions,
    reconnect,
) -> dict[str, Any]:
    database = ddl.database
    out_db = options.out_dir / database
    out_db.mkdir(parents=True, exist_ok=True)
    progress = _progress_path(out_db)
    completed = _load_progress(progress) if options.resume else set()
    pending = _pending_tables(ddl, completed)

    print(f"\n{'=' * 60}")
    print(f"Banco: {database}")
    print(f"  destino: {out_db}")
    print(f"  tabelas: {len(ddl.tables)} | pendentes: {len(pending)}")
    cap = _row_cap(options, database)
    if cap:
        print(f"  amostra: TOP {cap:,} linhas por tabela")

    if not options.resume or not (out_db / "schema" / "schema.sql").exists():
        print("  Exportando schema...")
        _write_schema(out_db, ddl)

    stats = {
        "database": database,
        "tables": len(ddl.tables),
        "rows": 0,
        "nonempty": 0,
        "sample_limit": cap,
    }
    sampled_tables: list[str] = []
    partial_tables: list[dict[str, Any]] = []
    schema_only_tables: list[str] = []

    for i, table in enumerate(ddl.tables, 1):
        full = f"{table.schema}.{table.name}"
        if options.resume and full in completed:
            continue

        if full in options.accept_partial:
            dest = _table_data_path(out_db, table.schema, table.name)
            if dest.exists() and dest.stat().st_size > 22:
                rows = _mark_accept_partial_table(
                    out_db, table, partial_tables=partial_tables
                )
                stats["rows"] += rows
                if rows > 0:
                    stats["nonempty"] += 1
                print(
                    f"  [{i}/{len(ddl.tables)}] {full}... "
                    f"aceito parcial ({rows:,} linhas, sem re-export)"
                )
                completed.add(full)
                _save_progress(progress, completed)
                if options.pause_table > 0:
                    time.sleep(options.pause_table)
                continue

        if _is_schema_only_table(options, database, table.schema, table.name):
            _mark_schema_only_table(out_db, table, schema_only_tables=schema_only_tables)
            print(f"  [{i}/{len(ddl.tables)}] {full}... schema-only (sem dados)")
            completed.add(full)
            _save_progress(progress, completed)
            if options.pause_table > 0:
                time.sleep(options.pause_table)
            continue

        tables_left = sum(
            1
            for t in ddl.tables[i - 1 :]
            if f"{t.schema}.{t.name}" not in completed
        )
        cap_row = _row_cap(options, database)
        inventory_rows = _row_count_hint(database, table.schema, table.name)
        is_sampled = cap_row is not None and (
            inventory_rows is None or inventory_rows > cap_row
        )
        show_inline = (inventory_rows or 0) > 10_000 or is_sampled
        if not show_inline:
            print(f"  [{i}/{len(ddl.tables)}] {full}...", end=" ", flush=True)
        rows = 0
        for attempt in range(1, options.table_retry_attempts + 1):
            try:
                rows = _export_table(
                    conn,
                    database,
                    table,
                    out_db,
                    options=options,
                    reconnect=reconnect,
                    table_idx=i,
                    table_total=len(ddl.tables),
                    tables_left=tables_left,
                )
                break
            except Exception as exc:
                if _needs_reconnect(exc) and attempt < options.table_retry_attempts:
                    wait = min(180, 20 * attempt)
                    print(
                        f"\n    prod indisponível em {full} — "
                        f"aguardando {wait}s ({attempt}/{options.table_retry_attempts})...",
                        flush=True,
                    )
                    time.sleep(wait)
                    reconnect()
                    continue
                print(f"\n  [{i}/{len(ddl.tables)}] {full}... ERRO: {exc}")
                raise
        stats["rows"] += rows
        if rows > 0:
            stats["nonempty"] += 1
        if is_sampled:
            sampled_tables.append(full)
        if show_inline:
            suffix = f" (TOP {cap_row:,})" if is_sampled else ""
            print(f"  -> {full}: {rows:,} linhas{suffix}", flush=True)
        else:
            print(f"{rows:,} linhas" if rows else "vazia")
        completed.add(full)
        _save_progress(progress, completed)
        if options.pause_table > 0:
            time.sleep(options.pause_table)

    manifest = {
        "database": database,
        "source": "MEREO_*",
        "tables": len(ddl.tables),
        "nonempty_tables": stats["nonempty"],
        "total_rows": stats["rows"],
        "sample_limit": cap,
        "sampled_tables": sampled_tables,
        "partial_tables": partial_tables,
        "schema_only_tables": schema_only_tables,
        "paths": {
            "schema_sql": str(out_db / "schema" / "schema.sql"),
            "data_dir": str(out_db / "data"),
        },
    }
    (out_db / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    if not options.resume:
        progress.unlink(missing_ok=True)
    print(f"  Concluído {database}: {stats['nonempty']} tbl com dados, {stats['rows']:,} linhas exportadas")
    return manifest


def run_backup(options: BackupOptions) -> int:
    print("Origem: MEREO_* (cliente — somente leitura)")
    print(f"Destino: {options.out_dir.resolve()}")
    print(f"Bancos: {', '.join(options.databases)}")
    print(
        f"batch={options.batch_size} pause_batch={options.pause_batch}s "
        f"pause_table={options.pause_table}s pause_db={options.pause_db}s"
    )
    print(f"resume={options.resume} skip_empty={options.skip_empty}")
    if options.sample_limit and options.sample_databases:
        print(
            f"sample_limit={options.sample_limit:,} em: "
            f"{', '.join(sorted(options.sample_databases))}"
        )
    if options.accept_partial:
        print(f"accept_partial={', '.join(sorted(options.accept_partial))}")
    if options.schema_only_patterns:
        dbs = ", ".join(sorted(options.schema_only_databases)) or "todos"
        print(f"schema_only em {dbs}: {len(options.schema_only_patterns)} padrões")
    print()

    options.out_dir.mkdir(parents=True, exist_ok=True)
    conn = db.connect(
        config=load_mereo_config(),
        timeout=600,
        login_timeout=options.login_timeout,
    )

    def reconnect():
        nonlocal conn
        try:
            conn.close()
        except Exception:
            pass
        conn = db.connect(
            config=load_mereo_config(),
            timeout=600,
            login_timeout=options.login_timeout,
        )
        return conn

    _print_backup_plan(options, conn)

    manifests = []
    try:
        for i, database in enumerate(options.databases):
            for attempt in range(1, options.table_retry_attempts + 1):
                try:
                    print(f"Extraindo DDL: {database}...")
                    ddl = extract_database_ddl(conn, database)
                    break
                except Exception as exc:
                    if _needs_reconnect(exc) and attempt < options.table_retry_attempts:
                        wait = min(180, 20 * attempt)
                        print(
                            f"    prod indisponível (DDL {database}) — "
                            f"aguardando {wait}s ({attempt}/{options.table_retry_attempts})...",
                            flush=True,
                        )
                        time.sleep(wait)
                        reconnect()
                        continue
                    raise
            manifests.append(backup_database(conn, ddl, options=options, reconnect=reconnect))
            if i < len(options.databases) - 1 and options.pause_db > 0:
                print(f"Pausa {options.pause_db}s antes do próximo banco...")
                time.sleep(options.pause_db)
    finally:
        conn.close()

    summary_path = options.out_dir / "summary.json"
    summary_path.write_text(json.dumps(manifests, indent=2), encoding="utf-8")
    print(f"\nBackup concluído. Resumo: {summary_path}")
    for m in manifests:
        print(f"  {m['database']}: {m['nonempty_tables']} tabelas com dados, {m['total_rows']:,} linhas")
    return 0


def main(argv: list[str] | None = None) -> int:
    if hasattr(sys.stdout, "reconfigure"):
        try:
            sys.stdout.reconfigure(line_buffering=True)
        except Exception:
            pass

    parser = argparse.ArgumentParser(
        description="Backup local dos bancos piloto (schema.sql + data/*.jsonl.gz)"
    )
    parser.add_argument(
        "--databases",
        default=",".join(PILOT_DATABASES),
        help="Bancos separados por vírgula",
    )
    parser.add_argument(
        "--out-dir",
        default=str(DEFAULT_OUT),
        help="Diretório base de saída (padrão: output/backups)",
    )
    parser.add_argument("--batch-size", type=int, default=500, help="Linhas por SELECT")
    parser.add_argument("--pause-batch", type=float, default=0.25, help="Pausa entre lotes (s)")
    parser.add_argument("--pause-table", type=float, default=0.4, help="Pausa entre tabelas (s)")
    parser.add_argument("--pause-db", type=float, default=15.0, help="Pausa entre bancos (s)")
    parser.add_argument("--resume", action="store_true", help="Retomar tabelas já exportadas")
    parser.add_argument(
        "--skip-empty",
        action="store_true",
        default=True,
        help="Pular SELECT em tabelas vazias (usa inventário local se existir)",
    )
    parser.add_argument(
        "--no-skip-empty",
        action="store_false",
        dest="skip_empty",
        help="Forçar SELECT mesmo em tabelas vazias no inventário",
    )
    parser.add_argument(
        "--sample-limit",
        type=int,
        default=None,
        help="TOP N linhas por tabela (aplica em --sample-databases)",
    )
    parser.add_argument(
        "--sample-databases",
        default="",
        help="Bancos com amostra TOP N (CSV). Ex.: MereoGR-Allos,MereoGR-Afya",
    )
    parser.add_argument(
        "--progress-every",
        type=int,
        default=20,
        help="Atualizar progresso a cada N lotes em tabelas grandes",
    )
    parser.add_argument(
        "--table-retry-attempts",
        type=int,
        default=15,
        help="Tentativas por tabela quando prod cai (aguarda entre tentativas)",
    )
    parser.add_argument(
        "--login-timeout",
        type=int,
        default=120,
        help="Timeout de login TCP em prod (segundos)",
    )
    parser.add_argument(
        "--accept-partial",
        default="",
        help="Tabelas CSV aceitas como parciais (ex.: dbo.ValorMatriz) — não re-exporta",
    )
    parser.add_argument(
        "--schema-only-tables",
        default="",
        help="Padrões schema.table sem dados (ex.: audit.AuditLogs,dbo.AUDIT_*)",
    )
    parser.add_argument(
        "--schema-only-audit",
        action="store_true",
        help="Usa padrões default de audit/log como schema-only",
    )
    parser.add_argument(
        "--schema-only-databases",
        default="",
        help="Bancos onde schema-only aplica (CSV). Default: --sample-databases",
    )
    args = parser.parse_args(argv)

    sample_dbs = frozenset(d.strip() for d in args.sample_databases.split(",") if d.strip())
    schema_only_dbs = frozenset(
        d.strip() for d in args.schema_only_databases.split(",") if d.strip()
    )
    if not schema_only_dbs and sample_dbs:
        schema_only_dbs = sample_dbs

    schema_patterns: tuple[str, ...] = ()
    if args.schema_only_tables.strip():
        schema_patterns = tuple(
            p.strip() for p in args.schema_only_tables.split(",") if p.strip()
        )
    elif args.schema_only_audit:
        schema_patterns = DEFAULT_SCHEMA_ONLY_PATTERNS

    options = BackupOptions(
        databases=[d.strip() for d in args.databases.split(",") if d.strip()],
        out_dir=Path(args.out_dir),
        batch_size=args.batch_size,
        pause_batch=args.pause_batch,
        pause_table=args.pause_table,
        pause_db=args.pause_db,
        resume=args.resume,
        skip_empty=args.skip_empty,
        sample_limit=args.sample_limit,
        sample_databases=sample_dbs,
        progress_every=max(1, args.progress_every),
        table_retry_attempts=max(1, args.table_retry_attempts),
        login_timeout=max(30, args.login_timeout),
        accept_partial=_parse_table_list(args.accept_partial),
        schema_only_patterns=schema_patterns,
        schema_only_databases=schema_only_dbs,
    )
    try:
        return run_backup(options)
    except KeyboardInterrupt:
        print("\nInterrompido — use --resume para continuar.", file=sys.stderr)
        return 130
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
