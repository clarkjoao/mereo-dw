"""Extrai DDL (schemas, tabelas, PKs, FKs) a partir de sys.* no SQL Server."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

from mereo_tools import db

SYSTEM_SCHEMAS = frozenset(
    {
        "sys",
        "INFORMATION_SCHEMA",
        "guest",
        "db_owner",
        "db_accessadmin",
        "db_securityadmin",
        "db_ddladmin",
        "db_backupoperator",
        "db_datareader",
        "db_datawriter",
        "db_denydatareader",
        "db_denydatawriter",
    }
)

COLUMNS_SQL = """
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    c.name AS column_name,
    ty.name AS type_name,
    c.max_length,
    c.precision,
    c.scale,
    c.is_nullable,
    c.is_identity,
    ISNULL(ic.seed_value, 0) AS seed_value,
    ISNULL(ic.increment_value, 0) AS increment_value,
    c.is_computed,
    cc.definition AS computed_definition,
    cc.is_persisted AS computed_persisted,
    dc.definition AS default_definition,
    c.column_id,
    CASE WHEN pk_col.column_id IS NOT NULL THEN 1 ELSE 0 END AS is_pk,
    ISNULL(pk_col.key_ordinal, 0) AS pk_ordinal,
    pk_kc.name AS pk_name
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
LEFT JOIN sys.identity_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
LEFT JOIN sys.computed_columns cc ON c.object_id = cc.object_id AND c.column_id = cc.column_id
LEFT JOIN sys.default_constraints dc ON c.default_object_id = dc.object_id
LEFT JOIN sys.indexes pk_i ON t.object_id = pk_i.object_id AND pk_i.is_primary_key = 1
LEFT JOIN sys.key_constraints pk_kc ON pk_i.object_id = pk_kc.parent_object_id AND pk_i.index_id = pk_kc.unique_index_id
LEFT JOIN sys.index_columns pk_col
    ON pk_i.object_id = pk_col.object_id
    AND pk_i.index_id = pk_col.index_id
    AND c.column_id = pk_col.column_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, c.column_id
"""

FOREIGN_KEYS_SQL = """
SELECT
    fk.name AS fk_name,
    ps.name AS parent_schema,
    pt.name AS parent_table,
    pc.name AS parent_column,
    rs.name AS referenced_schema,
    rt.name AS referenced_table,
    rc.name AS referenced_column,
    fkc.constraint_column_id,
    fk.delete_referential_action_desc AS on_delete,
    fk.update_referential_action_desc AS on_update
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables pt ON fkc.parent_object_id = pt.object_id
INNER JOIN sys.schemas ps ON pt.schema_id = ps.schema_id
INNER JOIN sys.tables rt ON fkc.referenced_object_id = rt.object_id
INNER JOIN sys.schemas rs ON rt.schema_id = rs.schema_id
INNER JOIN sys.columns pc
    ON fkc.parent_object_id = pc.object_id AND fkc.parent_column_id = pc.column_id
INNER JOIN sys.columns rc
    ON fkc.referenced_object_id = rc.object_id AND fkc.referenced_column_id = rc.column_id
ORDER BY fk.name, fkc.constraint_column_id
"""


@dataclass
class ColumnDef:
    name: str
    type_name: str
    max_length: int
    precision: int
    scale: int
    is_nullable: bool
    is_identity: bool
    seed_value: int
    increment_value: int
    is_computed: bool
    computed_definition: str | None
    computed_persisted: bool
    default_definition: str | None
    is_pk: bool
    pk_ordinal: int
    column_id: int

    @property
    def is_timestamp(self) -> bool:
        return self.type_name == "timestamp"

    @property
    def computed_without_definition(self) -> bool:
        return self.is_computed and not self.computed_definition

    @property
    def insertable(self) -> bool:
        if self.is_timestamp:
            return False
        if self.is_computed and self.computed_definition:
            return False
        return True


@dataclass
class TableDef:
    schema: str
    name: str
    columns: list[ColumnDef] = field(default_factory=list)
    pk_name: str | None = None
    pk_columns: list[str] = field(default_factory=list)

    @property
    def has_identity(self) -> bool:
        return any(c.is_identity for c in self.columns)

    @property
    def insert_columns(self) -> list[ColumnDef]:
        return [c for c in self.columns if c.insertable]

    @property
    def select_columns(self) -> list[ColumnDef]:
        """Colunas a ler em prod (inclui computed sem definição para copiar valores)."""
        return [
            c
            for c in self.columns
            if not c.is_timestamp and not (c.is_computed and c.computed_definition)
        ]


@dataclass
class ForeignKeyDef:
    name: str
    parent_schema: str
    parent_table: str
    parent_columns: list[str]
    referenced_schema: str
    referenced_table: str
    referenced_columns: list[str]
    on_delete: str
    on_update: str


@dataclass
class DatabaseDdl:
    database: str
    schemas: list[str]
    tables: list[TableDef]
    foreign_keys: list[ForeignKeyDef]


def format_column_type(col: ColumnDef) -> str:
    name = col.type_name
    if name in ("varchar", "nvarchar", "char", "nchar", "varbinary", "binary"):
        length = col.max_length
        if length == -1:
            return f"{name}(max)"
        if name.startswith("n"):
            length = length // 2 if length > 0 else length
        return f"{name}({length})"
    if name in ("decimal", "numeric"):
        return f"{name}({col.precision},{col.scale})"
    if name in ("datetime2", "datetimeoffset", "time"):
        if col.scale is not None and col.scale > 0:
            return f"{name}({col.scale})"
        return name
    return name


def render_create_schema(schema: str) -> str:
    safe = schema.replace("]", "]]")
    return f"IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'{safe}') EXEC(N'CREATE SCHEMA [{safe}]');"


def render_create_table(table: TableDef) -> str:
    col_lines: list[str] = []
    for col in table.columns:
        col_lines.append(f"    {render_column_definition(col)}")

    pk_cols = table.pk_columns
    if pk_cols:
        pk_list = ", ".join(f"[{c}]" for c in pk_cols)
        pk_name = table.pk_name or f"PK_{table.schema}_{table.name}"
        pk_name = pk_name.replace("]", "]]")
        col_lines.append(f"    CONSTRAINT [{pk_name}] PRIMARY KEY CLUSTERED ({pk_list})")

    body = ",\n".join(col_lines)
    schema = table.schema.replace("]", "]]")
    name = table.name.replace("]", "]]")
    return (
        f"IF OBJECT_ID(N'[{schema}].[{name}]', N'U') IS NULL\n"
        f"CREATE TABLE [{schema}].[{name}] (\n{body}\n);"
    )


def render_column_definition(col: ColumnDef) -> str:
    parts = [f"[{col.name}]", format_column_type(col)]
    if col.is_computed and col.computed_definition:
        parts.append(f"AS {col.computed_definition}")
        if col.computed_persisted:
            parts.append("PERSISTED")
        return " ".join(parts)
    if col.is_computed and not col.computed_definition:
        # MEREO_* read-only pode ocultar sys.computed_columns.definition — coluna regular no sim
        parts.append("NULL")
        return " ".join(parts)
    if col.is_identity:
        seed = int(col.seed_value or 1)
        inc = int(col.increment_value or 1)
        parts.append(f"IDENTITY({seed},{inc})")
    if not col.is_nullable:
        parts.append("NOT NULL")
    if col.default_definition and not col.is_identity:
        parts.append(f"DEFAULT {col.default_definition}")
    return " ".join(parts)


def render_add_foreign_key(fk: ForeignKeyDef) -> str:
    parent_cols = ", ".join(f"[{c}]" for c in fk.parent_columns)
    ref_cols = ", ".join(f"[{c}]" for c in fk.referenced_columns)
    fk_name = fk.name.replace("]", "]]")
    ps = fk.parent_schema.replace("]", "]]")
    pt = fk.parent_table.replace("]", "]]")
    rs = fk.referenced_schema.replace("]", "]]")
    rt = fk.referenced_table.replace("]", "]]")
    on_delete = ""
    on_update = ""
    if fk.on_delete and fk.on_delete != "NO_ACTION":
        on_delete = f" ON DELETE {fk.on_delete.replace('_', ' ')}"
    if fk.on_update and fk.on_update != "NO_ACTION":
        on_update = f" ON UPDATE {fk.on_update.replace('_', ' ')}"
    return (
        f"IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'{fk_name}')\n"
        f"ALTER TABLE [{ps}].[{pt}] WITH NOCHECK ADD CONSTRAINT [{fk_name}] "
        f"FOREIGN KEY ({parent_cols}) REFERENCES [{rs}].[{rt}] ({ref_cols})"
        f"{on_delete}{on_update};"
    )


def _as_int(value: Any, default: int = 0) -> int:
    if value is None:
        return default
    if isinstance(value, (bytes, bytearray)):
        return default if not value else int.from_bytes(value[:8], "little", signed=False) or default
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _build_tables(rows: list[dict[str, Any]]) -> list[TableDef]:
    tables: dict[tuple[str, str], TableDef] = {}
    for row in rows:
        key = (row["schema_name"], row["table_name"])
        if key not in tables:
            tables[key] = TableDef(schema=row["schema_name"], name=row["table_name"])
        col = ColumnDef(
            name=row["column_name"],
            type_name=row["type_name"],
            max_length=int(row["max_length"] or 0),
            precision=int(row["precision"] or 0),
            scale=int(row["scale"] or 0),
            is_nullable=bool(row["is_nullable"]),
            is_identity=bool(row["is_identity"]),
            seed_value=_as_int(row["seed_value"], 1),
            increment_value=_as_int(row["increment_value"], 1),
            is_computed=bool(row["is_computed"]),
            computed_definition=row.get("computed_definition"),
            computed_persisted=bool(row.get("computed_persisted")),
            default_definition=row.get("default_definition"),
            is_pk=bool(row["is_pk"]),
            pk_ordinal=int(row["pk_ordinal"] or 0),
            column_id=int(row["column_id"]),
        )
        tables[key].columns.append(col)
        if col.is_pk and row.get("pk_name"):
            tables[key].pk_name = row["pk_name"]

    result = sorted(tables.values(), key=lambda t: (t.schema, t.name))
    for table in result:
        table.pk_columns = [
            c.name
            for c in sorted(
                [c for c in table.columns if c.is_pk],
                key=lambda c: c.pk_ordinal,
            )
        ]
    return result


def _build_foreign_keys(rows: list[dict[str, Any]]) -> list[ForeignKeyDef]:
    grouped: dict[str, ForeignKeyDef] = {}
    for row in rows:
        name = row["fk_name"]
        if name not in grouped:
            grouped[name] = ForeignKeyDef(
                name=name,
                parent_schema=row["parent_schema"],
                parent_table=row["parent_table"],
                parent_columns=[],
                referenced_schema=row["referenced_schema"],
                referenced_table=row["referenced_table"],
                referenced_columns=[],
                on_delete=row["on_delete"],
                on_update=row["on_update"],
            )
        grouped[name].parent_columns.append(row["parent_column"])
        grouped[name].referenced_columns.append(row["referenced_column"])
    return sorted(grouped.values(), key=lambda fk: fk.name)


def extract_database_ddl(conn, database: str) -> DatabaseDdl:
    with db.use_database(conn, database):
        col_rows = db.fetchall(conn, COLUMNS_SQL)
        fk_rows = db.fetchall(conn, FOREIGN_KEYS_SQL)
        schema_rows = db.fetchall(
            conn,
            """
            SELECT name FROM sys.schemas
            WHERE name NOT IN ({placeholders})
            ORDER BY name
            """.format(
                placeholders=", ".join(f"N'{s}'" for s in sorted(SYSTEM_SCHEMAS))
            ),
        )

    schemas = [r["name"] for r in schema_rows]
    tables = _build_tables(col_rows)
    foreign_keys = _build_foreign_keys(fk_rows)
    return DatabaseDdl(database=database, schemas=schemas, tables=tables, foreign_keys=foreign_keys)
