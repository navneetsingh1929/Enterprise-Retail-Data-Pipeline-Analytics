{{ config(materialized='table') }}

with transaction_base as (
    select
        transaction_id, customer_id, product_id, promotion_id, transaction_date,
        payment_method, store_location, store_zip_code, store_city, store_state, distance_to_store,
        is_holiday_season, season_name, is_weekend, quantity, unit_price, discount_applied,
        total_sales as source_total_sales, _loaded_at,
        row_number() over (partition by transaction_id, product_id order by _loaded_at desc) as rn
    from {{ ref('stg_retail_transactions') }}
    where transaction_id is not null and product_id is not null
),

deduped_transactions as (
    select * from transaction_base where rn = 1
)

select
    {{ dbt_utils.generate_surrogate_key(['transaction_id', 'product_id']) }} as transaction_item_hash_key,
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_hash_key,
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_hash_key,
    {{ dbt_utils.generate_surrogate_key(['promotion_id']) }} as promotion_hash_key,
    transaction_id, transaction_date, payment_method, store_location, store_zip_code, store_city, store_state, distance_to_store,
    is_holiday_season, season_name, is_weekend, quantity, unit_price, discount_applied, source_total_sales,
    cast((quantity * unit_price) as number(12,2)) as gross_transaction_value,
    cast(((quantity * unit_price) - discount_applied) as number(12,2)) as net_transaction_revenue,
    _loaded_at
from deduped_transactions