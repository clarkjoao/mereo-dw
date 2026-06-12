#!/usr/bin/env python3
"""Gera models dbt silver em lote a partir do catálogo + schema MereoGR-Afya."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
SILVER_DOMAINS = REPO_ROOT / "analytics" / "catalog" / "silver_domains.yaml"
SCHEMA_REF = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "tables" / "MereoGR-Afya.json"
OUT_ROOT = REPO_ROOT / "analytics" / "dbt" / "models" / "silver"
KUBECONFIG = Path.home() / ".kube" / "mereo-cdc.yaml"


def _snake_col(col: str) -> str:
    if col in ("ID",):
        return "id"
    if col == "Id":
        return "id"
    return re.sub(r"(?<!^)(?=[A-Z])", "_", col).lower()


def _load_schema_columns() -> dict[str, list[str]]:
    if not SCHEMA_REF.exists():
        return {}
    data = json.loads(SCHEMA_REF.read_text(encoding="utf-8"))
    out: dict[str, list[str]] = {}
    for t in data.get("tables", []):
        bronze = (
            t["table"]
            if t["schema"] == "cdc"
            else f"{t['schema']}__{t['table']}"
        )
        out[bronze] = [c["name"] for c in t.get("columns", [])]
    return out


def _describe_ch(bronze: str) -> list[str] | None:
    import os

    env = {**os.environ, "KUBECONFIG": str(KUBECONFIG)}
    try:
        out = subprocess.check_output(
            [
                "kubectl", "exec", "-n", "mereo", "chi-mereo-clickhouse-main-0-0-0", "--",
                "clickhouse-client", "-q", f"DESCRIBE TABLE raw.`{bronze}`",
            ],
            env=env,
            stderr=subprocess.DEVNULL,
            timeout=30,
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
        return None
    cols = []
    for line in out.decode().splitlines():
        col = line.split("\t")[0]
        if col not in ("tenant_slug", "_ts_ms", "_deleted"):
            cols.append(col)
    return cols or None


def _column_lines(columns: list[str]) -> str:
    lines = []
    for col in columns:
        alias = _snake_col(col)
        if col in ("ID", "Id"):
            lines.append(f"    {col} as {alias},")
        else:
            lines.append(f"    `{col}` as {alias},")
    return "\n".join(lines)


def _render_sql(domain: str, silver_table: str, bronze: str, wave: int, columns: list[str]) -> str:
    return f"""{{{{
  config(
    materialized='view',
    tags=['silver', '{domain}', 'wave_{wave}'],
  )
}}}}

select
    tenant_slug,
{_column_lines(columns)}
    _ts_ms,
    _deleted
from {{{{ source('bronze', '{bronze}') }}}}
where _deleted = 0
"""


def generate_batch(
    *,
    domain: str | None = None,
    missing_only: bool = True,
    use_ch: bool = False,
    dry_run: bool = False,
) -> dict[str, int]:
    catalog = yaml.safe_load(SILVER_DOMAINS.read_text(encoding="utf-8"))
    schema_cols = _load_schema_columns()
    stats = {"written": 0, "skipped": 0, "failed": 0}

    for dom in catalog.get("domains", []):
        dom_id = dom["id"]
        if domain and dom_id != domain:
            continue

        for ent in dom.get("entities", []):
            silver_table = ent["silver_table"]
            bronze = ent["bronze"]
            wave = ent.get("wave", 1)
            out_path = OUT_ROOT / dom_id / f"{silver_table}.sql"

            if missing_only and out_path.exists():
                stats["skipped"] += 1
                continue

            columns = None
            if use_ch:
                columns = _describe_ch(bronze)
            if not columns:
                columns = schema_cols.get(bronze)
            if not columns:
                stats["failed"] += 1
                print(f"  FAIL sem colunas: {bronze}")
                continue

            sql = _render_sql(dom_id, silver_table, bronze, wave, columns)
            if dry_run:
                print(f"  DRY {out_path} ({len(columns)} cols)")
            else:
                out_path.parent.mkdir(parents=True, exist_ok=True)
                out_path.write_text(sql, encoding="utf-8")
            stats["written"] += 1

    return stats


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Gera models silver em lote")
    parser.add_argument("--domain", help="Domínio (ex.: avaliacao)")
    parser.add_argument("--all", action="store_true", help="Todos os domínios")
    parser.add_argument(
        "--missing-only",
        action="store_true",
        default=True,
        help="Só arquivos .sql ausentes (default)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Regenerar mesmo se .sql existe",
    )
    parser.add_argument("--use-ch", action="store_true", help="DESCRIBE via kubectl (fallback schema JSON)")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)

    if not args.domain and not args.all:
        parser.error("Informe --domain ou --all")

    stats = generate_batch(
        domain=args.domain if not args.all else None,
        missing_only=not args.force,
        use_ch=args.use_ch,
        dry_run=args.dry_run,
    )
    print(f"Escritos: {stats['written']}, skip: {stats['skipped']}, fail: {stats['failed']}")
    return 1 if stats["failed"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
