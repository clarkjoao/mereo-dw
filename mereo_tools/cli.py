from __future__ import annotations

import argparse
from pathlib import Path

from mereo_tools.config import SourceKind


def base_parser(description: str) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "--group",
        default="mereogr",
        help="Grupo de bancos definido em mereo_tools/groups.toml (padrão: mereogr)",
    )
    parser.add_argument(
        "--source",
        choices=("mereo", "mssql"),
        default="mereo",
        help="Origem da conexão: mereo=cliente real (MEREO_*), mssql=sim/prod (MSSQL_*)",
    )
    parser.add_argument(
        "--db",
        action="append",
        dest="databases",
        metavar="DB",
        help="Processar apenas este banco (repita para vários)",
    )
    parser.add_argument(
        "--sample",
        action="store_true",
        help="Usar mapping_sample do groups.toml em vez do fleet inteiro",
    )
    parser.add_argument("--limit", type=int, help="Limitar quantidade de bancos")
    parser.add_argument("--resume", action="store_true", help="Pular bancos já processados")
    parser.add_argument(
        "--pause",
        type=float,
        default=1.0,
        help="Segundos de pausa entre bancos (padrão: 1.0; use 0 para desligar)",
    )
    return parser


def group_output_dir(group_name: str) -> Path:
    from mereo_tools.groups import get_group

    return get_group(group_name).output_dir


def resolve_source(args: argparse.Namespace) -> SourceKind:
    return args.source
