{{ config(materialized='table') }}

with product_base as (
    select
        product_id, product_name, product_brand, product_category,
        product_rating, product_stock, product_return_rate, product_size, product_material, _loaded_at,
        row_number() over (partition by product_id order by _loaded_at desc) as rn
    from {{ ref('stg_retail_transactions') }}
    where product_id is not null
),

deduped_products as (
    select * from product_base where rn = 1
)

select
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_hash_key,
    product_id, product_name, product_brand, product_category,
    product_rating, product_stock, product_return_rate, product_size, product_material
from deduped_products