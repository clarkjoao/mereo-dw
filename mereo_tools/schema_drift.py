"""Compara schemas entre bancos do grupo e detecta drift."""

from __future__ import annotations

import csv
import hashlib
import json
import sys
from typing import Any

from mereo_tools.groups import get_group


def table_fingerprint(table: dict[str, Any]) -> str:
    cols = []
    for c in sorted(table["columns"], key=lambda x: x["name"].lower()):
        cols.append(f"{c['name']}:{c['type']}:{'null' if c['nullable'] else 'notnull'}:{'pk' if c.get('is_pk') else ''}")
    key = f"{table['schema']}.{table['table']}|" + "|".join(cols)
    return hashlib.sha256(key.encode()).hexdigest()[:16]


def column_signature(table: dict[str, Any]) -> dict[str, str]:
    return {c["name"]: c["type"] for c in table["columns"]}


def run_drift(group_name: str, reference_db: str | None = None, *, detailed: bool = False) -> int:
    group = get_group(group_name)
    schema_dir = group.output_dir / "schema" / "tables"
    ref_name = reference_db or group.reference_db

    if not schema_dir.exists():
        print(f"Execute schema extract antes. Pasta ausente: {schema_dir}", file=sys.stderr)
        return 1

    schema_files = sorted(schema_dir.glob("*.json"))
    if not schema_files:
        print("Nenhum schema encontrado.", file=sys.stderr)
        return 1

    by_db: dict[str, dict[str, dict[str, Any]]] = {}
    fingerprints: dict[str, dict[str, str]] = {}

    print(f"Carregando {len(schema_files)} schemas...")
    for i, path in enumerate(schema_files, 1):
        if i % 50 == 0:
            print(f"  {i}/{len(schema_files)}")
        data = json.loads(path.read_text(encoding="utf-8"))
        db_name = data["database"]
        tables_map: dict[str, dict[str, Any]] = {}
        fp_map: dict[str, str] = {}
        for t in data.get("tables", []):
            full = f"{t['schema']}.{t['table']}"
            tables_map[full] = t
            fp_map[full] = table_fingerprint(t)
        by_db[db_name] = tables_map
        fingerprints[db_name] = fp_map

    if ref_name not in by_db:
        ref_name = schema_files[0].stem
        print(f"Banco referência não encontrado; usando {ref_name}")

    ref_tables = by_db[ref_name]
    ref_fps = fingerprints[ref_name]
    all_table_names = set()
    for fps in fingerprints.values():
        all_table_names.update(fps.keys())

    diffs: list[dict[str, Any]] = []
    db_names = sorted(by_db.keys())

    for table_name in sorted(all_table_names):
        ref_fp = ref_fps.get(table_name)
        ref_table = ref_tables.get(table_name)

        for db_name in db_names:
            if db_name == ref_name:
                continue
            db_fp = fingerprints[db_name].get(table_name)
            db_table = by_db[db_name].get(table_name)

            if ref_table and not db_table:
                diffs.append(
                    {
                        "database": db_name,
                        "table": table_name,
                        "diff_type": "missing_table",
                        "expected": "exists",
                        "actual": "missing",
                        "reference_db": ref_name,
                    }
                )
            elif db_table and not ref_table:
                diffs.append(
                    {
                        "database": db_name,
                        "table": table_name,
                        "diff_type": "extra_table",
                        "expected": "missing",
                        "actual": "exists",
                        "reference_db": ref_name,
                    }
                )
            elif ref_fp and db_fp and ref_fp != db_fp:
                if not detailed:
                    diffs.append(
                        {
                            "database": db_name,
                            "table": table_name,
                            "diff_type": "schema_mismatch",
                            "expected": ref_fp,
                            "actual": db_fp,
                            "reference_db": ref_name,
                        }
                    )
                else:
                    ref_cols = column_signature(ref_table) if ref_table else {}
                    db_cols = column_signature(db_table) if db_table else {}
                    for col, typ in ref_cols.items():
                        if col not in db_cols:
                            diffs.append(
                                {
                                    "database": db_name,
                                    "table": table_name,
                                    "diff_type": "missing_column",
                                    "expected": f"{col} {typ}",
                                    "actual": "",
                                    "reference_db": ref_name,
                                }
                            )
                        elif db_cols[col] != typ:
                            diffs.append(
                                {
                                    "database": db_name,
                                    "table": table_name,
                                    "diff_type": "column_type_mismatch",
                                    "expected": f"{col} {typ}",
                                    "actual": f"{col} {db_cols[col]}",
                                    "reference_db": ref_name,
                                }
                            )
                    for col, typ in db_cols.items():
                        if col not in ref_cols:
                            diffs.append(
                                {
                                    "database": db_name,
                                    "table": table_name,
                                    "diff_type": "extra_column",
                                    "expected": "",
                                    "actual": f"{col} {typ}",
                                    "reference_db": ref_name,
                                }
                            )

    contract_summary: dict[str, Any] = {
        "reference_db": ref_name,
        "databases_compared": len(db_names),
        "unique_tables": len(all_table_names),
        "total_diffs": len(diffs),
        "databases_with_diffs": len({d["database"] for d in diffs}),
    }

    out_dir = group.output_dir / "schema"
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "drift_report.json").write_text(
        json.dumps({"summary": contract_summary, "diffs": diffs}, indent=2, default=str),
        encoding="utf-8",
    )

    csv_path = out_dir / "drift_summary.csv"
    fields = ["database", "table", "diff_type", "expected", "actual", "reference_db"]
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(diffs)

    print(f"Referência: {ref_name}")
    print(f"Bancos comparados: {contract_summary['databases_compared']}")
    print(f"Tabelas únicas: {contract_summary['unique_tables']}")
    print(f"Diferenças: {contract_summary['total_diffs']}")
    print(f"Bancos com drift: {contract_summary['databases_with_diffs']}")
    print(f"Relatório: {csv_path}")
    return 0


def main(argv: list[str] | None = None) -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Detecta drift de schema entre bancos")
    parser.add_argument("--group", default="mereogr")
    parser.add_argument("--reference-db", help="Banco referência (padrão: groups.toml)")
    parser.add_argument(
        "--detailed",
        action="store_true",
        help="Diff coluna a coluna (muito mais lento)",
    )
    args = parser.parse_args(argv)
    try:
        return run_drift(args.group, args.reference_db, detailed=args.detailed)
    except Exception as exc:
        print(f"Erro: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
