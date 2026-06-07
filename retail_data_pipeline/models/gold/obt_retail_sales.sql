{{ config(
    materialized='table', 
    schema='gold'
) }}

with fact_sales as (
    select * from {{ ref('fact_transactions') }}
),

dim_cust as (
    select * from {{ ref('dim_customers') }}
),

dim_prod as (
    select * from {{ ref('dim_products') }}
),

dim_promo as (
    select * from {{ ref('dim_promotions') }}
),

metadata_logs as (
    select run_id, pipeline_execution_start_time from {{ ref('pipeline_execution_audit') }}
    order by pipeline_execution_start_time desc limit 1
)

select
    f.transaction_item_hash_key,
    f.transaction_id,
    f.transaction_date,
    
    -- Customer Context
    c.customer_id, c.customer_age, c.customer_gender, c.income_bracket, c.loyalty_program,
    c.loyalty_score, c.churn_risk_score, c.has_churned, c.customer_city, c.customer_state,
    
    -- Product Context
    p.product_id, p.product_name, p.product_brand, p.product_category, p.product_rating, p.product_stock,
    
    -- Promotion Context
    pr.promotion_id, pr.promotion_type, pr.promotion_effectiveness, pr.promotion_channel,
    
    -- Geo/Temporal
    f.store_location, f.store_city, f.store_state, f.is_holiday_season, f.season_name, f.is_weekend,
    
    -- Metrics
    f.quantity, f.unit_price, f.discount_applied, f.source_total_sales, f.gross_transaction_value, f.net_transaction_revenue,
    
    -- Audit Tracking
    m.run_id as pipeline_run_id,
    m.pipeline_execution_start_time as gold_layer_processed_at

from fact_sales f
left join dim_cust c on f.customer_hash_key = c.customer_hash_key
left join dim_prod p on f.product_hash_key = p.product_hash_key
left join dim_promo pr on f.promotion_hash_key = pr.promotion_hash_key
cross join metadata_logs m