"""CLI: uv run python -m mereo_tools <comando>"""

from __future__ import annotations

import sys


def main(argv: list[str] | None = None) -> int:
    args = list(sys.argv[1:] if argv is None else argv)
    if not args or args[0] in ("-h", "--help"):
        print(__doc__)
        print("\nComandos: discover, inventory, schema, drift, teste_query")
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
    if command == "teste_query":
        from mereo_tools.teste_query import main as teste_query_main

        return teste_query_main(rest)

    print(f"Comando desconhecido: {command}", file=sys.stderr)
    print("Comandos: discover, inventory, schema, drift, teste_query")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
