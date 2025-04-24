
# 🚀 Azure Synapse Project

This project demonstrates how to use Azure Synapse Analytics to implement a complete data lakehouse architecture using Delta Lake tables and Azure components.

---

## 🏗️ Architecture Overview

```mermaid
graph TD;
  Source[Raw Data (Parquet/CSV)] --> Mount[Mount ADLS to Synapse]
  Mount --> Bronze[Bronze Layer (Raw Data)]
  Bronze --> Silver[Silver Layer (Cleaned & Filtered)]
  Silver --> Gold[Gold Layer (Aggregated)]
  Gold --> SQLViews[SQL Serverless Views]
  SQLViews --> PowerBI[Power BI Dashboard]
```

---

## 📂 Mounting ADLS Storage

Mount your Azure Data Lake Storage to Synapse using the following script in a Synapse notebook:

```python
# Mount ADLS Gen2 storage
configs = {
  "fs.azure.account.auth.type": "OAuth",
  "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
  "fs.azure.account.oauth2.client.id": "<app-id>",
  "fs.azure.account.oauth2.client.secret": dbutils.secrets.get(scope="<scope-name>", key="<secret-name>"),
  "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/<directory-id>/oauth2/token"
}

dbutils.fs.mount(
  source = "abfss://<container-name>@<storage-account-name>.dfs.core.windows.net/",
  mount_point = "/mnt/<mount-name>",
  extra_configs = configs
)
```

---

## 🥉 Bronze Layer - Ingest Raw Data

```python
df_bronze = spark.read.format("parquet").load("/mnt/<mount-name>/raw/nyctaxi/")
df_bronze.write.format("delta").mode("overwrite").saveAsTable("bronze_table")
```

➡️ This reads raw files and persists them in the bronze layer using Delta Lake format.

---

## 🥈 Silver Layer - Cleaned Data

```python
df_silver = df_bronze.filter("trip_distance > 0 AND fare_amount > 0")
df_silver.write.format("delta").mode("overwrite").saveAsTable("silver_table")
```

🧹 Filters out invalid trip data for cleaner downstream analysis.

---

## 🥇 Gold Layer - Aggregated Data

```python
df_gold = df_silver.groupBy("payment_type").agg({"total_amount": "avg"})
df_gold.write.format("delta").mode("overwrite").saveAsTable("gold_table")
```

📊 Aggregates data at the payment method level for insights.

---

## ⚙️ Creating Serverless SQL Views

```sql
CREATE OR ALTER VIEW vw_GoldAggregates AS
SELECT * FROM OPENROWSET(
    BULK 'https://<storage-account>.dfs.core.windows.net/<container>/gold_table/',
    FORMAT = 'DELTA'
) AS rows;
```

🧠 Enables SQL querying on top of Delta Lake gold layer via Synapse serverless SQL.

---

## 📈 Visualization using Power BI

Connect Power BI to the serverless SQL pool and use the view `vw_GoldAggregates` to create dynamic dashboards.

---

## 🧠 Stored Procedure for View Creation

```sql
CREATE OR ALTER PROCEDURE sp_CreateSQLServerlessView_gold
AS
BEGIN
    CREATE OR ALTER VIEW vw_GoldTaxiData AS
    SELECT * FROM OPENROWSET(
        BULK 'https://<storage-account>.dfs.core.windows.net/<container>/gold_table/',
        FORMAT = 'DELTA'
    ) AS data;
END;
```

This stored procedure automates view creation from the Gold layer.

---

## 📌 Summary

✨ This project uses Delta Lake across **bronze**, **silver**, and **gold** layers in Azure Synapse.

🔐 Secrets are managed with Azure Key Vault.

📊 Views are created using serverless SQL for easy reporting and visualization.

💡 Entire pipeline can be orchestrated with Azure Data Factory for automation.

