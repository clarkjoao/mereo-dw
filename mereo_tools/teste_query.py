"""Query rápida para testar conexão e latência."""

from __future__ import annotations

import argparse
import sys
import time

from mereo_tools import db
from mereo_tools.config import load_mssql_config
from mereo_tools.db import use_database


def run_teste_query(database: str = "MereoGR-Staging") -> int:
    config = load_mssql_config()
    print(f"Host: {config.host}:{config.port}")
    print(f"User: {config.user}")
    print(f"Banco: {database}")
    print()

    t0 = time.perf_counter()
    conn = db.connect(timeout=30)
    t_connect = time.perf_counter() - t0

    try:
        with use_database(conn, database):
            t1 = time.perf_counter()
            info = db.fetchone(
                conn,
                """
                SELECT
                    DB_NAME() AS database_name,
                    @@SERVERNAME AS server_name,
                    (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0) AS table_count,
                    GETUTCDATE() AS utc_now
                """,
            )
            t_query = time.perf_counter() - t1
    finally:
        conn.close()

    print("OK — conexão funcionando")
    print(f"  connect: {t_connect * 1000:.0f} ms")
    print(f"  query:   {t_query * 1000:.0f} ms")
    print(f"  total:   {(t_connect + t_query) * 1000:.0f} ms")
    print()
    print("Resultado:")
    for key, value in info.items():
        print(f"  {key}: {value}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Teste rápido de conexão SQL Server")
    parser.add_argument(
        "--db",
        default="MereoGR-Staging",
        help="Banco para testar (padrão: MereoGR-Staging)",
    )
    args = parser.parse_args(argv)
    try:
        return run_teste_query(args.db)
    except Exception as exc:
        print(f"Falha: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
