{{ config(materialized='view') }}

with source_data as (
    select * from {{ source('raw', 'landing_retail_data') }}
)

select
    -- =====================================================================
    -- 1. PRIMARY KEYS & SURROGATE KEY BASE FIELDS
    -- =====================================================================
    cast(transaction_id as varchar) as transaction_id,
    cast(customer_id as varchar) as customer_id,
    cast(product_id as varchar) as product_id,
    cast(coalesce(promotion_id, 'NO_PROMO') as varchar) as promotion_id,

    -- =====================================================================
    -- 2. CUSTOMER DEMOGRAPHICS & CORE ATTRIBUTES
    -- =====================================================================
    cast(age as integer) as customer_age,
    trim(upper(gender)) as customer_gender,
    trim(upper(income_bracket)) as income_bracket,
    trim(upper(loyalty_program)) as loyalty_program,
    cast(membership_years as integer) as membership_years,
    trim(upper(churned)) as has_churned,
    trim(upper(marital_status)) as marital_status,
    cast(number_of_children as integer) as number_of_children,
    trim(upper(education_level)) as education_level,
    trim(upper(occupation)) as customer_occupation,

    -- =====================================================================
    -- 3. TRANSACTIONAL METRICS & LOGISTICS
    -- =====================================================================
    to_date(transaction_date, 'YYYY-MM-DD') as transaction_date,
    cast(quantity as integer) as quantity,
    cast(unit_price as number(10,2)) as unit_price,
    cast(discount_applied as number(5,2)) as discount_applied,
    trim(upper(payment_method)) as payment_method,
    trim(upper(store_location)) as store_location,
    cast(total_sales as number(12,2)) as total_sales,

    -- =====================================================================
    -- 4. CUSTOMER BEHAVIOR & INTERACTION METRICS
    -- =====================================================================
    cast(avg_purchase_value as number(10,2)) as avg_purchase_value,
    trim(upper(purchase_frequency)) as purchase_frequency,
    to_date(last_purchase_date, 'YYYY-MM-DD') as last_purchase_date,
    cast(avg_discount_used as number(5,2)) as avg_discount_used,
    trim(upper(preferred_store)) as preferred_store,
    cast(online_purchases as integer) as online_purchases,
    cast(in_store_purchases as integer) as in_store_purchases,
    cast(avg_items_per_transaction as number(5,2)) as avg_items_per_transaction,
    cast(total_returned_items as integer) as total_returned_items,
    cast(total_returned_value as number(10,2)) as total_returned_value,
    cast(customer_support_calls as integer) as customer_support_calls,
    trim(upper(email_subscriptions)) as is_subscribed_emails,

    -- =====================================================================
    -- 5. PRODUCT PROFILE DETAILS
    -- =====================================================================
    trim(product_name) as product_name,
    trim(upper(product_brand)) as product_brand,
    trim(upper(product_category)) as product_category,
    cast(product_rating as number(3,1)) as product_rating,
    cast(product_stock as integer) as product_stock,
    cast(product_return_rate as number(5,2)) as product_return_rate,
    trim(upper(product_size)) as product_size,
    trim(upper(product_material)) as product_material,

    -- =====================================================================
    -- 6. PROMOTIONAL LOGS
    -- =====================================================================
    trim(upper(promotion_type)) as promotion_type,
    to_date(promotion_start_date, 'YYYY-MM-DD') as promotion_start_date,
    to_date(promotion_end_date, 'YYYY-MM-DD') as promotion_end_date,
    trim(upper(promotion_effectiveness)) as promotion_effectiveness,
    trim(upper(promotion_channel)) as promotion_channel,

    -- =====================================================================
    -- 7. GEOGRAPHICAL ATTRIBUTES
    -- =====================================================================
    cast(customer_zip_code as varchar) as customer_zip_code,
    trim(upper(customer_city)) as customer_city,
    trim(upper(customer_state)) as customer_state,
    cast(store_zip_code as varchar) as store_zip_code,
    trim(upper(store_city)) as store_city,
    trim(upper(store_state)) as store_state,
    cast(distance_to_store as number(10,2)) as distance_to_store,

    -- =====================================================================
    -- 8. SEASONAL & TEMPORAL FLAGS
    -- =====================================================================
    trim(upper(holiday_season)) as is_holiday_season,
    trim(upper(season)) as season_name,
    trim(upper(weekend)) as is_weekend,

    -- =====================================================================
    -- 9. ADVANCED DERIVED DATA SCIENCE METRICS (High Value for Dunnhumby)
    -- =====================================================================
    cast(days_since_last_purchase as integer) as days_since_last_purchase,
    cast(customer_lifetime_value as number(12,2)) as customer_lifetime_value,
    cast(loyalty_score as number(5,2)) as loyalty_score,
    cast(churn_risk_score as number(5,2)) as churn_risk_score,

    -- =====================================================================
    -- 10. METADATA AUDIT COLUMNS
    -- =====================================================================
    _loaded_at,
    _file_name

from source_data