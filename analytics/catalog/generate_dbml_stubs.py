#!/usr/bin/env python3
"""Gera specs/001-snowflake-dbml-model/contracts/mereo_snowflake_full.sql.

Arquivo SQL único, anotado para o LocalDrawDB (@layer/@group/@note/@fk/@origen/@map),
com TODAS as tabelas das 4 camadas:

  RAW     616  colunas completas do schema Afya; @fk do grafo; hubs curados viram
               override de @note e união de @fk
  STAGING 209  DIM/FACT/BRIDGE/REF (DEFER não gera staging); snake_case + @map por coluna
  EDW     448  nomes verbatim da matriz (dim_/fact_/brg_/bridge_/ref_/defer_);
               surrogate {entity}_key; @origen SEMPRE staging.*
  MART      3  blocos curados verbatim
  +pipeline.schema_drift_log (quarentena de drift de tenant)

Blocos curados de staging/edw/mart do spine entram verbatim. Gaps (FKs para alvos
sem EDW, tipos exóticos, colisões) vão para contracts/generator_gaps.md.

Uso:
    python3 analytics/catalog/generate_dbml_stubs.py [--layers raw,staging,edw,mart]

Idempotente: regenera o arquivo inteiro com ordenação determinística.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dbml_model import (  # noqa: E402
    REPO_ROOT,
    FkEdge,
    MatrixRow,
    Model,
    load_model,
    map_mssql_type,
    snake_case,
)

OUT_SQL = REPO_ROOT / "specs/001-snowflake-dbml-model/contracts/mereo_snowflake_full.sql"
OUT_GAPS = REPO_ROOT / "specs/001-snowflake-dbml-model/contracts/generator_gaps.md"

EDW_PREFIXES = ("dim_", "fact_", "brg_", "bridge_", "ref_", "defer_")

ROLE_GROUP = {"DIM": "dimensional", "FACT": "fatos", "BRIDGE": "bridge", "REF": "ref", "DEFER": "defer"}


def edw_entity(edw_name: str) -> str:
    for p in EDW_PREFIXES:
        if edw_name.startswith(p):
            return edw_name[len(p):]
    return edw_name


def strip_id_affixes(col_snake: str) -> str:
    s = re.sub(r"^id_", "", col_snake)
    s = re.sub(r"_id$", "", s)
    return s or col_snake


# ---------------------------------------------------------------------------
# RAW
# ---------------------------------------------------------------------------

def emit_raw(m: Model, used_curated: set[str]) -> list[str]:
    out: list[str] = [section_banner("RAW — landing CDC/bulk (616 tabelas, colunas completas do ERP)")]
    rows = sorted(m.rows, key=lambda r: (r.localdrawdb_group, r.bronze_table))
    for r in rows:
        ts = m.schemas[r.bronze_table]
        curated = m.curated.get(f"raw.{r.bronze_table}")
        if curated:
            used_curated.add(curated.qualified)

        header = ["-- @layer: raw", f"-- @group: {r.localdrawdb_group}"]
        note = None
        if curated:
            cn = curated.annotation("note")
            if cn:
                note = cn[0]
        if note is None:
            note = f"-- @note: {r.note}" if r.note else f"-- @note: {r.erp_key} — landing CDC/bulk"
        header.append(note)

        # @fk: união grafo + curados, dedup por (col -> alvo)
        fk_lines: list[str] = []
        seen_fk: set[str] = set()
        for e in m.edges_from(r.bronze_table):
            if len(e.from_columns) != len(e.to_columns):
                m.gaps.append(f"FK-ARITY: {e.fk_name} em {r.bronze_table}: {e.from_columns} -> {e.to_columns}")
                continue
            for fc, tc in zip(e.from_columns, e.to_columns):
                key = f"{fc.lower()}->{e.to_bronze.lower()}.{tc.lower()}"
                if key in seen_fk:
                    continue
                seen_fk.add(key)
                fk_lines.append(f"-- @fk: {fc} -> raw.{e.to_bronze}.{tc}")
        if curated:
            real_cols = {c.name.lower() for c in ts.columns}
            for ln in curated.annotation("fk"):
                mm = re.match(r"^--\s*@fk\s*:\s*(\S+)\s*->\s*(\S+)\.(\S+)$", ln)
                if mm:
                    # curadoria pode referenciar coluna que não existe no schema real
                    if mm.group(1).lower() not in real_cols:
                        m.gaps.append(
                            f"FK-CURADO-INVÁLIDO: raw.{r.bronze_table}: coluna '{mm.group(1)}' "
                            f"não existe no schema Afya — @fk descartado"
                        )
                        continue
                    key = f"{mm.group(1).lower()}->{mm.group(2).lower()}.{mm.group(3).lower()}"
                    if key in seen_fk:
                        continue
                    seen_fk.add(key)
                fk_lines.append(ln)
        header.extend(sorted(fk_lines))

        body = [f"CREATE TABLE IF NOT EXISTS raw.{r.bronze_table} (", "  tenant_slug STRING,"]
        for c in ts.columns:
            body.append(f"  {c.name} {map_mssql_type(c.mssql_type, m.gaps, f'raw.{r.bronze_table}.{c.name}')},")
        body.append("  _ts_ms BIGINT,")
        body.append("  _deleted INT,")
        if ts.pk_columns:
            body.append(f"  PRIMARY KEY (tenant_slug, {', '.join(ts.pk_columns)})")
        else:
            m.gaps.append(f"PK: {r.bronze_table} sem PK no schema Afya -> PRIMARY KEY (tenant_slug)")
            body.append("  PRIMARY KEY (tenant_slug)")
        body.append(") USING DELTA;")
        out.append("\n".join(header + body))
    return out


# ---------------------------------------------------------------------------
# STAGING
# ---------------------------------------------------------------------------

def staging_columns(m: Model, r: MatrixRow) -> list[tuple[str, str, str]]:
    """[(snake, TYPE, source_col)] com detecção de colisão snake_case."""
    ts = m.schemas[r.bronze_table]
    seen: dict[str, int] = {}
    cols: list[tuple[str, str, str]] = []
    for c in ts.columns:
        sn = snake_case(c.name)
        if sn in seen:
            seen[sn] += 1
            m.gaps.append(f"SNAKE-COLISÃO: {r.bronze_table}.{c.name} -> {sn}_{seen[sn]}")
            sn = f"{sn}_{seen[sn]}"
        else:
            seen[sn] = 1
        cols.append((sn, map_mssql_type(c.mssql_type, m.gaps, f"staging.{r.staging_name}.{sn}"), c.name))
    return cols


def emit_staging(m: Model, used_curated: set[str]) -> list[str]:
    out = [section_banner("STAGING — cleanse/tipagem (DIM/FACT/BRIDGE/REF; DEFER fica só em raw)")]
    rows = sorted((r for r in m.rows if r.has_staging), key=lambda r: (r.domain, r.staging_name))
    for r in rows:
        curated = m.curated.get(r.staging_object)
        if curated:
            used_curated.add(curated.qualified)
            out.append(curated.text)
            continue
        ts = m.schemas[r.bronze_table]
        header = [
            "-- @layer: staging",
            "-- @group: staging",
            f"-- @note: Cleanse {r.erp_key} — snake_case, tipagem, filtra _deleted=0",
            f"-- @origen: raw.{r.bronze_table}",
        ]
        body = [f"CREATE TABLE IF NOT EXISTS staging.{r.staging_name} (", "  tenant_slug STRING,"]
        cols = staging_columns(m, r)
        for sn, typ, src in cols:
            body.append(f"  {sn} {typ}, -- @map <- raw.{r.bronze_table}.{src}")
        pk_snakes = [snake_case(p) for p in ts.pk_columns]
        if pk_snakes:
            body.append(f"  PRIMARY KEY (tenant_slug, {', '.join(pk_snakes)})")
        else:
            body.append("  PRIMARY KEY (tenant_slug)")
        body.append(") USING DELTA;")
        out.append("\n".join(header + body))
    return out


# ---------------------------------------------------------------------------
# EDW
# ---------------------------------------------------------------------------

_FIRST_COL_RE = re.compile(r"^\s{2}([a-z_][a-z0-9_]*)\s")


def surrogate_lookup(m: Model) -> dict[str, str]:
    """edw_object -> nome real da coluna surrogate.

    Curados usam nomes semânticos (dim_org_area -> area_key, ref_unit_of_measure ->
    uom_key); gerados seguem a regra {entity}_key. Lê a primeira coluna do bloco curado.
    """
    out: dict[str, str] = {}
    for r in m.rows:
        if not r.edw_object:
            continue
        curated = m.curated.get(r.edw_object)
        if curated:
            for line in curated.body.splitlines()[1:]:
                fc = _FIRST_COL_RE.match(line)
                if fc:
                    out[r.edw_object] = fc.group(1)
                    break
        else:
            out[r.edw_object] = f"{edw_entity(r.edw_name)}_key"
    return out


def resolve_fk_keys(
    m: Model, r: MatrixRow, by_bronze: dict[str, MatrixRow], surrogates: dict[str, str]
) -> list[tuple[str, str, str]]:
    """[(key_col, target_edw_object, target_key_col)] para arestas com alvo DIM/REF."""
    resolved: list[tuple[str, FkEdge, MatrixRow]] = []
    seen_pairs: set[tuple[str, str, str]] = set()
    for e in m.edges_from(r.bronze_table):
        if len(e.from_columns) != 1:
            continue  # arity já reportada na RAW
        tgt = by_bronze.get(e.to_bronze)
        if tgt is None:
            continue
        # bancos fonte têm FKs duplicadas (mesma coluna -> mesmo alvo, fk_name distinto)
        pair = (e.from_columns[0].lower(), e.to_bronze.lower(), e.to_columns[0].lower())
        if pair in seen_pairs:
            continue
        seen_pairs.add(pair)
        if tgt.dimensional_role in ("DIM", "REF"):
            resolved.append((e.from_columns[0], e, tgt))
        elif tgt.dimensional_role in ("FACT", "BRIDGE", "DEFER", "EXCLUDE"):
            m.gaps.append(
                f"FK-SEM-DIM: {r.edw_object or r.bronze_table}.{e.from_columns[0]} -> "
                f"{e.to_bronze} ({tgt.dimensional_role}) — mantém id natural, sem @fk"
            )
    # nomes: plain se alvo único; prefixado se 2+ arestas para o mesmo alvo ou self-FK
    by_target: dict[str, int] = {}
    for _, _, tgt in resolved:
        by_target[tgt.edw_object] = by_target.get(tgt.edw_object, 0) + 1
    keys: list[tuple[str, str, str]] = []
    seen_names: set[str] = set()
    for from_col, e, tgt in sorted(resolved, key=lambda x: (x[2].edw_object, x[0])):
        target_key = surrogates[tgt.edw_object]
        is_self = tgt.bronze_table == r.bronze_table
        if by_target[tgt.edw_object] > 1 or is_self:
            name = f"{strip_id_affixes(snake_case(from_col))}_{target_key}"
        else:
            name = target_key
        if name in seen_names:
            base = name
            i = 2
            while f"{base}_{i}" in seen_names:
                i += 1
            name = f"{base}_{i}"
            m.gaps.append(f"KEY-COLISÃO: {r.edw_object}: {base} duplicado -> {name}")
        seen_names.add(name)
        keys.append((name, tgt.edw_object, target_key))
    return keys


def emit_edw(m: Model, used_curated: set[str]) -> list[str]:
    out = [section_banner("EDW — snowflake conformado (@origen SEMPRE via staging)")]
    by_bronze = m.row_by_bronze()
    surrogates = surrogate_lookup(m)
    cat_order = {"dim_": 0, "ref_": 1, "brg_": 2, "bridge_": 2, "fact_": 3, "defer_": 4}

    def cat(r: MatrixRow) -> int:
        for p, i in cat_order.items():
            if r.edw_name.startswith(p):
                return i
        return 5

    rows = sorted((r for r in m.rows if r.edw_object), key=lambda r: (cat(r), r.domain, r.edw_name))
    for r in rows:
        curated = m.curated.get(r.edw_object)
        if curated:
            used_curated.add(curated.qualified)
            out.append(curated.text)
            continue

        entity = edw_entity(r.edw_name)
        ts = m.schemas[r.bronze_table]
        pk_snakes = [snake_case(p) for p in ts.pk_columns]
        grain = f"(tenant_slug, {', '.join(pk_snakes)})" if pk_snakes else "(tenant_slug)"

        if r.dimensional_role == "DEFER":
            header = [
                "-- @layer: edw",
                "-- @group: defer",
                f"-- @note: DEFER {r.erp_key} — stub sem dados piloto; origem reservada raw.{r.bronze_table} via {r.staging_object}",
            ]
            body = [f"CREATE TABLE IF NOT EXISTS edw.{r.edw_name} (", f"  {entity}_key BIGINT,", "  tenant_slug STRING,"]
            for p in pk_snakes:
                if p != f"{entity}_key":
                    body.append(f"  {p} BIGINT,")
            body.append(f"  PRIMARY KEY ({entity}_key)")
            body.append(") USING DELTA;")
            out.append("\n".join(header + body))
            continue

        group = ROLE_GROUP[r.dimensional_role]
        scd = " SCD1" if r.dimensional_role == "DIM" else ""
        header = [
            "-- @layer: edw",
            f"-- @group: {group}",
            f"-- @note: {r.dimensional_role} {r.erp_key}{scd} — grain {grain}",
            f"-- @origen: {r.staging_object}",
        ]
        fk_keys = resolve_fk_keys(m, r, by_bronze, surrogates)
        for key_col, target_obj, target_key in fk_keys:
            header.append(f"-- @fk: {key_col} -> {target_obj}.{target_key}")

        body = [f"CREATE TABLE IF NOT EXISTS edw.{r.edw_name} (", f"  {entity}_key BIGINT,", "  tenant_slug STRING,"]
        stg_cols = staging_columns(m, r)
        taken = {f"{entity}_key", "tenant_slug"} | {k for k, _, _ in fk_keys}
        for key_col, _, _ in fk_keys:
            body.append(f"  {key_col} BIGINT,")
        for sn, typ, src in stg_cols:
            if sn in taken:
                m.gaps.append(f"COL-SOMBRA: edw.{r.edw_name}.{sn} colide com surrogate — mantido só o key")
                continue
            body.append(f"  {sn} {typ}, -- @map <- {r.staging_object}.{sn}")
        body.append(f"  PRIMARY KEY ({entity}_key)")
        body.append(") USING DELTA;")
        out.append("\n".join(header + body))
    return out


# ---------------------------------------------------------------------------
# MART + pipeline
# ---------------------------------------------------------------------------

def emit_mart(m: Model, used_curated: set[str]) -> list[str]:
    out = [section_banner("MART — consumo (apenas EDW como origem)")]
    for q, b in sorted(m.curated.items()):
        if b.schema == "mart":
            used_curated.add(q)
            out.append(b.text)
    out.append(
        "\n".join(
            [
                "-- @layer: raw",
                "-- @group: pipeline",
                "-- @note: Quarentena de drift de schema — todo objeto/coluna/dado de tenant que não casa com o contrato de 616 tabelas é logado aqui para avaliação futura (nunca descartado em silêncio)",
                "CREATE TABLE IF NOT EXISTS pipeline.schema_drift_log (",
                "  tenant_slug STRING,",
                "  object_type STRING,",
                "  object_name STRING,",
                "  reason STRING,",
                "  payload STRING,",
                "  detected_at TIMESTAMP,",
                "  PRIMARY KEY (tenant_slug, object_type, object_name, detected_at)",
                ") USING DELTA;",
            ]
        )
    )
    return out


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def section_banner(title: str) -> str:
    bar = "-- " + "=" * 77
    return f"{bar}\n-- {title}\n{bar}"


def file_banner(m: Model, layers: list[str]) -> str:
    n_raw = len(m.rows)
    n_stg = sum(1 for r in m.rows if r.has_staging)
    n_edw = sum(1 for r in m.rows if r.edw_object)
    n_mart = sum(1 for b in m.curated.values() if b.schema == "mart")
    return "\n".join(
        [
            "-- " + "=" * 77,
            "-- Mereo ERP — modelo Snowflake COMPLETO (gerado — NÃO EDITAR À MÃO)",
            "-- Feature: specs/001-snowflake-dbml-model",
            "--",
            "-- Regenerar:  python3 analytics/catalog/generate_dbml_stubs.py",
            "-- Validar:    python3 analytics/catalog/validate_dbml_full.py",
            "--",
            f"-- Camadas geradas: {','.join(layers)}",
            f"-- Contagens: raw={n_raw} staging={n_stg} edw={n_edw} mart={n_mart} pipeline=1",
            "-- Curadoria: blocos staging/edw/mart do spine mereo_snowflake_dimensional.sql",
            "--            entram verbatim; raw curada vira override de @note/@fk",
            "-- Regra:     edw.* NUNCA @origen raw.* (sempre via staging)",
            "-- " + "=" * 77,
        ]
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--layers", default="raw,staging,edw,mart", help="csv: raw,staging,edw,mart")
    args = ap.parse_args()
    layers = [s.strip() for s in args.layers.split(",") if s.strip()]

    m = load_model()
    used_curated: set[str] = set()
    parts: list[str] = [file_banner(m, layers)]
    if "raw" in layers:
        parts.extend(emit_raw(m, used_curated))
    if "staging" in layers:
        parts.extend(emit_staging(m, used_curated))
    if "edw" in layers:
        parts.extend(emit_edw(m, used_curated))
    if "mart" in layers:
        parts.extend(emit_mart(m, used_curated))

    OUT_SQL.write_text("\n\n".join(parts) + "\n", encoding="utf-8")

    # blocos curados das camadas gerada que não foram consumidos = erro de alinhamento
    expected = {q for q, b in m.curated.items() if b.schema in layers}
    unused = expected - used_curated
    if unused:
        print(f"ERRO: blocos curados não consumidos: {sorted(unused)}", file=sys.stderr)
        return 1

    gap_lines = ["# Generator gaps — mereo_snowflake_full.sql", "", f"Total: {len(m.gaps)}", ""]
    by_kind: dict[str, list[str]] = {}
    for g in sorted(m.gaps):
        kind = g.split(":", 1)[0]
        by_kind.setdefault(kind, []).append(g)
    for kind in sorted(by_kind):
        gap_lines.append(f"## {kind} ({len(by_kind[kind])})")
        gap_lines.append("")
        gap_lines.extend(f"- {g}" for g in by_kind[kind])
        gap_lines.append("")
    OUT_GAPS.write_text("\n".join(gap_lines), encoding="utf-8")

    n_tables = sum(p.count("CREATE TABLE IF NOT EXISTS") for p in parts)
    size_kb = OUT_SQL.stat().st_size // 1024
    print(f"OK: {OUT_SQL.name} — {n_tables} tabelas, {size_kb} KB, {len(m.gaps)} gaps, "
          f"{len(used_curated)}/{len(expected)} curados consumidos")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
