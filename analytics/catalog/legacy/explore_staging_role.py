#!/usr/bin/env python3
"""Explora papel do MereoGR-Staging vs contrato cliente (Afya) e overlap de dados."""

from __future__ import annotations

import argparse
import csv
import gzip
import json
import os
import subprocess
from pathlib import Path
from typing import Any

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
SCHEMA_AFYA = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "tables" / "MereoGR-Afya.json"
SCHEMA_STAGING = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "tables" / "MereoGR-Staging.json"
DRIFT_CSV = REPO_ROOT / "output" / "groups" / "mereogr" / "schema" / "drift_summary.csv"
BACKUPS = REPO_ROOT / "output" / "backups"
OUT_CSV = REPO_ROOT / "analytics" / "catalog" / "staging_vs_client_diff.csv"
OUT_YAML = REPO_ROOT / "analytics" / "catalog" / "staging_exploration_summary.yaml"
KUBECONFIG = Path.home() / ".kube" / "mereo-cdc.yaml"


def _bronze(schema: str, table: str) -> str:
    return table if schema == "cdc" else f"{schema}__{table}"


def _count_rows_gz(path: Path) -> int:
    if not path.exists():
        return 0
    try:
        with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
            return sum(1 for _ in f)
    except OSError:
        return 0


def _load_table_sets(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {f"{t['schema']}.{t['table']}" for t in data.get("tables", [])}


def _staging_drift_rows() -> list[dict[str, str]]:
    if not DRIFT_CSV.exists():
        return []
    rows = []
    with DRIFT_CSV.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row.get("database") == "MereoGR-Staging":
                rows.append(row)
    return rows


def _overlap_colaborador_ids() -> dict[str, Any]:
    """Compara IDs de COLABORADOR entre backups staging/afya/allos."""
    bronze = "dbo__COLABORADOR"
    ids: dict[str, set[int]] = {}
    for slug, db in [("staging", "MereoGR-Staging"), ("afya", "MereoGR-Afya"), ("allos", "MereoGR-Allos")]:
        path = BACKUPS / db / "data" / f"{bronze}.jsonl.gz"
        s: set[int] = set()
        if path.exists():
            with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
                for line in f:
                    try:
                        row = json.loads(line)
                        if "ID" in row:
                            s.add(int(row["ID"]))
                    except (json.JSONDecodeError, ValueError, TypeError):
                        continue
        ids[slug] = s

    stg, afya, allos = ids.get("staging", set()), ids.get("afya", set()), ids.get("allos", set())
    return {
        "count_staging": len(stg),
        "count_afya": len(afya),
        "count_allos": len(allos),
        "staging_intersect_afya": len(stg & afya),
        "staging_intersect_allos": len(stg & allos),
        "staging_intersect_afya_pct": round(100 * len(stg & afya) / len(stg), 2) if stg else 0,
        "staging_intersect_allos_pct": round(100 * len(stg & allos) / len(stg), 2) if stg else 0,
        "conclusion": "mixed_client_data" if (stg & afya or stg & allos) else "isolated_synthetic",
    }


def _email_sample() -> dict[str, list[str]]:
    bronze = "dbo__COLABORADOR"
    out: dict[str, list[str]] = {}
    for slug, db in [("staging", "MereoGR-Staging"), ("afya", "MereoGR-Afya"), ("allos", "MereoGR-Allos")]:
        path = BACKUPS / db / "data" / f"{bronze}.jsonl.gz"
        emails: list[str] = []
        if path.exists():
            with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
                for i, line in enumerate(f):
                    if i >= 5:
                        break
                    try:
                        row = json.loads(line)
                        emails.append(str(row.get("EMAIL", "")))
                    except json.JSONDecodeError:
                        continue
        out[slug] = emails
    return out


def _ch_overlap_query() -> dict[str, Any] | None:
    pw_path = REPO_ROOT / "analytics" / ".ch-dbt-password"
    if not pw_path.exists():
        return None
    password = pw_path.read_text().strip()
    env = {**os.environ, "KUBECONFIG": str(KUBECONFIG)}
    query = """
    SELECT
      (SELECT count() FROM colaborador.pessoa WHERE tenant_slug='staging') AS stg_cnt,
      (SELECT count() FROM colaborador.pessoa WHERE tenant_slug='afya') AS afya_cnt,
      (SELECT count() FROM colaborador.pessoa WHERE tenant_slug='allos') AS allos_cnt,
      (SELECT count() FROM (
        SELECT id FROM colaborador.pessoa WHERE tenant_slug='staging'
        INTERSECT
        SELECT id FROM colaborador.pessoa WHERE tenant_slug='afya'
      )) AS id_overlap_stg_afya
    FORMAT JSON
    """
    try:
        out = subprocess.check_output(
            [
                "kubectl", "exec", "-n", "mereo", "chi-mereo-clickhouse-main-0-0-0", "--",
                "clickhouse-client", "-u", "dbt", f"--password={password}", "-q", query,
            ],
            env=env,
            stderr=subprocess.DEVNULL,
            timeout=30,
        )
        data = json.loads(out.decode())
        return data.get("data", [{}])[0] if data.get("data") else {}
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
        return None


def explore() -> dict[str, Any]:
    afya_tables = _load_table_sets(SCHEMA_AFYA)
    stg_tables = _load_table_sets(SCHEMA_STAGING)
    missing_in_staging = sorted(afya_tables - stg_tables)
    extra_in_staging = sorted(stg_tables - afya_tables)

    drift_rows = _staging_drift_rows()
    missing_table = sorted({r["table"] for r in drift_rows if r["diff_type"] == "missing_table"})

    stg_schema_tables = sorted(t for t in stg_tables if t.startswith("stg."))

    # Row profiling: staging-only populated vs clients
    diff_rows: list[dict[str, Any]] = []
    staging_only_populated: list[str] = []
    for erp in sorted(afya_tables):
        schema_name, table = erp.split(".", 1)
        bronze = _bronze(schema_name, table)
        r_stg = _count_rows_gz(BACKUPS / "MereoGR-Staging" / "data" / f"{bronze}.jsonl.gz")
        r_afya = _count_rows_gz(BACKUPS / "MereoGR-Afya" / "data" / f"{bronze}.jsonl.gz")
        r_allos = _count_rows_gz(BACKUPS / "MereoGR-Allos" / "data" / f"{bronze}.jsonl.gz")
        if erp in missing_in_staging:
            diff_type = "missing_table_in_staging"
        elif erp in extra_in_staging:
            diff_type = "extra_in_staging"
        else:
            diff_type = "present_both"
        if r_stg > 0 and r_afya == 0 and r_allos == 0:
            staging_only_populated.append(erp)
        diff_rows.append({
            "erp_key": erp,
            "bronze": bronze,
            "diff_type": diff_type,
            "rows_staging": r_stg,
            "rows_afya": r_afya,
            "rows_allos": r_allos,
            "staging_only_data": "yes" if erp in staging_only_populated else "no",
        })

    with OUT_CSV.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(diff_rows[0].keys()))
        writer.writeheader()
        writer.writerows(diff_rows)

    id_overlap = _overlap_colaborador_ids()
    email_sample = _email_sample()
    ch_overlap = _ch_overlap_query()

    top_staging_volume = sorted(
        [r for r in diff_rows if r["rows_staging"] > 0],
        key=lambda x: -x["rows_staging"],
    )[:15]

    summary = {
        "reference_db": "MereoGR-Afya",
        "staging_db": "MereoGR-Staging",
        "afya_table_count": len(afya_tables),
        "staging_table_count": len(stg_tables),
        "missing_tables_in_staging": missing_in_staging,
        "missing_table_count": len(missing_in_staging),
        "extra_tables_in_staging": extra_in_staging,
        "stg_schema_tables": stg_schema_tables,
        "drift_diff_count": len(drift_rows),
        "colaborador_id_overlap": id_overlap,
        "email_samples": email_sample,
        "clickhouse_overlap": ch_overlap,
        "staging_only_populated_count": len(staging_only_populated),
        "staging_only_populated_top": staging_only_populated[:25],
        "top_staging_volume_tables": top_staging_volume,
        "valor_matriz": next((r for r in diff_rows if r["erp_key"] == "dbo.ValorMatriz"), {}),
        "staging_role_options": {
            "exclude_from_marts": "Marts só tenant_slug cliente; staging fora de KPIs",
            "flag_is_internal": "Incluir com is_internal=true para QA",
            "separate_bronze_path": "raw_internal.* ou database separado",
        },
        "recommendation": (
            "Staging é ambiente interno QA — subset de IDs reutilizados (~99% COLABORADOR) "
            "com PII anonimizada; não é cliente de produção; excluir de marts; "
            "ValorMatriz é sandbox de volume (~5,9M rows)."
        ),
    }
    OUT_YAML.write_text(yaml.dump(summary, allow_unicode=True, sort_keys=False, default_flow_style=False), encoding="utf-8")
    return summary


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Explora papel do MereoGR-Staging")
    parser.parse_args(argv)
    summary = explore()
    print(f"Afya tables: {summary['afya_table_count']}, Staging: {summary['staging_table_count']}")
    print(f"Missing in Staging: {summary['missing_table_count']}")
    print(f"COLABORADOR overlap: {summary['colaborador_id_overlap']}")
    print(f"Staging-only populated: {summary['staging_only_populated_count']}")
    print(f"CSV: {OUT_CSV}")
    print(f"YAML: {OUT_YAML}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
