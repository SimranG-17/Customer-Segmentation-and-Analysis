# Customer Segmentation & Retention Analysis using PostgreSQL

**SQL Portfolio Project | PostgreSQL | RFM Analysis | Customer Analytics**

## Project Overview

This project analyzes historical purchases from a UK-based online retailer using PostgreSQL and **RFM (Recency, Frequency, Monetary) analysis**. The objective is to understand customer purchasing behavior, identify valuable and potentially inactive groups, and recommend targeted retention strategies.

### Key Results

| Metric | Result |
|---|---:|
| Original transaction records | **541,909** |
| Customers segmented | **4,338** |
| Behavioral segments | **6** |
| Gross positive sales analyzed | **£8,911,407.90** |
| Champions' share of customers | **21.81%** |
| Champions' share of gross sales | **64.48% (£5.75M)** |
| At-risk customers | **659 (15.19%)** |
| Historical purchases from at-risk customers | **£822K (9.23%)** |

## Business Problem

An online retailer needs to know:
1. Which customers contribute the most sales?
2. Which customers purchase recently and frequently?
3. Which historically valuable customers are becoming less active?
4. Which customer groups should marketing teams prioritize for retention, reactivation, or repeat-purchase campaigns?

## Dataset

- **Source:** [UCI Machine Learning Repository – Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail)
- **Period:** December 2010 to December 2011
- **Original records:** 541,909 transaction lines
- **Key fields:** InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country

The source data is not duplicated in this repository; download it from UCI to reproduce the analysis.

## Tools & SQL Skills

**PostgreSQL, pgAdmin 4, SQL**, including cleaning and filtering, aggregate functions, CTEs, views, `GROUP BY`, `CASE WHEN`, and `NTILE(5)` window functions.

## Approach

### 1. Data Quality & Cleaning
- Investigated missing customer IDs, cancelled invoices and nonpositive quantity/price values.
- Kept identifiable customers with valid positive purchase transactions.
- Created `retail_clean` and calculated `total_amount = quantity * unit_price`.
- Validated import dates and compared original versus cleaned row counts.

### 2. Exploratory Data Analysis
- Calculated customer count, order count, total sales, units sold and average order value.
- Examined top-spending customers, monthly sales, one-time versus repeat purchases, and mean versus median customer spending.

### 3. RFM Metrics & Scoring
At the customer level:
- **Recency:** days since the last purchase, measured relative to one day after the latest transaction in the dataset.
- **Frequency:** number of distinct invoices.
- **Monetary:** sum of positive purchase amounts.

Assigned scores from 1 to 5 with `NTILE(5)`. Lower recency is better; higher frequency and monetary values are better.

### 4. Customer Segmentation
Used a `CASE WHEN` hierarchy to assign each customer to one of **Champions, Loyal Customers, New or Promising, At Risk, Hibernating,** or **Regular Customers**.

## Segment Performance

| Segment | Customers | Customer Share | Gross Positive Sales | Sales Share |
|---|---:|---:|---:|---:|
| Champions | 946 | 21.81% | £5,746,144.46 | 64.48% |
| Regular Customers | 1,251 | 28.84% | £948,065.16 | 10.64% |
| Loyal Customers | 505 | 11.64% | £939,911.31 | 10.55% |
| At Risk | 659 | 15.19% | £822,090.05 | 9.23% |
| Hibernating | 668 | 15.40% | £317,631.82 | 3.56% |
| New or Promising | 309 | 7.12% | £137,565.10 | 1.54% |

Percentages are rounded.

## Key Insights & Recommended Actions

**Protect high-value customers:** Champions represent **21.81% of customers but contribute 64.48% of gross positive sales**. Consider VIP benefits and personalized loyalty rewards.

**Re-engage valuable customers:** The **659 At Risk customers** have **£822K in historical purchases** and average **151.4 days since last purchase**. Consider targeted win-back campaigns, prioritizing historically high spenders.

**Encourage repeat purchases:** Regular Customers are the largest segment (**28.84%**) but contribute **10.64% of sales**. Consider product recommendations and relevant repeat-purchase offers.

Read the [detailed business insights](Business_Insights.md) and [segment results](results/customer_segment_performance.csv).

## Project Files

| File | Description |
|---|---|
| [Customer_Segmentation.sql](Customer_Segmentation.sql) | Database setup, cleaning, EDA, RFM scoring, segmentation and business analysis |
| [Business_Insights.md](Business_Insights.md) | Findings and recommended marketing priorities |
| [Data_Dictionary.md](Data_Dictionary.md) | Original fields, calculated measures and segment definitions |
| [Run_Guide.md](Run_Guide.md) | How to import the data and reproduce the SQL analysis |
| [results/](results/) | Three exported SQL result tables |

## Limitations

- Historical data covers 2010–2011 and does not indicate current customer behavior.
- The analysis **excludes cancellations and nonpositive transactions**, so the sales figures represent **gross positive purchase value, not net revenue**.
- RFM segments are relative to the observed customer base and do not prove actual churn. `NTILE(5)` may split tied values across score groups.
- "New or Promising" reflects recent, low-frequency purchasing behavior; it does not guarantee the customer is new.
- Marketing recommendations are **proposals**, not implemented campaigns. No revenue uplift or churn reduction was measured.

## Conclusion

RFM segmentation converted retail transaction data into **six actionable customer groups**, showing substantial sales concentration among Champions and identifying a focused population for potential reactivation. These insights can guide prioritization of customer retention and personalized marketing.

## Author

[SimranG-17 on GitHub](https://github.com/SimranG-17)
