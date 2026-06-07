{% snapshot scd_customers_snapshot %}

{{
    config(
      target_database='retail_db',
      target_schema='analytics',
      unique_key='customer_hash_key',
      strategy='check',
      check_cols=['income_bracket', 'loyalty_program', 'churn_risk_score', 'has_churned'],
    )
}}

-- Historical capture points targeting our Silver dimension
select 
    customer_hash_key,
    customer_id,
    customer_age,
    income_bracket,
    loyalty_program,
    loyalty_score,
    churn_risk_score,
    has_churned,
    _loaded_at
from {{ ref('dim_customers') }}

{% endsnapshot %}