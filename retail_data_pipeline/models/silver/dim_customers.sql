{{ config(
    materialized='incremental',
    unique_key='customer_hash_key',
    incremental_strategy='merge'
) }}

with customer_base as (
    select
        customer_id,
        customer_age,
        customer_gender,
        income_bracket,
        loyalty_program,
        membership_years,
        has_churned,
        marital_status,
        number_of_children,
        education_level,
        customer_occupation,
        avg_purchase_value,
        purchase_frequency,
        last_purchase_date,
        avg_discount_used,
        preferred_store,
        online_purchases,
        in_store_purchases,
        avg_items_per_transaction,
        total_returned_items,
        total_returned_value,
        customer_support_calls,
        is_subscribed_emails,
        days_since_last_purchase,
        customer_lifetime_value,
        loyalty_score,
        churn_risk_score,
        customer_zip_code,
        customer_city,
        customer_state,
        _loaded_at,
        row_number() over (partition by customer_id order by _loaded_at desc) as rn
    from {{ ref('stg_retail_transactions') }}
    where customer_id is not null
),

deduped_customers as (
    select * from customer_base where rn = 1
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_hash_key,
    customer_id, customer_age, customer_gender, income_bracket, loyalty_program,
    membership_years, has_churned, marital_status, number_of_children,
    education_level, customer_occupation, avg_purchase_value, purchase_frequency,
    last_purchase_date, avg_discount_used, preferred_store, online_purchases,
    in_store_purchases, avg_items_per_transaction, total_returned_items,
    total_returned_value, customer_support_calls, is_subscribed_emails,
    days_since_last_purchase, customer_lifetime_value, loyalty_score,
    churn_risk_score, customer_zip_code, customer_city, customer_state, _loaded_at
from deduped_customers

{% if is_incremental() %}
    where _loaded_at > (select max(_loaded_at) from {{ this }})
{% endif %}