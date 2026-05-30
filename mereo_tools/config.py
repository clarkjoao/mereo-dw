from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class MssqlConfig:
    host: str
    port: int
    user: str
    password: str

    @property
    def server(self) -> str:
        return self.host


def load_mssql_config(env_path: Path | None = None) -> MssqlConfig:
    """Carrega credenciais do .env (MYSQL_* ou MSSQL_* — o que estiver definido)."""
    path = env_path or ROOT / ".env"
    if not path.exists():
        raise FileNotFoundError(f".env não encontrado em {path}")

    # .env tem prioridade sobre variáveis já exportadas no shell
    load_dotenv(path, override=True)

    def pick(*keys: str) -> str | None:
        for key in keys:
            value = os.getenv(key)
            if value is not None and value != "":
                return value
        return None

    # Aceita os dois prefixos; usa o primeiro encontrado no .env
    host = pick("MYSQL_HOST", "MSSQL_HOST")
    port = pick("MYSQL_PORT", "MSSQL_PORT")
    user = pick("MYSQL_USER", "MSSQL_USER")
    password = pick("MYSQL_PASSWORD", "MSSQL_PASSWORD")

    missing = [label for label, value in [("HOST", host), ("PORT", port), ("USER", user), ("PASSWORD", password)] if not value]
    if missing:
        raise ValueError(
            "Variáveis ausentes no .env. Defina MYSQL_HOST/PORT/USER/PASSWORD ou MSSQL_HOST/PORT/USER/PASSWORD"
        )

    return MssqlConfig(
        host=host,
        port=int(port),
        user=user,
        password=password,
    )
