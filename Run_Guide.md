# Project Execution Guide

## Customer Segmentation and RFM Analysis using PostgreSQL

This guide explains how to set up the database, import the Online Retail dataset, execute the SQL queries, and reproduce the customer segmentation analysis.

## 1. Prerequisites

You will need:

- PostgreSQL
- pgAdmin 4
- UCI Online Retail Dataset
- The `customer_segmentation.sql` file from this repository

**Dataset Source:** [UCI Machine Learning Repository – Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail)

The dataset contains 541,909 original transaction records from December 2010 to December 2011.

## 2. Create a PostgreSQL Database

1. Open pgAdmin 4.
2. Connect to your PostgreSQL server.
3. Right-click **Databases → Create → Database**.
4. Enter a database name such as `customer_segmentation`.
5. Click **Save**.

Open the Query Tool for the newly created database.

## 3. Create the Raw Data Table

Open `customer_segmentation.sql`.

Execute only **Section 1 — Creating a Table**:

```sql
CREATE TABLE online_retail (
    InvoiceNO VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INTEGER,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC(12,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(100)
);
```

This creates the table structure required to store the dataset.

**Important:** If the table already exists, skip this step. Do not recreate it or reimport data unnecessarily.

## 4. Import the Dataset

The original UCI dataset may need to be saved or converted to CSV before importing into PostgreSQL.

1. In pgAdmin, locate the `online_retail` table.
2. Right-click the table and select **Import/Export Data**.
3. Select **Import**.
4. Choose the prepared CSV file.
5. Set the format to **CSV**.
6. Enable **Header** if the first row contains column names.
7. Set the delimiter to a comma.
8. Select a compatible encoding and import the data.

If UTF-8 encoding causes an import error, `WIN1252` may work for this dataset.

**Date handling:** The source CSV may use the `DD/MM/YYYY HH:MM` format. Ensure PostgreSQL interprets these dates correctly. Converting the CSV date column to the unambiguous `YYYY-MM-DD HH:MM:SS` format before importing is one option.

## 5. Validate the Import

Verify that the expected number of records was imported:

```sql
SELECT COUNT(*) AS total_records
FROM online_retail;
```

**Expected original records:** 541,909

Check the transaction date range:

```sql
SELECT
    MIN(invoicedate) AS first_order,
    MAX(invoicedate) AS last_order
FROM online_retail;
```

Validate the date of a known invoice:

```sql
SELECT
    invoiceno,
    invoicedate
FROM online_retail
WHERE invoiceno = '536365'
LIMIT 5;
```

The invoice date should be **2010-12-01 08:26:00**.

If it is incorrect, fix the imported date interpretation before continuing.

## 6. Execute the SQL Analysis

Open `customer_segmentation.sql` in the pgAdmin Query Tool.

After completing the table creation and CSV import, execute the remaining SQL sections in order.

| Section | Purpose |
|---|---|
| 2. Data Exploration | Identify missing values and invalid transactions |
| 3. Data Cleaning | Create the cleaned transaction view |
| 4. Exploratory Data Analysis | Analyze customers, orders, sales, and purchasing behavior |
| 5. RFM Analysis | Calculate customer-level Recency, Frequency, and Monetary values |
| 6. RFM Scoring | Assign RFM scores using `NTILE(5)` |
| 7. Customer Segmentation | Classify customers into six groups using `CASE WHEN` |
| 8. Final RFM Validation | Check customer counts and sales totals |
| 9. Business Insights | Analyze segment performance and high-value at-risk customers |

**Note:** On an existing database, skip Section 1 to avoid attempting to create an already-existing table.

## 7. Verify the Customer Segmentation

The analysis creates four SQL views:

| View | Purpose |
|---|---|
| `retail_clean` | Cleaned positive purchase transactions |
| `customer_rfm` | Customer-level RFM metrics |
| `rfm_score` | Recency, Frequency, and Monetary scores |
| `customer_segments` | Final six customer segments |

Check that the customer count and sales totals match:

```sql
SELECT
    (SELECT COUNT(DISTINCT customer_id)
     FROM retail_clean) AS total_customers,

    (SELECT COUNT(*)
     FROM customer_segments) AS segmented_customers,

    (SELECT ROUND(SUM(total_amount), 2)
     FROM retail_clean) AS total_sales,

    (SELECT ROUND(SUM(monetary), 2)
     FROM customer_segments) AS segmented_sales;
```

The customer counts should match, and the two sales totals should match.

The original project's analysis identified **4,338 eligible customers**.

## 8. Generate Business Insights

Run the three queries in **Section 9 — Business Insights and Findings**.

### Query 1: Customer Distribution and Sales Contribution

Identifies the number of customers in each segment and their contribution to total gross positive sales.

### Query 2: RFM Behaviour Across Segments

Compares average recency, purchase frequency, and customer spending across segments.

### Query 3: High-Value At-Risk Customers

Identifies historically high-spending customers within the At Risk segment.

These analyses support recommendations for loyalty, reactivation, and personalized marketing strategies.

## 9. Export the Results

To save results from pgAdmin:

1. Run the required SQL query.
2. Locate the **Data Output** panel.
3. Use the export/download option to save results as CSV.
4. Add the exported files to a `results` folder in the repository.

Suggested filenames:

- `segment_distribution.csv`
- `rfm_segment_behavior.csv`
- `at_risk_customers.csv`

Exported results should match the final database analysis.

## 10. Important Considerations

- The data covers historical transactions from 2010–2011.
- Cancelled invoices and nonpositive purchases are excluded.
- Total sales represent positive transaction value, not refund-adjusted net revenue.
- RFM categories reflect relative purchasing behavior rather than confirmed customer churn.
- Marketing recommendations are analytical proposals, not measured campaign outcomes.

## 11. Expected Project Outcome

After completing the analysis, the project should produce:

- A cleaned retail transaction dataset
- Customer-level RFM metrics
- RFM scores from 1 to 5
- Six customer segments
- Segment-wise sales and customer distribution
- Business recommendations focused on retention and customer engagement

The project demonstrates how SQL can turn transactional data into actionable business insights.
