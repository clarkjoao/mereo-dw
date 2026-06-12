#!/usr/bin/env python3
"""Valida specs/001-snowflake-dbml-model/contracts/mereo_snowflake_full.sql.

Checks (exit != 0 em qualquer falha):
  1. Contagens por camada derivadas da matriz em runtime (raw/staging/edw/mart/pipeline)
  2. Todo objeto da matriz aparece exatamente 1x; nenhum extra
  3. Nenhum bloco edw com `@origen: raw.*`; mart só com `@origen` edw.*
  4. Todo `@map <- schema.tabela.coluna` resolve para coluna existente no arquivo
  5. Todo `@fk: col -> schema.tabela.coluna` resolve para coluna existente no arquivo
  6. Blocos curados staging/edw/mart do spine presentes verbatim (corpo idêntico)

Uso: python3 analytics/catalog/validate_dbml_full.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from dbml_model import REPO_ROOT, load_model  # noqa: E402

FULL_SQL = REPO_ROOT / "specs/001-snowflake-dbml-model/contracts/mereo_snowflake_full.sql"

CREATE_RE = re.compile(r"^CREATE TABLE IF NOT EXISTS ([a-z]+)\.([A-Za-z0-9_]+)\s*\($")
COL_RE = re.compile(r"^\s{2}([A-Za-z_][A-Za-z0-9_]*)\s+[A-Z]")
MAP_RE = re.compile(r"--\s*@map\s*<-\s*([A-Za-z0-9_.]+)")
FK_RE = re.compile(r"^--\s*@fk\s*:\s*(\S+)\s*->\s*([A-Za-z0-9_.]+)\.([A-Za-z_][A-Za-z0-9_]*)$")
ORIGEN_RE = re.compile(r"^--\s*@origen\s*:\s*(.+)$")


def parse_full(text: str):
    """-> tables: {qualified: set(colunas)}, blocks: [(qualified, header_lines, body_lines)]"""
    tables: dict[str, set[str]] = {}
    blocks: list[tuple[str, list[str], list[str]]] = []
    header: list[str] = []
    current: str | None = None
    body: list[str] = []
    for line in text.splitlines():
        if current is not None:
            body.append(line)
            cm = COL_RE.match(line)
            if cm and cm.group(1) not in ("PRIMARY",):
                tables[current].add(cm.group(1).lower())
            if line.rstrip().endswith(";"):
                blocks.append((current, header, body))
                current, header, body = None, [], []
            continue
        m = CREATE_RE.match(line.strip())
        if m:
            current = f"{m.group(1)}.{m.group(2)}"
            tables[current] = set()
            body = [line]
            continue
        s = line.strip()
        if s.startswith("-- @"):
            header.append(s)
        elif not s.startswith("--") or not s:
            if not s.startswith("--"):
                header = []
    return tables, blocks


def main() -> int:
    errors: list[str] = []
    m = load_model()
    text = FULL_SQL.read_text(encoding="utf-8")
    tables, blocks = parse_full(text)

    # 1+2. contagens e presença exata, derivadas da matriz
    expected: dict[str, set[str]] = {"raw": set(), "staging": set(), "edw": set(), "mart": set(), "pipeline": set()}
    for r in m.rows:
        expected["raw"].add(f"raw.{r.bronze_table}")
        if r.has_staging:
            expected["staging"].add(r.staging_object)
        if r.edw_object:
            expected["edw"].add(r.edw_object)
    for q, b in m.curated.items():
        if b.schema == "mart":
            expected["mart"].add(q)
    expected["pipeline"].add("pipeline.schema_drift_log")

    actual: dict[str, set[str]] = {k: set() for k in expected}
    for q in tables:
        schema = q.split(".", 1)[0]
        if schema in actual:
            actual[schema].add(q)
        else:
            errors.append(f"SCHEMA inesperado: {q}")
    for layer in expected:
        missing = expected[layer] - actual[layer]
        extra = actual[layer] - expected[layer]
        for x in sorted(missing):
            errors.append(f"FALTA [{layer}]: {x}")
        for x in sorted(extra):
            errors.append(f"EXTRA [{layer}]: {x}")
        n_exp, n_act = len(expected[layer]), len(actual[layer])
        status = "ok" if n_exp == n_act and not missing and not extra else "FALHA"
        print(f"  {layer:9} esperado={n_exp:4} encontrado={n_act:4} {status}")

    # 3. lineage por camada
    for q, header, _ in blocks:
        schema = q.split(".", 1)[0]
        for ln in header:
            om = ORIGEN_RE.match(ln)
            if not om:
                continue
            sources = [s.strip() for s in om.group(1).split(",")]
            for src in sources:
                if schema == "edw" and src.startswith("raw."):
                    errors.append(f"REGRA-FR: {q} tem @origen {src} (edw nunca aponta para raw)")
                if schema == "mart" and not src.startswith("edw."):
                    errors.append(f"REGRA-FR: {q} tem @origen {src} (mart só deriva de edw)")

    # 4. @map resolve
    n_maps = 0
    for q, _, body in blocks:
        for line in body:
            mm = MAP_RE.search(line)
            if not mm:
                continue
            n_maps += 1
            ref = mm.group(1)
            parts = ref.rsplit(".", 1)
            if len(parts) != 2:
                errors.append(f"@map malformado em {q}: {ref}")
                continue
            tbl, col = parts
            if tbl not in tables:
                errors.append(f"@map em {q}: tabela origem '{tbl}' não existe")
            elif col.lower() not in tables[tbl]:
                errors.append(f"@map em {q}: coluna '{tbl}.{col}' não existe")
    print(f"  @map      {n_maps} referências")

    # 5. @fk resolve
    n_fks = 0
    for q, header, _ in blocks:
        for ln in header:
            fm = FK_RE.match(ln)
            if not fm:
                continue
            n_fks += 1
            col, tbl, tcol = fm.groups()
            if col.lower() not in tables.get(q, set()):
                errors.append(f"@fk em {q}: coluna local '{col}' não existe")
            if tbl not in tables:
                errors.append(f"@fk em {q}: tabela alvo '{tbl}' não existe")
            elif tcol.lower() not in tables[tbl]:
                errors.append(f"@fk em {q}: coluna alvo '{tbl}.{tcol}' não existe")
    print(f"  @fk       {n_fks} referências")

    # 6. blocos curados staging/edw/mart verbatim (corpo)
    n_curated = 0
    body_by_table = {q: "\n".join(b) for q, _, b in blocks}
    for q, b in m.curated.items():
        if b.schema == "raw":
            continue  # raw curada é absorvida (override), não verbatim
        n_curated += 1
        if q not in body_by_table:
            errors.append(f"CURADO ausente: {q}")
        elif body_by_table[q].strip() != b.body.strip():
            errors.append(f"CURADO divergente: {q} (corpo difere do spine)")
    print(f"  curados   {n_curated} blocos staging/edw/mart verificados")

    if errors:
        print(f"\nFALHOU — {len(errors)} erro(s):")
        for e in errors[:50]:
            print(f"  - {e}")
        if len(errors) > 50:
            print(f"  ... +{len(errors) - 50}")
        return 1
    print("\nOK — mereo_snowflake_full.sql válido")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
