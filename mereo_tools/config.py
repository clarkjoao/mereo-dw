from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[1]

SourceKind = Literal["mereo", "mssql"]


@dataclass(frozen=True)
class MssqlConfig:
    host: str
    port: int
    user: str
    password: str
    source: SourceKind = "mssql"

    @property
    def server(self) -> str:
        return self.host


def _ensure_env(env_path: Path | None = None) -> Path:
    path = env_path or ROOT / ".env"
    if not path.exists():
        raise FileNotFoundError(f".env não encontrado em {path}")
    load_dotenv(path, override=False)
    return path


def _load_from_prefix(prefix: str, *, source: SourceKind, env_path: Path | None = None) -> MssqlConfig:
    _ensure_env(env_path)

    def get(suffix: str) -> str | None:
        value = os.getenv(f"{prefix}_{suffix}")
        return value if value not in (None, "") else None

    host = get("HOST")
    port = get("PORT")
    user = get("USER")
    password = get("PASSWORD")

    missing = [label for label, value in [("HOST", host), ("PORT", port), ("USER", user), ("PASSWORD", password)] if not value]
    if missing:
        raise ValueError(f"Variáveis ausentes no .env para {prefix}_*: {', '.join(missing)}")

    return MssqlConfig(
        host=host,
        port=int(port),
        user=user,
        password=password,
        source=source,
    )


def load_mereo_config(env_path: Path | None = None) -> MssqlConfig:
    """Cliente real — somente dev local (MEREO_*)."""
    return _load_from_prefix("MEREO", source="mereo", env_path=env_path)


def load_mssql_config(env_path: Path | None = None) -> MssqlConfig:
    """Simulador (dev) ou cliente real (prod via secrets K8s) — MSSQL_* ou MYSQL_*."""
    _ensure_env(env_path)

    def pick(*keys: str) -> str | None:
        for key in keys:
            value = os.getenv(key)
            if value is not None and value != "":
                return value
        return None

    host = pick("MYSQL_HOST", "MSSQL_HOST")
    port = pick("MYSQL_PORT", "MSSQL_PORT")
    user = pick("MYSQL_USER", "MSSQL_USER")
    password = pick("MYSQL_PASSWORD", "MSSQL_PASSWORD")

    missing = [label for label, value in [("HOST", host), ("PORT", port), ("USER", user), ("PASSWORD", password)] if not value]
    if missing:
        raise ValueError(
            "Variáveis ausentes no .env. Defina MSSQL_HOST/PORT/USER/PASSWORD (ou MYSQL_*)"
        )

    return MssqlConfig(
        host=host,
        port=int(port),
        user=user,
        password=password,
        source="mssql",
    )


def load_config(source: SourceKind, env_path: Path | None = None) -> MssqlConfig:
    if source == "mereo":
        return load_mereo_config(env_path)
    return load_mssql_config(env_path)
