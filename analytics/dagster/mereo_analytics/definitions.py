"""Dagster definitions for Mereo analytics (dbt + ClickHouse)."""

import os
from pathlib import Path

import clickhouse_connect
from dagster import (
    AssetExecutionContext,
    DefaultScheduleStatus,
    DefaultSensorStatus,
    Definitions,
    RunRequest,
    ScheduleDefinition,
    SensorEvaluationContext,
    define_asset_job,
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


def _kafka_lag() -> int:
    client = _ch_client()
    try:
        result = client.query(
            """
            SELECT coalesce(
                sum(greatest(
                    toInt64(0),
                    toInt64(coalesce(assignments.current_offset[1], 0))
                    - toInt64(coalesce(num_messages_read, 0))
                )),
                0
            ) AS lag
            FROM system.kafka_consumers
            WHERE table = 'colaborador_kafka'
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


@sensor(job=dbt_build_job, minimum_interval_seconds=120, default_status=DefaultSensorStatus.RUNNING)
def raw_freshness_sensor(context: SensorEvaluationContext):
    try:
        lag = _kafka_lag()
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
    jobs=[dbt_build_job],
    resources={
        "dbt": DbtCliResource(
            project_dir=dbt_project,
            profiles_dir=DBT_PROJECT_DIR,
            dbt_executable=str(DBT_EXECUTABLE) if DBT_EXECUTABLE.exists() else "dbt",
            target=os.environ.get("DBT_TARGET", "dev"),
        ),
    },
    schedules=[daily_dbt_schedule],
    sensors=[raw_freshness_sensor],
)
