from __future__ import annotations

from contextlib import contextmanager
from typing import Any, Iterator

import pymssql

from mereo_tools.config import MssqlConfig, load_mssql_config


def connect(config: MssqlConfig | None = None, *, timeout: int = 300) -> pymssql.Connection:
    cfg = config or load_mssql_config()
    return pymssql.connect(
        server=cfg.server,
        port=cfg.port,
        user=cfg.user,
        password=cfg.password,
        database="master",
        login_timeout=30,
        timeout=timeout,
        as_dict=True,
    )


def fetchall(conn: pymssql.Connection, sql: str, params: tuple | None = None) -> list[dict[str, Any]]:
    cur = conn.cursor()
    cur.execute(sql, params or ())
    rows = cur.fetchall()
    return list(rows) if rows else []


def fetchone(conn: pymssql.Connection, sql: str, params: tuple | None = None) -> dict[str, Any] | None:
    rows = fetchall(conn, sql, params)
    return rows[0] if rows else None


@contextmanager
def use_database(conn: pymssql.Connection, database: str) -> Iterator[None]:
    safe = database.replace("]", "]]")
    cur = conn.cursor()
    cur.execute(f"USE [{safe}]")
    yield
