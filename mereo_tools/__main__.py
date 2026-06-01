"""CLI: uv run python -m mereo_tools <comando>"""

from __future__ import annotations

import sys


def main(argv: list[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        print("\nComandos: discover, inventory, inventory-batches, schema, drift, mapping-report, teste_query, seed-sim, clone-sim, backup-local, restore-local")
        print("Exemplo: uv run python -m mereo_tools teste_query --db MereoGR-Staging")
        return 0 if args else 1

    command = args[0]
    rest = args[1:]

    if command == "discover":
        from mereo_tools.discover import main as discover_main

        return discover_main(rest)
    if command == "inventory":
        from mereo_tools.inventory import main as inventory_main

        return inventory_main(rest)
    if command == "schema":
        from mereo_tools.schema_extract import main as schema_main

        return schema_main(rest)
    if command == "drift":
        from mereo_tools.schema_drift import main as drift_main

        return drift_main(rest)
    if command == "mapping-report":
        from mereo_tools.mapping_report import main as mapping_report_main

        return mapping_report_main(rest)
    if command == "teste_query":
        from mereo_tools.teste_query import main as teste_query_main

        return teste_query_main(rest)
    if command == "seed-sim":
        from mereo_tools.seed_sim import main as seed_sim_main

        return seed_sim_main(rest)
    if command == "clone-sim":
        from mereo_tools.clone_sim import main as clone_sim_main

        return clone_sim_main(rest)
    if command == "backup-local":
        from mereo_tools.backup_local import main as backup_local_main

        return backup_local_main(rest)
    if command == "restore-local":
        from mereo_tools.restore_local import main as restore_local_main

        return restore_local_main(rest)
    if command == "inventory-batches":
        from mereo_tools.run_inventory_batches import main as batches_main

        return batches_main(rest)

    print(f"Comando desconhecido: {command}", file=sys.stderr)
    print("Comandos: discover, inventory, inventory-batches, schema, drift, mapping-report, teste_query, seed-sim, clone-sim, backup-local, restore-local")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
