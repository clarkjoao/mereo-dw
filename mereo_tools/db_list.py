"""Resolve lista de bancos para inventory/schema."""

from __future__ import annotations

import json

from mereo_tools.groups import DatabaseGroup


def load_database_list(
    group: DatabaseGroup,
    *,
    databases: list[str] | None = None,
    use_sample: bool = False,
    limit: int | None = None,
    source: str = "mereo",
) -> list[str]:
    if databases:
        names = list(databases)
    elif use_sample and group.mapping_sample:
        names = list(group.mapping_sample)
    elif group.databases_file.exists():
        rows = json.loads(group.databases_file.read_text(encoding="utf-8"))
        names = [r["name"] for r in rows if r.get("state_desc") == "ONLINE"]
    else:
        from mereo_tools.discover import discover_databases

        rows = discover_databases(group, source=source)
        names = [r["name"] for r in rows if r.get("state_desc") == "ONLINE"]

    if limit:
        names = names[:limit]
    return names
