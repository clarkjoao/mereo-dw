"""Dagster definitions for Mereo analytics (dbt + ClickHouse)."""

import os
from datetime import datetime, timezone
from pathlib import Path

import clickhouse_connect
from dagster import (
    AssetExecutionContext,
    DefaultScheduleStatus,
    DefaultSensorStatus,
    Definitions,
    MetadataValue,
    OpExecutionContext,
    RunRequest,
    ScheduleDefinition,
    SensorEvaluationContext,
    define_asset_job,
    job,
    op,
    sensor,
)
from dagster_dbt import DbtCliResource, DbtProject, dbt_assets

_analytics_root = Path(__file__).parent.parent.parent
DBT_PROJECT_DIR = Path(os.environ.get("DBT_PROJECT_DIR", _analytics_root / "dbt"))
_dbt_exe = os.environ.get("DBT_EXECUTABLE")
DBT_EXECUTABLE = Path(_dbt_exe) if _dbt_exe else Path(__file__).parent.parent / ".venv" / "bin" / "dbt"

PILOT_ENTITY = os.environ.get("MEREPO_PILOT_ENTITY", "colaborador")
CH_HOST = os.environ.get("CH_HOST", "localhost")
CH_PORT = int(os.environ.get("CH_PORT", "18123"))
CH_USER = os.environ.get("CH_USER", "dbt")
CH_PASSWORD = os.environ.get("CH_DBT_PASSWORD") or os.environ.get("password", "")
KAFKA_CONSUMER_GROUP = os.environ.get("CH_RAW_CONSUMER_GROUP", "ch-raw-colaborador-v2")
MAX_LAG_MESSAGES = int(os.environ.get("FRESHNESS_MAX_LAG", "100"))

dbt_project = DbtProject(
    project_dir=DBT_PROJECT_DIR,
    profiles_dir=DBT_PROJECT_DIR,
)

dbt_project.prepare_if_dev()


def _ch_client():
    return clickhouse_connect.get_client(
        host=CH_HOST,
        port=CH_PORT,
        username=CH_USER,
        password=CH_PASSWORD,
        secure=False,
    )


def _kafka_lag(entity: str) -> int:
    kafka_table = f"{entity}_kafka"
    client = _ch_client()
    try:
        result = client.query(
            f"""
            SELECT coalesce(
                sum(greatest(
                    toInt64(0),
                    toInt64(coalesce(assignments.current_offset[1], 0))
                    - toInt64(coalesce(num_messages_read, 0))
                )),
                0
            ) AS lag
            FROM system.kafka_consumers
            WHERE table = '{kafka_table}'
            """
        )
        return max(0, int(result.first_row[0] or 0))
    except Exception:
        return 0


def _raw_watermark(entity: str) -> int:
    client = _ch_client()
    result = client.query(f"SELECT coalesce(max(_ts_ms), 0) FROM raw.{entity}")
    return int(result.first_row[0] or 0)


@dbt_assets(manifest=dbt_project.manifest_path)
def mereo_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()


dbt_build_job = define_asset_job(name="dbt_build", selection=[mereo_dbt_assets])

daily_dbt_schedule = ScheduleDefinition(
    job=dbt_build_job,
    cron_schedule="0 6 * * *",
    name="daily_dbt_build",
    default_status=DefaultScheduleStatus.STOPPED,
)


@op
def snapshot_raw_ingestion(context: OpExecutionContext) -> dict:
    """Snapshot volume/lag/watermark de raw.{entity} → pipeline.*."""
    entity = PILOT_ENTITY
    kafka_table = f"{entity}_kafka"
    topic = f"raw.{entity}"
    client = _ch_client()
    now = datetime.now(timezone.utc)

    total = int(
        client.query(f"SELECT count() FROM raw.{entity}").first_row[0] or 0
    )
    total_final = int(
        client.query(f"SELECT count() FROM raw.{entity} FINAL").first_row[0] or 0
    )
    watermark = _raw_watermark(entity)
    lag = _kafka_lag(entity)

    per_tenant: dict[str, int] = {}
    tenant_rows = client.query(
        f"SELECT tenant_slug, count() AS n FROM raw.{entity} GROUP BY tenant_slug ORDER BY tenant_slug"
    )
    for slug, n in tenant_rows.result_rows:
        per_tenant[str(slug)] = int(n or 0)

    snapshot_rows: list[list] = []
    snapshot_rows.append(
        [entity, "", total, total_final, watermark, lag, now]
    )
    for slug, n in per_tenant.items():
        snapshot_rows.append([entity, slug, n, n, watermark, lag, now])

    client.insert(
        "pipeline.ingestion_snapshots",
        snapshot_rows,
        column_names=[
            "entity",
            "tenant_slug",
            "row_count",
            "row_count_final",
            "ch_max_ts_ms",
            "kafka_lag",
            "snapshot_at",
        ],
    )
    client.insert(
        "pipeline.entity_watermarks",
        [[entity, watermark, None, now]],
        column_names=["entity", "ch_max_ts_ms", "kafka_hi_offset", "checked_at"],
    )
    client.insert(
        "pipeline.consumer_lag_snapshots",
        [[KAFKA_CONSUMER_GROUP, kafka_table, lag, now]],
        column_names=["consumer_group", "topic", "lag", "snapshot_at"],
    )

    volume_meta = {
        "entity": entity,
        "total_rows": total,
        "total_rows_final": total_final,
        "watermark_ts_ms": watermark,
        "kafka_lag": lag,
        "kafka_table": kafka_table,
        "consumer_group": KAFKA_CONSUMER_GROUP,
        "by_tenant": per_tenant,
    }
    context.add_output_metadata(
        {
            "entity": MetadataValue.text(entity),
            "total_rows": MetadataValue.int(total),
            "total_rows_final": MetadataValue.int(total_final),
            "watermark_ts_ms": MetadataValue.int(watermark),
            "kafka_lag": MetadataValue.int(lag),
            "by_tenant": MetadataValue.json(per_tenant),
        }
    )
    context.log.info(
        "raw.%s snapshot: rows=%s final=%s lag=%s watermark=%s tenants=%s",
        entity,
        total,
        total_final,
        lag,
        watermark,
        per_tenant,
    )
    return volume_meta


@job
def raw_ingestion_observability():
    snapshot_raw_ingestion()


raw_ingestion_observability_schedule = ScheduleDefinition(
    job=raw_ingestion_observability,
    cron_schedule="*/5 * * * *",
    name="raw_ingestion_observability_schedule",
    default_status=DefaultScheduleStatus.RUNNING,
)


@sensor(job=dbt_build_job, minimum_interval_seconds=120, default_status=DefaultSensorStatus.RUNNING)
def raw_freshness_sensor(context: SensorEvaluationContext):
    try:
        lag = _kafka_lag(PILOT_ENTITY)
        watermark = _raw_watermark(PILOT_ENTITY)
    except Exception as exc:
        context.log.warning("Freshness check failed: %s", exc)
        return

    if lag > MAX_LAG_MESSAGES:
        context.log.info("dbt blocked: CH Kafka lag=%s > %s", lag, MAX_LAG_MESSAGES)
        try:
            client = _ch_client()
            client.insert(
                "pipeline.freshness_events",
                [[PILOT_ENTITY, 1, f"lag={lag}", None]],
                column_names=["entity", "dbt_blocked", "reason", "at"],
            )
        except Exception:
            pass
        return

    if watermark == 0:
        context.log.info("dbt blocked: raw.%s watermark=0", PILOT_ENTITY)
        return

    context.log.info("Freshness OK lag=%s watermark=%s — triggering dbt_build", lag, watermark)
    yield RunRequest(run_key=f"fresh-{PILOT_ENTITY}-{watermark}")


defs = Definitions(
    assets=[mereo_dbt_assets],
    jobs=[dbt_build_job, raw_ingestion_observability],
    resources={
        "dbt": DbtCliResource(
            project_dir=dbt_project,
            profiles_dir=DBT_PROJECT_DIR,
            dbt_executable=str(DBT_EXECUTABLE) if DBT_EXECUTABLE.exists() else "dbt",
            target=os.environ.get("DBT_TARGET", "dev"),
        ),
    },
    schedules=[daily_dbt_schedule, raw_ingestion_observability_schedule],
    sensors=[raw_freshness_sensor],
)
