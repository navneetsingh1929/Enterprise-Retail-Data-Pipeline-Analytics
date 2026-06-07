# Enterprise-Retail-Data-Pipeline-Analytics

# End-to-End Enterprise Retail Data Pipeline & Analytics Engine
### Tech Stack: Python (Pandas, NumPy), AWS S3, Snowflake, dbt Core, Power BI (Import Mode)

---

## 📌 Project Overview
This repository contains a production-grade, end-to-end data engineering and business intelligence pipeline that processes over **1 Million (10 Lakh) rows** of raw transactional data. Shifting away from a disorganized "One Big Table" (OBT) format, the architecture implements a **Medallion Star Schema Framework** (Bronze -> Silver -> Gold). 

The goal of this engine is to ingest raw records, perform rigorous feature engineering, enforce structural constraints, maintain historical tracking, and surface clean data for high-impact executive dashboards standard to global firms like **Dunnhumby and Tesco**.

---

## 🏗️ Architecture Blueprint
The data flows sequentially through three unified environments to guarantee performance, storage optimization, and absolute reporting integrity:

1. **Ingestion Layer (Python):** Raw datasets are processed using Pandas and NumPy for initial truncation, data type enforcement, and algorithmic feature derivation before landing on cloud buckets.
2. **Bronze Layer (Raw Staging):** Direct raw tables and view projections (`stg_retail_transactions`) built in Snowflake via dbt Core to capture immutable snapshots of source schemas.
3. **Silver Layer (Dimensional Modeling):** Data normalization into standard Star Schema formats. Features are bucketed into clean Dimensions and Facts using **MD5 Surrogate Hashing** and extreme data deduplication window logic.
4. **Gold Layer (Analytical OBT Reporting):** Highly dense join aggregates that compile independent dimensions into a structured One Big Table optimized for fast BI columnar cache query indexing.

---

## 🛠️ Phase 1: Python Data Ingestion & Algorithmic Feature Derivation
Before modeling data inside the warehouse, a Python pipeline sanitizes dates, removes structural noise, and generates core analytical scoring metrics (`loyalty_score`, `churn_risk_score`) using advanced vectorization logic via **Pandas & NumPy**:

```python
import numpy as np
import pandas as pd

# 1. Load the dataset
df = pd.read_csv("retail_data.csv")

# --- Operation: Drop Temporal Overlaps & Structural Noise ---
columns_to_drop = ["transaction_hour", "day_of_week", "week_of_year", "month_of_year"]
df = df.drop(columns=columns_to_drop, errors="ignore")

# --- Operation: Date Isolation & Cleaning ---
date_columns = [
    "transaction_date", "last_purchase_date", "product_manufacture_date",
    "product_expiry_date", "promotion_start_date", "promotion_end_date"
]
for col in date_columns:
    if col in df.columns:
        df[col] = df[col].astype(str).str.split(" ").str[0]

# --- Operation: Metric Calculation & Type Constraints Enforcements ---
numeric_cols = [
    "total_transactions", "total_sales", "avg_transaction_value",
    "membership_years", "website_visits", "days_since_last_purchase", "customer_support_calls"
]
for col in numeric_cols:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)

# Derive: Average Purchase Interval
df["avg_purchase_interval"] = np.where(df["total_transactions"] > 0, (365 / df["total_transactions"]), 0).round(2)

# Derive: Customer Lifetime Value (CLV Core Mapping)
df["customer_lifetime_value"] = df["total_sales"].round(2)

# Derive: Custom Loyalty Score Algorithm
tenure_pts = df["membership_years"].clip(upper=10) * 4
transaction_pts = df["total_transactions"].clip(upper=50) * 0.8
engagement_pts = df["website_visits"].clip(upper=100) * 0.2
df["loyalty_score"] = (tenure_pts + transaction_pts + engagement_pts).round(2)

# Derive: Custom Churn Risk Score Vectorization
recency_pts = df["days_since_last_purchase"].clip(upper=180) * 0.278
support_pts = df["customer_support_calls"].clip(upper=5) * 6
churn_history_pts = np.where(df["churned"].astype(str).str.lower() == "yes", 20, 0)
df["churn_risk_score"] = (recency_pts + support_pts + churn_history_pts).round(2)

# Save Sanatized Dataset for Snowflake Landing
df.to_csv("transform_retail_data.csv", index=False)
---
##⚡ Phase 2: Warehouse Modeling & dbt Pipelines (Silver & Gold Layers)

To prevent reporting breakages and relational Fan-out Duplication Problems, the architecture implements strict sequence window ranking (row_number()) inside dbt models before generating central analytics cubes.
1. Dimension Tables (Silver Layer Example)

dim_promotions.sql and dim_products.sql resolve structural anomalies inside Kaggle source formats by partitioning records over business natural keys to isolate unique entries.
SQL
---
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

2. Analytical Cube (Gold Layer)

obt_retail_sales.sql combines dimensions and fact tables using MD5 Surrogate Keys. It incorporates an automated incremental infrastructure trace (pipeline_execution_audit) that injects dynamic runtime metadata variables (invocation_id) directly into reporting grain structures.
SQL

{{ config(materialized='table', schema='gold') }}

with fact_sales as (
    select * from {{ ref('fact_transactions') }}
),
dim_cust as ( select * from {{ ref('dim_customers') }} ),
dim_prod as ( select * from {{ ref('dim_products') }} ),
dim_promo as ( select * from {{ ref('dim_promotions') }} ),
metadata_logs as (
    select run_id, pipeline_execution_start_time from {{ ref('pipeline_execution_audit') }}
    order by pipeline_execution_start_time desc limit 1
)

select
    f.transaction_item_hash_key, f.transaction_id, f.transaction_date,
    c.customer_id, c.customer_age, c.customer_gender, c.income_bracket, c.loyalty_program,
    c.loyalty_score, c.churn_risk_score, c.has_churned, c.customer_city, c.customer_state,
    p.product_id, p.product_name, p.product_brand, p.product_category, p.product_rating, p.product_stock,
    pr.promotion_id, pr.promotion_type, pr.promotion_effectiveness, pr.promotion_channel,
    f.store_location, f.store_city, f.store_state, f.is_holiday_season, f.season_name, f.is_weekend,
    f.quantity, f.unit_price, f.discount_applied, f.source_total_sales, f.gross_transaction_value, f.net_transaction_revenue,
    m.run_id as pipeline_run_id, m.pipeline_execution_start_time as gold_layer_processed_at
from fact_sales f
left join dim_cust c on f.customer_hash_key = c.customer_hash_key
left join dim_prod p on f.product_hash_key = p.product_hash_key
left join dim_promo pr on f.promotion_hash_key = pr.promotion_hash_key
cross join metadata_logs m

📈 Phase 3: Business Intelligence & Dunnhumby Executive Dashboards

The refined analytical Gold layer is streamed into Power BI Desktop via Import Mode connectivity leveraging xVelocity columnar compression engine to maintain sub-second cross-filtering latency.
Canvas 1: Executive Revenue & Campaign Insights

Focused on tracking capital performance efficiency, margin preservation, and promotion allocation distributions:

    Core Business Financial KPIs: Exposes Gross Transaction Value (GTV), Net Revenue, Promo Elasticity (Discount Leakage Ratio), and Average Basket Value (ABV) dynamically formatted under global accounting models.

    ABV Time-Series Integration: Dual-axis charts maps monthly Net revenues correlated with multi-quarter moving Ticket Sizes.

    Commercial Matrix: Deep matrix grid reporting cross-channel campaign completions (promotion_type vs promotion_channel) evaluating physical clearance metrics.

Canvas 2: Customer Loyalty & Behavioral Segmentation

Leverages the core algorithmic variables generated during pipeline executions to map retention risks and brand interaction densities:

    The Retention Risk Scatter Quadrant: A dynamic scatter distribution tracking Average Loyalty Score vs Average Churn Risk Score mapped over customer demographic cohorts (income_bracket, gender), filtering out density clutter to expose critical high-risk leakage groups.

    Income & Loyalty Adoption Deck: Horizontal 100% stacked bar metrics providing categorical exposure of loyalty conversions within fixed economic bounds.

    Sequential Age Cohorts Correlation: Custom DAX bucketed intervals (Age Group = FLOOR(customer_age, 5)) tracking customer age trends linearly against store attrition rates.

🚀 Deployment Instructions (How to Run)

    Pre-requisites: Install Python 3.x, configure active Snowflake Cloud warehouse compute environment.

    Data Prep: Execute ingestion script to generate baseline files: python main.py

    Execute dbt Models: Navigate to your project terminal and initialize structural transformations:
    Bash

    dbt clean
    dbt deps
    dbt run --full-refresh
    dbt test

    BI Deployment: Open the Power BI workbook, configure the Snowflake connector using the account URL and Import constraints, and hit Refresh to update reporting metrics.
