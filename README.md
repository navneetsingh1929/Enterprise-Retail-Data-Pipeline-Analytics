# Enterprise-Retail-Data-Pipeline-Analytics

# End-to-End Enterprise Retail Data Pipeline & Analytics Engine
### Tech Stack: Python (Pandas, NumPy), AWS S3, Snowflake, dbt Core, Power BI (Import Mode)

---

## 📌 Project Overview
This repository documents a production-grade, end-to-end data engineering and business intelligence pipeline processing over 1 Million rows of raw transactional data. Shifting away from an unorganized "One Big Table" (OBT) format, the architecture implements a formalized Medallion Star Schema Framework (Bronze -> Silver -> Gold). 

The primary objective of this engine is to ingest raw multi-source data, perform programmatic feature engineering, enforce structural constraints, maintain historical tracking, and surface enterprise-grade analytical metrics tailored to global retail frameworks standard to firms like Dunnhumby and Tesco.

---

## 🏗️ Architecture Blueprint
The data flows sequentially through four distinct lifecycle stages to guarantee query performance, cost optimization, and absolute reporting integrity:

1. **Ingestion Layer (Python):** Raw datasets are processed for initial truncation, data type enforcement, and algorithmic metric derivation.
2. **Bronze Layer (Raw Staging):** Direct raw tables and view projections built within the warehouse to capture immutable snapshots of source schemas.
3. **Silver Layer (Dimensional Modeling):** Cleaned data normalized into a standard Star Schema. Records are partitioned to isolate unique entries, and composite fields are resolved using cryptographic hashing.
4. **Gold Layer (Analytical OBT Reporting):** Highly optimized, dense multi-table joins that compile independent dimensions into a single unified view optimized for fast BI columnar cache query indexing.

---

## 🛠️ Phase 1: Python Data Ingestion & Algorithmic Feature Derivation
Before moving data into the warehouse compute layer, a localized preprocessing pipeline handles structural cleaning and engineers critical analytical scoring vectors via Python:

* **Temporal Regularization:** Drops redundant time columns and operational noise to establish a consistent, focused transactional grain.
* **Date Standardization:** Loops through all timestamped fields to isolate clean string dates, stripping away irregular trailing time zones and empty space sub-strings.
* **Type Constraints Enforcement:** Evaluates primary columns to enforce rigorous numeric types, programmatically turning null errors into safe baselines.
* **Loyalty Score Engineering:** Employs clipping functions to establish a custom loyalty metric based on weighted vectors of customer membership duration, total store transactions, and website engagement frequencies.
* **Churn Risk Vectorization:** Implements localized risk scoring by evaluating customer support log volumes, transaction recency limits, and explicit historical churn statuses.

---

## ⚡ Phase 2: Dimensional Modeling & Relational Transformations (Silver Layer)
Inside the cloud warehouse, dbt Core governs the transition from raw staging views into a normalized schema designed to scale:

* **De-duplication Framework:** Solves relational data fan-out and replication issues by running row-sequencing partition logic over unique business keys, filtering out historical operational noise.
* **Surrogate Key Generation:** Eradicates reliance on vulnerable natural keys by processing target primary dimensions through cryptographic MD5 hashing functions to guarantee record uniqueness.
* **Star Schema Segregation:** Divides chaotic transactional flat files into dedicated independent Dimension tables (covering detailed customers, products, and promotion channels) linked directly to a centralized core Fact table.

---

## 🚀 Phase 3: Analytical Aggregation & Lineage Governance (Gold Layer)
The Gold Layer acts as the final reporting fabric, transforming normalized tables into highly integrated structures optimized for executive discovery:

* **One Big Table (OBT) Synthesis:** Joins the Silver fact and dimension tables into an analytical matrix, eliminating complex downstream join requirements within the reporting tool.
* **Metadata-Driven Execution Layer:** Injects active pipeline audit tracking parameters into the reporting structures. Every batch execution captures unique system invocation tokens and run timestamps, providing complete transparency for platform auditing.

---

## 📈 Phase 4: Business Intelligence & Dunnhumby Executive Dashboards
The clean analytical reporting layer is ingested into Power BI Desktop via Import Mode, leveraging the xVelocity in-memory columnar engine to provide lightning-fast, sub-second cross-filtering capabilities.

### 1. Executive Revenue & Campaign Insights Canvas
Focused on capital performance metrics, margin preservation, and promotion allocation distributions:
* **Core Financial Indicators:** Tracks Gross Transaction Value, Net Revenue, Promo Elasticity (Discount Leakage Ratio), and Average Basket Value (ABV/Ticket Size).
* **ABV Time-Series Integration:** Dual-axis visualization mapping monthly net revenues correlated directly against multi-quarter moving ticket sizes.
* **Commercial Matrix:** Deep matrix reporting cross-evaluating campaign type completions against active channel pipelines to pinpoint margin leaks.

### 2. Customer Loyalty & Behavioral Segmentation Canvas
Leverages advanced programmatic variables to expose demographic retention risks and brand interaction trends:
* **The Retention Risk Scatter Quadrant:** A specialized scatter distribution mapping Average Loyalty Score against Average Churn Risk. It aggregates individual records into clear demographic blocks (income bracket, gender), filtering out clutter to instantly surface vulnerable cohorts.
* **Income & Loyalty Adoption Deck:** Horizontal 100% stacked metrics tracking active loyalty program conversions across defined economic bounds.
* **Sequential Age Cohorts Correlation:** Linearly groups customer ages into clean 5-year buckets to evaluate shopping tenure and age-based attrition rates without visual noise.

### 3. Pipeline Operations & Quality Traceability Canvas
Built specifically to provide infrastructure visibility and enterprise platform governance:
* **Product Portfolio Distribution Treemap:** Hierarchical visualization tracking active transaction volume shares across categories and brands.
* **Governance Audit Logging Grid:** Displays dbt pipeline runtime execution tokens and processing timestamps directly on the canvas, proving absolute data integrity to stakeholders.

---

## 💻 Operations & Deployment Flow

1. **Local Data Processing:** Run the pipeline ingestion script to apply data types and engineer scoring vectors.
2. **dbt Dependency Installation:** Pull necessary auditing and hashing packages from the dbt hub repository.
3. **Pipeline Transformation:** Execute localized dbt models to trigger structural normalization, deduplication, and staging tests inside the data warehouse.
4. **BI Report Refresh:** Connect the reporting workbook to the analytical schema layer using warehouse compute credentials to update executive metrics.
