# Data Dictionary
## Customer Segmentation and RFM Analysis

### 1. Dataset Overview

**Dataset:** UCI Online Retail Dataset  
**Source:** [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/352/online+retail)  
**Database:** PostgreSQL  
**Raw Table:** `online_retail`

The dataset contains 541,909 transaction records from a UK-based online retailer between December 2010 and December 2011.

### 2. Original Dataset Columns

| Column | Data Type | Description |
|---|---|---|
| `invoiceno` | VARCHAR(20) | Unique invoice number identifying a transaction |
| `stockcode` | VARCHAR(20) | Product identification code |
| `description` | TEXT | Product description |
| `quantity` | INTEGER | Number of units purchased |
| `invoicedate` | TIMESTAMP | Date and time of the transaction |
| `unitprice` | NUMERIC(12,2) | Price per product unit in GBP |
| `customerid` | VARCHAR(20) | Unique customer identifier |
| `country` | VARCHAR(100) | Customer's country |

### 3. Cleaned Dataset — `retail_clean`

A SQL view was created to prepare valid purchase transactions for analysis.

**Cleaning rules:**

- Excluded records with missing customer IDs.
- Excluded cancelled invoices beginning with `C`.
- Removed records with zero or negative quantities.
- Removed records with zero or negative unit prices.
- Excluded records with missing invoice numbers or transaction dates.

**Additional calculated column:**

| Column | Description | Calculation |
|---|---|---|
| `total_amount` | Total value of a transaction line | `quantity * unit_price` |

**Note:** The cleaned dataset represents positive purchase transactions. Refunds and cancellations are excluded, so calculated sales do not represent net revenue.

### 4. RFM Metrics — `customer_rfm`

RFM stands for **Recency, Frequency, and Monetary Value**.

Each customer receives three metrics based on their purchase history.

| Metric | Description | SQL Calculation |
|---|---|---|
| `recency_days` | Number of days since the customer's latest purchase | Reference date minus latest purchase date |
| `frequency` | Number of unique orders placed | `COUNT(DISTINCT invoice_no)` |
| `monetary` | Total historical purchase value | `SUM(total_amount)` |

The reference date is calculated as **one day after the latest transaction date** in the cleaned dataset.

**Business interpretation:**

- Lower Recency = More recent purchasing activity
- Higher Frequency = More frequent purchases
- Higher Monetary = Higher historical spending

### 5. RFM Scoring — `rfm_score`

PostgreSQL's `NTILE(5)` window function assigns scores between 1 and 5.

| Score | Recency | Frequency | Monetary |
|---|---|---|---|
| 1 | Least recent | Lower order frequency | Lower spending |
| 2 | Relatively inactive | Relatively low frequency | Relatively low spending |
| 3 | Middle group | Middle group | Middle group |
| 4 | Relatively recent | Relatively high frequency | Relatively
