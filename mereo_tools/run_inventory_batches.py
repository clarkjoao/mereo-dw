"""Roda inventory em lotes pequenos (menos carga no cliente, retomável)."""

from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def remaining_databases(group_name: str) -> list[str]:
    from mereo_tools.groups import get_group

    group = get_group(group_name)
    rows = json.loads(group.databases_file.read_text(encoding="utf-8"))
    done = {
        p.name
        for p in (group.output_dir / "databases").iterdir()
        if (p / "meta.json").exists()
    }
    return [r["name"] for r in rows if r.get("state_desc") == "ONLINE" and r["name"] not in done]


def main(argv: list[str] | None = None) -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Inventory em lotes com pausa entre bancos e lotes")
    parser.add_argument("--group", default="mereogr")
    parser.add_argument("--batch-size", type=int, default=15)
    parser.add_argument("--pause", type=float, default=2.0)
    parser.add_argument("--batch-pause", type=float, default=5.0)
    parser.add_argument("--max-batches", type=int, default=0, help="0 = até acabar")
    args = parser.parse_args(argv)

    batches_run = 0
    while True:
        pending = remaining_databases(args.group)
        if not pending:
            print("Inventory completo.")
            return 0
        if args.max_batches and batches_run >= args.max_batches:
            print(f"Pausado — {len(pending)} bancos restantes.")
            return 0

        batch = pending[: args.batch_size]
        batches_run += 1
        print(f"\n=== Lote {batches_run}: {len(batch)} banco(s), {len(pending)} restantes ===")
        cmd = [
            "uv",
            "run",
            "python",
            "-m",
            "mereo_tools",
            "inventory",
            "--source",
            "mereo",
            "--pause",
            str(args.pause),
            *sum([["--db", db] for db in batch], []),
        ]
        result = subprocess.run(cmd, cwd=ROOT)
        if result.returncode != 0:
            print(f"Lote {batches_run} falhou (exit {result.returncode}). Retome depois.")
            return result.returncode
        if pending[args.batch_size :]:
            time.sleep(args.batch_pause)


if __name__ == "__main__":
    raise SystemExit(main())
