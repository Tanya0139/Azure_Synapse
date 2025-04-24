
# 💠 Azure Synapse Project

## 📌 Overview

This project demonstrates how to build a modern data architecture using **Azure Synapse**, incorporating **Data Factory**, **Azure Data Lake Storage**, and **Delta Lake** architecture (Bronze, Silver, and Gold layers).

---

## 🗺️ Architecture

```mermaid
graph TD;
  A[Raw Data (Parquet/CSV)] --> B[Bronze Layer - Mounted to Synapse]
  B --> C[Silver Layer - Cleaned & Filtered]
  C --> D[Gold Layer - Aggregated Views using SQL Serverless]
  D --> E[Power BI / Reporting]
```

---

## 🏗️ Components & Code Snippets

### 🔐 1. Mount ADLS Storage in Synapse

```python
configs = {
  "fs.azure.account.auth.type": "OAuth",
  "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
  "fs.azure.account.oauth2.client.id": "<client-id>",
  "fs.azure.account.oauth2.client.secret": dbutils.secrets.get(scope="<scope>", key="<key-name>"),
  "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/<tenant-id>/oauth2/token"
}

dbutils.fs.mount(
  source="abfss://<container>@<account>.dfs.core.windows.net/",
  mount_point="/mnt/<mount-name>",
  extra_configs=configs
)
```

---

### ⚙️ 2. Bronze ➡️ Silver Transformation

```python
df_bronze = spark.read.format("parquet").load("/mnt/<mount-name>/bronze/")
df_silver = df_bronze.filter("trip_distance > 0").dropna()
df_silver.write.format("delta").mode("overwrite").save("/mnt/<mount-name>/silver/")
```

---

### ✨ 3. Silver ➡️ Gold Aggregation

```python
df_silver = spark.read.format("delta").load("/mnt/<mount-name>/silver/")
df_gold = df_silver.groupBy("payment_type").agg({"total_amount": "avg"})
df_gold.write.format("delta").mode("overwrite").save("/mnt/<mount-name>/gold/")
```

---

### 📄 4. Create SQL Serverless View

```sql
CREATE OR ALTER VIEW [dbo].[vw_avg_payment_by_type] AS
SELECT
    payment_type,
    AVG(total_amount) as avg_total_amount
FROM
    OPENROWSET(
        BULK 'https://<storageaccount>.dfs.core.windows.net/<container>/gold/*.parquet',
        FORMAT='PARQUET'
    ) AS [result]
GROUP BY payment_type;
```

---

## 🧠 Technologies Used

- Azure Synapse Analytics
- Azure Data Factory
- Azure Data Lake Storage Gen2
- Delta Lake (Bronze/Silver/Gold)
- Power BI
- SQL Serverless
- Python (Spark)
- GitHub for version control

---

## ✅ Outcome

🚀 Successfully implemented a layered architecture with secure access, scalable data transformation pipelines, and analytical views consumable via Power BI.

---
