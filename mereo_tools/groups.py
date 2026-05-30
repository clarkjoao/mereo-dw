from __future__ import annotations

import fnmatch
import tomllib
from dataclasses import dataclass
from pathlib import Path

from mereo_tools.config import ROOT

GROUPS_FILE = Path(__file__).resolve().parent / "groups.toml"


@dataclass(frozen=True)
class DatabaseGroup:
    name: str
    pattern: str
    reference_db: str
    exclude: tuple[str, ...] = ()

    @property
    def output_dir(self) -> Path:
        return ROOT / "output" / "groups" / self.name

    @property
    def databases_file(self) -> Path:
        return self.output_dir / "databases.json"

    def sql_like_pattern(self) -> str:
        return self.pattern.replace("*", "%")

    def matches(self, database_name: str) -> bool:
        if not fnmatch.fnmatch(database_name, self.pattern):
            return False
        return not any(fnmatch.fnmatch(database_name, ex) for ex in self.exclude)


def load_groups(path: Path | None = None) -> dict[str, DatabaseGroup]:
    config_path = path or GROUPS_FILE
    data = tomllib.loads(config_path.read_text(encoding="utf-8"))
    groups: dict[str, DatabaseGroup] = {}
    for name, section in data.items():
        exclude = section.get("exclude", [])
        if isinstance(exclude, str):
            exclude = [exclude]
        groups[name] = DatabaseGroup(
            name=name,
            pattern=section["pattern"],
            reference_db=section.get("reference_db", ""),
            exclude=tuple(exclude),
        )
    return groups


def get_group(name: str, path: Path | None = None) -> DatabaseGroup:
    groups = load_groups(path)
    if name not in groups:
        available = ", ".join(sorted(groups))
        raise KeyError(f"Grupo '{name}' não encontrado. Disponíveis: {available}")
    return groups[name]
