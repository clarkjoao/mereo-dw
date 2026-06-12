#!/usr/bin/env python3
"""Audita silver existente vs classificação dimensional (Spec 1) — matriz de reuso."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Any

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
SILVER_DOMAINS = REPO_ROOT / "analytics" / "catalog" / "silver_domains.yaml"
CLASSIFICATION = REPO_ROOT / "analytics" / "catalog" / "client_table_classification.csv"
DIM_FACT = REPO_ROOT / "analytics" / "catalog" / "dim_fact_candidates.yaml"
OUT_CSV = REPO_ROOT / "analytics" / "catalog" / "silver_reuse_matrix.csv"

ROLE_TO_ACTION = {
    "DIM": "REUSE_AS_DIM",
    "FACT": "REUSE_AS_FACT",
    "BRIDGE": "REUSE_AS_BRIDGE",
    "REF": "REUSE_AS_DIM",
    "EXCLUDE": "DEPRECATE",
    "DEFER": "REFINE",
}


def audit() -> dict[str, Any]:
    silver = yaml.safe_load(SILVER_DOMAINS.read_text(encoding="utf-8"))
    class_by_bronze: dict[str, dict[str, str]] = {}
    if CLASSIFICATION.exists():
        with CLASSIFICATION.open(encoding="utf-8") as f:
            for row in csv.DictReader(f):
                class_by_bronze[row["bronze"]] = row

    rows_out: list[dict[str, Any]] = []
    action_counts: dict[str, int] = {}

    for dom in silver.get("domains", []):
        domain_id = dom["id"]
        for ent in dom.get("entities", []):
            bronze = ent["bronze"]
            cls = class_by_bronze.get(bronze, {})
            role = cls.get("dimensional_role", "UNKNOWN")
            action = ROLE_TO_ACTION.get(role, "REFINE")
            if ent.get("silver_table") == "valor_matriz":
                action = "REUSE_AS_FACT"
            if role == "EXCLUDE":
                action = "DEPRECATE"
            action_counts[action] = action_counts.get(action, 0) + 1

            rows_out.append({
                "silver_domain": domain_id,
                "silver_table": ent["silver_table"],
                "bronze": bronze,
                "erp_key": cls.get("erp_key", ent.get("erp", {}).get("schema", "") + "." + ent.get("erp", {}).get("table", "")),
                "dimensional_role": role,
                "reuse_action": action,
                "snowflake_candidate": cls.get("snowflake_candidate", ""),
                "grain": cls.get("grain", ""),
                "row_count_afya": cls.get("row_count_afya", ""),
                "row_count_allos": cls.get("row_count_allos", ""),
                "status": ent.get("status", ""),
                "wave": ent.get("wave", ""),
                "notes": (ent.get("notes") or "")[:120],
            })

    with OUT_CSV.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows_out[0].keys()))
        writer.writeheader()
        writer.writerows(rows_out)

    direct_reuse = sum(
        1 for r in rows_out if r["reuse_action"] in ("REUSE_AS_DIM", "REUSE_AS_FACT", "REUSE_AS_BRIDGE")
    )
    pct = round(100 * direct_reuse / len(rows_out), 1) if rows_out else 0

    gold_candidates = []
    if DIM_FACT.exists():
        df = yaml.safe_load(DIM_FACT.read_text(encoding="utf-8"))
        gold_candidates = df.get("priority_facts", [])

    return {
        "silver_entities": len(rows_out),
        "direct_reuse_count": direct_reuse,
        "direct_reuse_pct": pct,
        "action_counts": action_counts,
        "gold_priority": gold_candidates,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Audita reuso da silver para modelo dimensional")
    parser.parse_args(argv)
    if not CLASSIFICATION.exists():
        print("Execute explore_client_dimensions.py primeiro.", flush=True)
        return 1
    stats = audit()
    print(f"Silver entities: {stats['silver_entities']}")
    print(f"Reuso direto: {stats['direct_reuse_count']} ({stats['direct_reuse_pct']}%)")
    for action, n in sorted(stats["action_counts"].items()):
        print(f"  {action}: {n}")
    print(f"CSV: {OUT_CSV}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
