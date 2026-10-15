# Business Insights & Recommendations
## Customer Segmentation and RFM Analysis

### 1. Business Objective

The objective of this analysis was to understand customer purchasing behavior and identify opportunities to improve customer retention and marketing effectiveness.

Using PostgreSQL and RFM (Recency, Frequency, Monetary) analysis, 4,338 customers were classified into six behavioral segments.

The analysis focused on three business questions:

1. Which customer segments contribute the most sales?
2. Which customers are valuable but at risk of becoming inactive?
3. How can the retailer prioritize marketing strategies for different customer groups?

---

### 2. Customer Segmentation Results

| Customer Segment | Customers | Customer % | Gross Sales (£) | Sales % |
|---|---:|---:|---:|---:|
| Champions | 946 | 21.81% | 5,746,144.46 | 64.48% |
| Regular Customers | 1,251 | 28.84% | 948,065.16 | 10.64% |
| Loyal Customers | 505 | 11.64% | 939,911.31 | 10.55% |
| At Risk | 659 | 15.19% | 822,090.05 | 9.23% |
| Hibernating | 668 | 15.40% | 317,631.82 | 3.56% |
| New or Promising | 309 | 7.12% | 137,565.10 | 1.54% |
| **Total** | **4,338** | **100%** | **8,911,407.90** | **100%** |

*Percentages may differ slightly when summed because of rounding. Sales represent positive purchase transactions, excluding cancellations and refunds.*

---

### 3. Key Business Findings

#### Finding 1: A Small Customer Group Generates Most Sales

**946 Champions (21.81% of customers) contributed £5.75 million, representing 64.48% of total gross positive sales.**

This indicates that sales are heavily concentrated among high-value customers.

**Business recommendation:**

Prioritize Champions through:

- VIP loyalty programs
- Exclusive offers and early product access
- Personalized rewards

**Expected business benefit:** Support retention of the retailer's most valuable customers.

#### Finding 2: At-Risk Customers Represent a Significant Retention Opportunity

**659 customers (15.19%) were classified as At Risk, representing £822K in historical sales (9.23%).**

These customers have valuable purchase histories but have not purchased as recently as stronger-performing customer groups.

**Business recommendation:**

- Launch personalized win-back email campaigns.
- Offer relevant incentives based on purchase history.
- Prioritize higher-spending at-risk customers for re-engagement.

**Expected business benefit:** Improve the chances of reactivating previously valuable customers.

#### Finding 3: Regular Customers Form the Largest Segment

**1,251 Regular Customers represented 28.84% of the customer base but contributed only 10.64% of gross sales.**

This suggests an
