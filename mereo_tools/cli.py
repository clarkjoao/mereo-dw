from __future__ import annotations

import argparse
from pathlib import Path


def base_parser(description: str) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "--group",
        default="mereogr",
        help="Grupo de bancos definido em mereo_tools/groups.toml (padrão: mereogr)",
    )
    parser.add_argument("--db", help="Processar apenas este banco")
    parser.add_argument("--limit", type=int, help="Limitar quantidade de bancos")
    parser.add_argument("--resume", action="store_true", help="Pular bancos já processados")
    return parser


def group_output_dir(group_name: str) -> Path:
    from mereo_tools.groups import get_group

    return get_group(group_name).output_dir
