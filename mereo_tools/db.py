from __future__ import annotations

import time
from contextlib import contextmanager
from typing import Any, Iterator

import pymssql

from mereo_tools.config import MssqlConfig, SourceKind, load_config

# Timeouts conservadores para o cliente real (MEREO_*)
Mereo_DEFAULTS = {"login_timeout": 15, "timeout": 120}
# Simulador / prod via MSSQL_* — mais folga
MSSQL_DEFAULTS = {"login_timeout": 30, "timeout": 120}


def connect(
    config: MssqlConfig | None = None,
    *,
    source: SourceKind = "mssql",
    timeout: int | None = None,
    login_timeout: int | None = None,
) -> pymssql.Connection:
    cfg = config or load_config(source)
    defaults = Mereo_DEFAULTS if cfg.source == "mereo" else MSSQL_DEFAULTS
    return pymssql.connect(
        server=cfg.server,
        port=cfg.port,
        user=cfg.user,
        password=cfg.password,
        database="master",
        login_timeout=login_timeout if login_timeout is not None else defaults["login_timeout"],
        timeout=timeout if timeout is not None else defaults["timeout"],
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


def pause_between_databases(seconds: float) -> None:
    if seconds > 0:
        time.sleep(seconds)
