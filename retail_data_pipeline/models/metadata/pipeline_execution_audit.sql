{{ config(
    materialized='incremental',
    schema='metadata',
    unique_key='run_id'
) }}

with current_execution as (
    select
        '{{ invocation_id }}' as run_id,
        '{{ project_name }}' as dbt_project,
        to_timestamp_ntz('{{ run_started_at }}') as pipeline_execution_start_time,
        current_user() as executed_by_user,
        current_warehouse() as snowflake_compute_warehouse
)

select * from current_execution

{% if is_incremental() %}
    -- Prevents processing overlaps
    where pipeline_execution_start_time > (select max(pipeline_execution_start_time) from {{ this }})
{% endif %}