# Data Dictionary

## Customer Segmentation and RFM Analysis

## 1. Dataset Overview

- **Dataset:** [UCI Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail)
- **Period:** December 2010–December 2011
- **Original records:** 541,909
- **Database:** PostgreSQL
- **Raw table:** `online_retail`

The dataset contains transaction-line records from a UK-based online retailer.

## 2. Original Dataset Columns

| Column | PostgreSQL Type | Description |
|---|---|---|
| `invoiceno` | VARCHAR(20) | Invoice identifier; invoice codes beginning with C indicate cancellations |
| `stockcode` | VARCHAR(20) | Product code |
| `description` | TEXT | Product description |
| `quantity` | INTEGER | Number of units on the transaction line |
| `invoicedate` | TIMESTAMP | Date and time of transaction |
| `unitprice` | NUMERIC(12,2) | Unit price in GBP, as stored in this project |
| `customerid` | VARCHAR(20) | Customer identifier |
| `country` | VARCHAR(100) | Customer country |

## 3. Cleaned Transactions — `retail_clean`

The `retail_clean` SQL view retains transactions meeting the following conditions:

- A nonmissing, nonblank customer ID and invoice number
- A nonmissing invoice date
- Positive quantity and unit price
- An invoice number **not** beginning with `C`

| Output Column | Definition |
|---|---|
| `invoice_no` | Trimmed invoice identifier |
| `stock_code` | Trimmed product code |
| `description` | Product description |
| `quantity` | Purchased units |
| `invoice_date` | Timestamp of purchase |
| `unit_price` | Unit price |
| `customer_id` | Trimmed customer identifier |
| `country` | Country |
| `total_amount` | `ROUND(quantity * unit_price, 2)` |

**Sales definition:** The analysis sums **positive purchase amounts**. It excludes cancellations and refunds; therefore, the resulting sales totals are **not refund-adjusted net revenue**.

## 4. Customer RFM Metrics — `customer_rfm`

One row is calculated per eligible customer.

| Metric | SQL Definition | Interpretation |
|---|---|---|
| `recency_days` | One day after the latest dataset transaction date, minus the customer's last purchase date | Lower = more recent |
| `frequency` | `COUNT(DISTINCT invoice_no)` | Higher = more distinct orders |
| `monetary` | `ROUND(SUM(total_amount), 2)` | Higher = more historical positive spending |

The reference date is based on the dataset, **not today's date**.

## 5. RFM Scores — `rfm_score`

Each metric receives a score from **1 to 5** using PostgreSQL's `NTILE(5)` window function.

| Score | Recency | Frequency | Monetary |
|---|---|---|---|
| 1 | Least recent | Lower frequency | Lower spending |
| 2 | Relatively less recent | Relatively low frequency | Relatively low spending |
| 3 | Middle group | Middle group | Middle group |
| 4 | Relatively recent | Relatively high frequency | Relatively high spending |
| 5 | Most recent | Higher frequency | Higher spending |

- `r_score`: `NTILE(5) OVER (ORDER BY recency_days DESC, customer_id)`
- `f_score`: `NTILE(5) OVER (ORDER BY frequency ASC, customer_id)`
- `m_score`: `NTILE(5) OVER (ORDER BY monetary ASC, customer_id)`

**Limitation:** `NTILE(5)` divides the ranked customers into similarly sized groups and can assign different scores to customers with equal metric values.

## 6. Customer Segments — `customer_segments`

The `CASE WHEN` conditions are checked **in order**, and the first matching rule sets the customer segment.

| Segment | Rule in SQL | Interpretation |
|---|---|---|
| Champions | R ≥ 4, F ≥ 4, M ≥ 4 | Recent, frequent, high-spending customers |
| Loyal Customers | R ≥ 3, F ≥ 4 | Recently or moderately recently active, frequent customers not already Champions |
| New or Promising | R ≥ 4, F ≤ 2 | Recent, relatively infrequent purchasers |
| At Risk | R ≤ 2, F ≥ 3 | Historically frequent customers whose most recent purchase was longer ago |
| Hibernating | R = 1, F ≤ 2 | Least-recent and low-frequency customers |
| Regular Customers | Remaining combinations | Customers who do not meet the earlier rules |

The labels are **behavioral categories**, not verified churn classifications. In particular, `New or Promising` does **not** prove a first-ever purchase.

## 7. Business Analysis Metrics

| Metric | Definition |
|---|---|
| Total Customers | `COUNT(DISTINCT customer_id)` |
| Total Orders | `COUNT(DISTINCT invoice_no)` |
| Total Sales | `SUM(total_amount)` from positive transactions |
| Units Sold | `SUM(quantity)` |
| Average Order Value (AOV) | Total positive sales divided by distinct invoices |
| Customer Percentage | Segment customers divided by all segmented customers × 100 |
| Sales Percentage | Segment monetary sum divided by overall segment monetary sum × 100 |
| Average Recency | `AVG(recency_days)` by segment |
| Average Frequency | `AVG(frequency)` by segment |
| Average Spending | `AVG(monetary)` by segment |

## 8. SQL Views & Results

| View | Purpose |
|---|---|
| `retail_clean` | Valid positive purchase transaction lines |
| `customer_rfm` | Customer-level RFM metrics |
| `rfm_score` | Customer-level 1–5 scores |
| `customer_segments` | Final customer segment label |

Exported query results:
- [Customer segment performance](results/customer_segment_performance.csv)
- [Average RFM behavior by segment](results/rfm_segment_behavior.csv)
- [Top high-value at-risk customers](results/high_value_at_risk_customers.csv)

## 9. Limitations

The data is historical (2010–2011), purchases are gross positive transactions rather than net revenue, and segment labels describe observed relative behavior rather than confirmed churn or realized campaign outcomes.
