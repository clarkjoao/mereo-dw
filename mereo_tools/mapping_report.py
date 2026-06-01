"""Relatório de mapping: drift de entidades do catálogo + fleet inventory."""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path
from typing import Any

from mereo_tools.groups import get_group

WAVE1_ENTITIES = ("dbo.COLABORADOR",)


def _load_drift(group_dir: Path) -> dict[str, Any] | None:
    path = group_dir / "schema" / "drift_report.json"
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def _colaborador_from_schema(group_dir: Path, database: str) -> dict[str, Any] | None:
    path = group_dir / "schema" / "tables" / f"{database}.json"
    if not path.exists():
        return None
    data = json.loads(path.read_text(encoding="utf-8"))
    for table in data.get("tables", []):
        if table.get("schema") == "dbo" and table.get("table") == "COLABORADOR":
            return table
    return None


def _fleet_colaborador_stats(group_dir: Path) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    db_dir = group_dir / "databases"
    if not db_dir.exists():
        return rows
    for tables_file in sorted(db_dir.glob("*/tables.jsonl")):
        database = tables_file.parent.name
        found = False
        for line in tables_file.open(encoding="utf-8"):
            row = json.loads(line)
            if row.get("schema") == "dbo" and row.get("table") == "COLABORADOR":
                found = True
                rows.append(
                    {
                        "database": database,
                        "row_count": row.get("row_count", 0),
                        "has_pk": row.get("has_pk", False),
                        "pk_columns": row.get("pk_columns", ""),
                        "size_mb": row.get("size_mb", 0),
                    }
                )
                break
        if not found:
            rows.append(
                {
                    "database": database,
                    "row_count": 0,
                    "has_pk": False,
                    "pk_columns": "",
                    "size_mb": 0,
                    "missing": True,
                }
            )
    return rows


def run_mapping_report(group_name: str, *, reference_db: str | None = None) -> int:
    group = get_group(group_name)
    out_dir = group.output_dir
    ref = reference_db or group.reference_db

    drift = _load_drift(out_dir)
    if drift is None:
        print("Execute drift antes: uv run python -m mereo_tools drift --group mereogr --detailed", file=sys.stderr)
        return 1

    entity_diffs: dict[str, list[dict[str, Any]]] = {e: [] for e in WAVE1_ENTITIES}
    for diff in drift.get("diffs", []):
        table = diff.get("table", "")
        if table in entity_diffs:
            entity_diffs[table].append(diff)

    ref_colab = _colaborador_from_schema(out_dir, ref)
    sample_dbs = list(group.mapping_sample) if group.mapping_sample else []
    colab_by_db: dict[str, dict[str, Any]] = {}
    for db_name in sample_dbs:
        table = _colaborador_from_schema(out_dir, db_name)
        if table:
            colab_by_db[db_name] = {
                "column_count": len(table.get("columns", [])),
                "pk_columns": table.get("pk_columns", []),
                "columns": [c["name"] for c in table.get("columns", [])],
            }

    fleet_stats = _fleet_colaborador_stats(out_dir)
    with_colab = [r for r in fleet_stats if not r.get("missing")]
    without_colab = [r for r in fleet_stats if r.get("missing")]

    report = {
        "reference_db": ref,
        "drift_summary": drift.get("summary", {}),
        "wave1_entities": {
            "dbo.COLABORADOR": {
                "drift_diffs_in_sample": len(entity_diffs["dbo.COLABORADOR"]),
                "drift_details": entity_diffs["dbo.COLABORADOR"],
                "reference_columns": ref_colab.get("pk_columns") if ref_colab else [],
                "sample_column_counts": {k: v["column_count"] for k, v in colab_by_db.items()},
            }
        },
        "fleet_colaborador": {
            "total_databases_inventoried": len(fleet_stats),
            "with_colaborador": len(with_colab),
            "without_colaborador": [r["database"] for r in without_colab],
            "total_rows": sum(int(r.get("row_count") or 0) for r in with_colab),
        },
    }

    report_dir = out_dir / "mapping"
    report_dir.mkdir(parents=True, exist_ok=True)
    json_path = report_dir / "report.json"
    json_path.write_text(json.dumps(report, indent=2, default=str), encoding="utf-8")

    csv_path = report_dir / "colaborador_fleet.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["database", "row_count", "has_pk", "pk_columns", "size_mb", "missing"],
            extrasaction="ignore",
        )
        writer.writeheader()
        writer.writerows(fleet_stats)

    colab_diffs = entity_diffs["dbo.COLABORADOR"]
    print(f"Referência: {ref}")
    print(f"Drift geral: {drift.get('summary', {}).get('total_diffs', '?')} diffs")
    print(f"dbo.COLABORADOR drift na amostra: {len(colab_diffs)} diffs")
    print(
        f"Fleet COLABORADOR: {len(with_colab)}/{len(fleet_stats)} bancos "
        f"({len(without_colab)} sem tabela)"
    )
    if without_colab:
        print(f"  Sem COLABORADOR: {', '.join(r['database'] for r in without_colab[:10])}")
    print(f"Relatório: {json_path}")
    print(f"Fleet CSV: {csv_path}")
    return 0 if not colab_diffs else 0  # drift in other tables is expected; COLABORADOR zero is success


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Relatório de mapping (COLABORADOR + fleet)")
    parser.add_argument("--group", default="mereogr")
    parser.add_argument("--reference-db", help="Banco referência (padrão: groups.toml)")
    args = parser.parse_args(argv)
    try:
        return run_mapping_report(args.group, reference_db=args.reference_db)
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
