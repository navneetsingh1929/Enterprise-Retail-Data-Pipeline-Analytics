{{ config(materialized='table') }}

with promotion_base as (
    select
        promotion_id, promotion_type, promotion_start_date, promotion_end_date,
        promotion_effectiveness, promotion_channel, _loaded_at,
        row_number() over (partition by promotion_id order by _loaded_at desc) as rn
    from {{ ref('stg_retail_transactions') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['promotion_id']) }} as promotion_hash_key,
    promotion_id, promotion_type, promotion_start_date, promotion_end_date,
    promotion_effectiveness, promotion_channel
from promotion_base
where rn = 1