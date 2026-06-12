#!/usr/bin/env python3
"""Modelo compartilhado para os geradores DBML da spec 001-snowflake-dbml-model.

Carrega e cruza:
  1. specs/001-snowflake-dbml-model/contracts/erp_mapping_matrix.csv  (616 linhas)
  2. output/groups/mereogr/schema/tables/MereoGR-Afya.json            (colunas/tipos/PKs)
  3. analytics/catalog/bronze_relationship_graph.json                 (709 arestas FK)
  4. specs/001-snowflake-dbml-model/contracts/mereo_snowflake_dimensional.sql
     (52 blocos curados — staging/edw/mart verbatim; raw vira override de @note/@fk)

Consumido por generate_dbml_stubs.py (spec 001) e generate_edw_dbt_models.py (spec 002).
"""
from __future__ import annotations

import csv
import json
import re
from dataclasses import dataclass, field
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
MATRIX_CSV = REPO_ROOT / "specs/001-snowflake-dbml-model/contracts/erp_mapping_matrix.csv"
SCHEMA_JSON = REPO_ROOT / "output/groups/mereogr/schema/tables/MereoGR-Afya.json"
FK_GRAPH_JSON = REPO_ROOT / "analytics/catalog/bronze_relationship_graph.json"
SPINE_SQL = REPO_ROOT / "specs/001-snowflake-dbml-model/contracts/mereo_snowflake_dimensional.sql"

# ---------------------------------------------------------------------------
# Tipos MSSQL -> Spark/Delta (vocabulário do spine curado)
# ---------------------------------------------------------------------------

_TYPE_MAP = {
    "int": "INT",
    "smallint": "INT",
    "tinyint": "INT",
    "bit": "INT",
    "bigint": "BIGINT",
    "varchar": "STRING",
    "nvarchar": "STRING",
    "char": "STRING",
    "nchar": "STRING",
    "text": "STRING",
    "ntext": "STRING",
    "uniqueidentifier": "STRING",
    "xml": "STRING",
    "sysname": "STRING",
    "datetime": "TIMESTAMP",
    "datetime2": "TIMESTAMP",
    "smalldatetime": "TIMESTAMP",
    "datetimeoffset": "TIMESTAMP",
    "date": "DATE",
    "time": "STRING",
    "float": "DOUBLE",
    "real": "DOUBLE",
    "varbinary": "BINARY",
    "binary": "BINARY",
    "image": "BINARY",
    "timestamp": "BINARY",  # rowversion
    "rowversion": "BINARY",
}

_DECIMAL_TYPES = {"decimal", "numeric"}

_TYPE_RE = re.compile(r"^([a-z0-9_]+)\s*(?:\(\s*([^)]*)\s*\))?$")


def map_mssql_type(mssql_type: str, gaps: list[str] | None = None, context: str = "") -> str:
    """'decimal(28,8)' -> 'DECIMAL(28,8)'; 'nvarchar(max)' -> 'STRING'; desconhecido -> STRING + gap."""
    m = _TYPE_RE.match(mssql_type.strip().lower())
    if not m:
        if gaps is not None:
            gaps.append(f"TYPE: tipo não-parseável '{mssql_type}' em {context} -> STRING")
        return "STRING"
    base, args = m.group(1), m.group(2)
    if base in _DECIMAL_TYPES:
        return f"DECIMAL({args.replace(' ', '')})" if args else "DECIMAL(18,4)"
    if base == "money":
        return "DECIMAL(19,4)"
    if base == "smallmoney":
        return "DECIMAL(10,4)"
    mapped = _TYPE_MAP.get(base)
    if mapped is None:
        if gaps is not None:
            gaps.append(f"TYPE: tipo desconhecido '{mssql_type}' em {context} -> STRING")
        return "STRING"
    return mapped


# ---------------------------------------------------------------------------
# snake_case determinístico (corrige o bug do silver legado: i_d__m_e_t_a)
# ---------------------------------------------------------------------------

_CAMEL_RE1 = re.compile(r"(.)([A-Z][a-z]+)")
_CAMEL_RE2 = re.compile(r"([a-z0-9])([A-Z])")


def snake_case(name: str) -> str:
    """ID->id, ID_META->id_meta, JobPositionId->job_position_id, COD_AREA->cod_area."""
    s = name.strip()
    # tudo-maiúsculas (com ou sem underscore) -> só baixar
    if s.upper() == s:
        return s.lower()
    s = _CAMEL_RE1.sub(r"\1_\2", s)
    s = _CAMEL_RE2.sub(r"\1_\2", s)
    return re.sub(r"__+", "_", s).lower()


# ---------------------------------------------------------------------------
# Dataclasses
# ---------------------------------------------------------------------------

@dataclass
class MatrixRow:
    erp_key: str
    bronze_table: str
    domain: str
    dimensional_role: str  # DIM | FACT | BRIDGE | REF | DEFER | EXCLUDE
    layer_path: str
    raw_object: str
    staging_object: str
    edw_object: str
    mart_object: str
    localdrawdb_layer: str
    localdrawdb_group: str
    note: str

    @property
    def staging_name(self) -> str:
        """'staging.stg_x' -> 'stg_x' ('' se vazio)."""
        return self.staging_object.split(".", 1)[1] if "." in self.staging_object else self.staging_object

    @property
    def edw_name(self) -> str:
        return self.edw_object.split(".", 1)[1] if "." in self.edw_object else self.edw_object

    @property
    def has_staging(self) -> bool:
        """DEFER reserva staging_object na matriz mas NÃO gera tabela staging."""
        return bool(self.staging_object) and self.dimensional_role in ("DIM", "FACT", "BRIDGE", "REF")


@dataclass
class ColumnSchema:
    name: str
    mssql_type: str
    nullable: bool
    is_pk: bool


@dataclass
class TableSchema:
    schema: str
    table: str
    columns: list[ColumnSchema]
    pk_columns: list[str]

    @property
    def bronze_name(self) -> str:
        # mesma regra de generate_silver_batch.py
        return self.table if self.schema == "cdc" else f"{self.schema}__{self.table}"


@dataclass
class FkEdge:
    fk_name: str
    from_bronze: str
    from_columns: list[str]
    to_bronze: str
    to_columns: list[str]

    @property
    def is_degenerate_self(self) -> bool:
        return (
            self.from_bronze == self.to_bronze
            and [c.upper() for c in self.from_columns] == [c.upper() for c in self.to_columns]
        )


@dataclass
class CuratedBlock:
    schema: str  # raw | staging | edw | mart
    name: str
    header_lines: list[str]  # linhas '-- @...' verbatim
    body: str  # bloco CREATE TABLE inteiro verbatim (sem o header)

    @property
    def qualified(self) -> str:
        return f"{self.schema}.{self.name}"

    @property
    def text(self) -> str:
        return "\n".join(self.header_lines + [self.body])

    def annotation(self, key: str) -> list[str]:
        """Linhas de uma anotação específica, ex.: annotation('fk')."""
        pat = re.compile(rf"^--\s*@{key}\s*:", re.IGNORECASE)
        return [ln for ln in self.header_lines if pat.match(ln)]


@dataclass
class Model:
    rows: list[MatrixRow]
    schemas: dict[str, TableSchema]  # key = bronze_name (ex. dbo__COLABORADOR)
    edges: list[FkEdge]  # já sem self-edges degenerados
    curated: dict[str, CuratedBlock]  # key = qualified (ex. edw.dim_employee)
    gaps: list[str] = field(default_factory=list)

    def row_by_bronze(self) -> dict[str, MatrixRow]:
        return {r.bronze_table: r for r in self.rows}

    def edges_from(self, bronze: str) -> list[FkEdge]:
        return [e for e in self.edges if e.from_bronze == bronze]


# ---------------------------------------------------------------------------
# Loaders
# ---------------------------------------------------------------------------

def load_matrix(path: Path = MATRIX_CSV) -> list[MatrixRow]:
    with path.open(newline="", encoding="utf-8") as f:
        return [MatrixRow(**{k: (v or "").strip() for k, v in row.items()}) for row in csv.DictReader(f)]


def load_schemas(path: Path = SCHEMA_JSON) -> dict[str, TableSchema]:
    data = json.loads(path.read_text(encoding="utf-8"))
    out: dict[str, TableSchema] = {}
    for t in data["tables"]:
        ts = TableSchema(
            schema=t["schema"],
            table=t["table"],
            columns=[
                ColumnSchema(
                    name=c["name"],
                    mssql_type=c["type"],
                    nullable=bool(c.get("nullable", True)),
                    is_pk=bool(c.get("is_pk", False)),
                )
                for c in t["columns"]
            ],
            pk_columns=list(t.get("pk_columns") or []),
        )
        out[ts.bronze_name] = ts
    return out


def load_edges(path: Path = FK_GRAPH_JSON) -> list[FkEdge]:
    data = json.loads(path.read_text(encoding="utf-8"))
    raw_edges = data.get("edges", data) if isinstance(data, dict) else data
    edges = [
        FkEdge(
            fk_name=e.get("fk_name", ""),
            from_bronze=e["from_bronze"],
            from_columns=list(e["from_columns"]),
            to_bronze=e["to_bronze"],
            to_columns=list(e["to_columns"]),
        )
        for e in raw_edges
    ]
    return [e for e in edges if not e.is_degenerate_self]


_CREATE_RE = re.compile(r"^CREATE TABLE IF NOT EXISTS ([a-z]+)\.([A-Za-z0-9_]+)\s*\($")


def load_spine(path: Path = SPINE_SQL) -> dict[str, CuratedBlock]:
    """Indexa os blocos curados do spine por 'schema.nome'."""
    blocks: dict[str, CuratedBlock] = {}
    header: list[str] = []
    body_lines: list[str] = []
    current: tuple[str, str] | None = None
    for line in path.read_text(encoding="utf-8").splitlines():
        if current is not None:
            body_lines.append(line)
            if line.rstrip().endswith(";"):
                schema, name = current
                blocks[f"{schema}.{name}"] = CuratedBlock(
                    schema=schema, name=name, header_lines=header, body="\n".join(body_lines)
                )
                current, header, body_lines = None, [], []
            continue
        m = _CREATE_RE.match(line.strip())
        if m:
            current = (m.group(1), m.group(2))
            body_lines = [line]
            continue
        stripped = line.strip()
        if stripped.startswith("-- @"):
            header.append(stripped)
        elif not stripped.startswith("--") and stripped:
            header = []  # linha solta (INSERT etc.) quebra o acúmulo de header
        elif not stripped:
            header = []  # linha em branco separa blocos
    return blocks


def load_model() -> Model:
    return Model(
        rows=load_matrix(),
        schemas=load_schemas(),
        edges=load_edges(),
        curated=load_spine(),
    )


if __name__ == "__main__":
    m = load_model()
    by_role: dict[str, int] = {}
    for r in m.rows:
        by_role[r.dimensional_role] = by_role.get(r.dimensional_role, 0) + 1
    by_layer: dict[str, int] = {}
    for b in m.curated.values():
        by_layer[b.schema] = by_layer.get(b.schema, 0) + 1
    print(f"matrix rows: {len(m.rows)}  roles: {by_role}")
    print(f"schemas: {len(m.schemas)} tables")
    print(f"fk edges (sem self-degenerados): {len(m.edges)}")
    print(f"curated blocks: {len(m.curated)}  por layer: {by_layer}")
