-- ============================================================
-- CUSTOMER SEGMENTATION & RETENTION ANALYSIS
-- PostgreSQL | RFM Analysis
-- Dataset: UCI Online Retail
-- ============================================================


-- ============================================================
-- 1. CREATING A TABLE
-- ============================================================

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

-- Import the UCI Online Retail CSV into this table.
-- If the table already exists, do not rerun CREATE TABLE.


-- ============================================================
-- 2. DATA EXPLORATION
-- ============================================================

-- 2.1 TOTAL NUMBER OF RECORDS

SELECT COUNT(*) AS total_records
FROM online_retail;


-- 2.2 CHECK MISSING VALUES

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE customerid IS NULL
           OR TRIM(customerid::TEXT) = ''
    ) AS missing_customer_ids,

    COUNT(*) FILTER (
        WHERE description IS NULL
    ) AS missing_descriptions,

    COUNT(*) FILTER (
        WHERE invoicedate IS NULL
    ) AS missing_dates

FROM online_retail;


-- 2.3 CHECK CANCELLED OR INVALID TRANSACTIONS

SELECT
    COUNT(*) FILTER (
        WHERE UPPER(invoiceno::TEXT) LIKE 'C%'
    ) AS cancelled_transactions,

    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS invalid_quantities,

    COUNT(*) FILTER (
        WHERE unitprice <= 0
    ) AS invalid_prices

FROM online_retail;


-- ============================================================
-- 3. DATA CLEANING AND VALIDATION
-- ============================================================

-- 3.1 CHECK THE FIRST AND LAST TRANSACTION DATE

SELECT
    MIN(invoicedate) AS first_order,
    MAX(invoicedate) AS last_order
FROM online_retail;


-- 3.2 CHECK INVOICE DATE
-- Invoice 536365 should show 2010-12-01 08:26:00.

SELECT
    invoiceno,
    invoicedate
FROM online_retail
WHERE invoiceno::TEXT = '536365'
LIMIT 5;


-- 3.3 CREATE A CLEAN DATA VIEW

CREATE OR REPLACE VIEW retail_clean AS
SELECT
    TRIM(invoiceno::TEXT) AS invoice_no,
    TRIM(stockcode::TEXT) AS stock_code,
    description,
    quantity,
    invoicedate AS invoice_date,
    unitprice::NUMERIC AS unit_price,
    TRIM(customerid::TEXT) AS customer_id,
    country,

    ROUND(
        quantity::NUMERIC * unitprice::NUMERIC,
        2
    ) AS total_amount

FROM online_retail

WHERE customerid IS NOT NULL
  AND TRIM(customerid::TEXT) <> ''
  AND invoiceno IS NOT NULL
  AND TRIM(invoiceno::TEXT) <> ''
  AND invoicedate IS NOT NULL
  AND quantity > 0
  AND unitprice > 0
  AND UPPER(TRIM(invoiceno::TEXT)) NOT LIKE 'C%';


-- 3.4 VALIDATE THE CLEAN RECORDS

SELECT
    (SELECT COUNT(*)
     FROM online_retail) AS raw_records,

    (SELECT COUNT(*)
     FROM retail_clean) AS cleaned_records,

    (SELECT COUNT(*)
     FROM online_retail)
    -
    (SELECT COUNT(*)
     FROM retail_clean) AS excluded_records;


-- 3.5 CHECK REMAINING INVALID RECORDS

SELECT
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customers,

    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS invalid_quantity,

    COUNT(*) FILTER (
        WHERE unit_price <= 0
    ) AS invalid_price,

    COUNT(*) FILTER (
        WHERE invoice_date IS NULL
    ) AS missing_dates

FROM retail_clean;


-- 3.6 CHECK POSSIBLE DUPLICATE RECORDS
-- Diagnostic check only: matching rows are not automatically removed.

SELECT
    invoice_no,
    stock_code,
    customer_id,
    quantity,
    unit_price,
    invoice_date,
    COUNT(*) AS duplicate_count

FROM retail_clean

GROUP BY
    invoice_no,
    stock_code,
    customer_id,
    quantity,
    unit_price,
    invoice_date

HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;


-- ============================================================
-- 4. EXPLORATORY DATA ANALYSIS (EDA)
-- ============================================================

-- 4.1 OVERALL BUSINESS PERFORMANCE

SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(total_amount), 2) AS total_sales,
    SUM(quantity) AS total_quantity_sold,
    COUNT(DISTINCT invoice_no) AS total_orders,

    ROUND(
        SUM(total_amount) /
        NULLIF(COUNT(DISTINCT invoice_no), 0),
        2
    ) AS average_order_value

FROM retail_clean;


-- 4.2 TOP 10 HIGHEST-SPENDING CUSTOMERS

SELECT
    customer_id,
    ROUND(SUM(total_amount), 2) AS total_spending

FROM retail_clean

GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 10;


-- 4.3 MONTHLY SALES REVENUE ANALYSIS

SELECT
    DATE_TRUNC('month', invoice_date) AS sales_month,
    ROUND(SUM(total_amount), 2) AS monthly_sales

FROM retail_clean

GROUP BY sales_month
ORDER BY sales_month ASC;


-- 4.4 ONE-TIME VS REPEAT CUSTOMERS

WITH customer_orders AS (

    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS total_orders

    FROM retail_clean
    GROUP BY customer_id

),

customer_classification AS (

    SELECT
        customer_id,
        total_orders,

        CASE
            WHEN total_orders = 1
                THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type

    FROM customer_orders

)

SELECT
    customer_type,
    COUNT(*) AS total_customers

FROM customer_classification

GROUP BY customer_type
ORDER BY total_customers DESC;


-- 4.5 AVERAGE AND MEDIAN CUSTOMER SPENDING

WITH customer_spending AS (

    SELECT
        customer_id,
        SUM(total_amount) AS total_spending

    FROM retail_clean
    GROUP BY customer_id

)

SELECT
    ROUND(AVG(total_spending), 2) AS avg_spending,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total_spending)::NUMERIC,
        2
    ) AS median_customer_spending

FROM customer_spending;


-- ============================================================
-- 5. RFM ANALYSIS
-- ============================================================

-- 5.1 RECENCY, FREQUENCY AND MONETARY METRICS
--
-- Recency: Days since last purchase
-- Frequency: Number of unique orders
-- Monetary: Total historical spending
--
-- Reference date: One day after the latest transaction


CREATE OR REPLACE VIEW customer_rfm AS

WITH customer_metrics AS (

    SELECT
        customer_id,
        MAX(invoice_date)::DATE AS last_purchase_date,
        COUNT(DISTINCT invoice_no) AS frequency,
        ROUND(SUM(total_amount), 2) AS monetary

    FROM retail_clean

    GROUP BY customer_id

)

SELECT
    customer_id,

    (
        SELECT MAX(invoice_date)::DATE + 1
        FROM retail_clean
    ) - last_purchase_date AS recency_days,

    frequency,
    monetary

FROM customer_metrics;


-- 5.2 VALIDATE THE RFM METRICS

SELECT *
FROM customer_rfm
ORDER BY customer_id
LIMIT 10;


-- ============================================================
-- 6. RFM SCORING
-- ============================================================

-- Assign scores from 1 to 5 using NTILE(5).
-- Higher R, F and M scores indicate better customer behavior.

CREATE OR REPLACE VIEW rfm_score AS

SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,

    -- RECENCY SCORE
    NTILE(5) OVER (
        ORDER BY recency_days DESC, customer_id
    ) AS r_score,

    -- FREQUENCY SCORE
    NTILE(5) OVER (
        ORDER BY frequency ASC, customer_id
    ) AS f_score,

    -- MONETARY SCORE
    NTILE(5) OVER (
        ORDER BY monetary ASC, customer_id
    ) AS m_score

FROM customer_rfm;


-- ============================================================
-- 7. CUSTOMER SEGMENTATION USING RFM SCORES
-- ============================================================

CREATE OR REPLACE VIEW customer_segments AS

SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,

    CASE

        WHEN r_score >= 4
         AND f_score >= 4
         AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3
         AND f_score >= 4
            THEN 'Loyal Customers'

        WHEN r_score >= 4
         AND f_score <= 2
            THEN 'New or Promising'

        WHEN r_score <= 2
         AND f_score >= 3
            THEN 'At Risk'

        WHEN r_score = 1
         AND f_score <= 2
            THEN 'Hibernating'

        ELSE 'Regular Customers'

    END AS customer_segment

FROM rfm_score;


-- ============================================================
-- 8. FINAL RFM SEGMENTATION VALIDATION
-- ============================================================

-- Verify that customer counts and sales totals match.

SELECT
    (SELECT COUNT(DISTINCT customer_id)
     FROM retail_clean) AS total_customers,

    (SELECT COUNT(*)
     FROM customer_segments) AS segmented_customers,

    (SELECT ROUND(SUM(total_amount), 2)
     FROM retail_clean) AS total_sales,

    (SELECT ROUND(SUM(monetary), 2)
     FROM customer_segments) AS segmented_sales;


-- ============================================================
-- 9. BUSINESS INSIGHTS AND FINDINGS
-- ============================================================

-- 9.1 CUSTOMER DISTRIBUTION AND SALES CONTRIBUTION BY SEGMENT
--
-- Business Question:
-- Which customer segments contribute the most sales?


SELECT
    customer_segment,
    COUNT(*) AS total_customers,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,

    ROUND(
        SUM(monetary),
        2
    ) AS total_sales,

    ROUND(
        100.0 * SUM(monetary) /
        NULLIF(SUM(SUM(monetary)) OVER (), 0),
        2
    ) AS sales_percentage

FROM customer_segments

GROUP BY customer_segment
ORDER BY total_sales DESC;


-- 9.2 RFM BEHAVIOUR ACROSS CUSTOMER SEGMENTS
--
-- Business Question:
-- How do customer segments differ in purchasing behavior?


SELECT
    customer_segment,
    ROUND(AVG(recency_days), 1) AS avg_recency,
    ROUND(AVG(frequency), 1) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_spending

FROM customer_segments

GROUP BY customer_segment
ORDER BY avg_spending DESC;


-- 9.3 TOP 10 HIGH-VALUE AT-RISK CUSTOMERS
--
-- Business Question:
-- Which historically valuable customers may need
-- targeted reactivation campaigns?


SELECT
    customer_id,
    recency_days,
    frequency,
    monetary

FROM customer_segments

WHERE customer_segment = 'At Risk'

ORDER BY monetary DESC
LIMIT 10;


-- ============================================================
-- END OF CUSTOMER SEGMENTATION PROJECT
-- ============================================================

