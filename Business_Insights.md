# Business Insights & Recommendations

## Customer Segmentation and RFM Analysis

## 1. Business Objective

Use PostgreSQL and RFM (Recency, Frequency, Monetary) analysis to understand purchasing behavior, identify valuable customer groups and suggest where a UK-based online retailer could focus its marketing resources.

**Scope:** **4,338** eligible customers segmented into **six groups** from the historical UCI Online Retail dataset.

**Business questions:**
1. Which customer segments contribute the most sales?
2. Which historically valuable customers show signs of inactivity?
3. Which marketing strategies could help the retailer retain and engage customers?

## 2. Customer Segmentation Results

| Customer Segment | Customers | Customer % | Gross Positive Sales (£) | Sales % |
|---|---:|---:|---:|---:|
| Champions | 946 | 21.81% | 5,746,144.46 | 64.48% |
| Regular Customers | 1,251 | 28.84% | 948,065.16 | 10.64% |
| Loyal Customers | 505 | 11.64% | 939,911.31 | 10.55% |
| At Risk | 659 | 15.19% | 822,090.05 | 9.23% |
| Hibernating | 668 | 15.40% | 317,631.82 | 3.56% |
| New or Promising | 309 | 7.12% | 137,565.10 | 1.54% |
| **Total** | **4,338** | **100.00%** | **8,911,407.90** | **100.00%** |

*Segment percentages are individually rounded. Sales include positive purchase transactions only, not refund-adjusted net revenue.*

**Source:** [Customer segment performance CSV](results/customer_segment_performance.csv).

## 3. Key Findings

### Finding 1 — Champions Generate Most Historical Sales

**946 Champions (21.81% of customers) generated £5.75M, or 64.48% of gross positive sales.**

Champions also made an average of **11.2 orders** per customer and had an average recency of **13.1 days**.

**Recommendation:** Prioritize loyalty rewards, tailored recognition and exclusive offers for these high-value customers.

**Decision supported:** Protect the segment associated with the largest share of historical purchases.

### Finding 2 — At-Risk Customers Offer a Reactivation Opportunity

**659 At Risk customers (15.19%) account for £822,090.05 in historical purchase value, or 9.23% of sales.**

Their average recency is **151.4 days**, compared with **13.1 days for Champions**. Their average historical spending is **£1,247.48 per customer**.

**Recommendation:** Prioritize targeted win-back campaigns for the highest-spending customers in this segment, testing personalized messages and relevant offers.

**Decision supported:** Focus reactivation resources on customers with meaningful historical value rather than targeting everyone equally.

### Finding 3 — Regular Customers Are the Largest Group

**1,251 Regular Customers (28.84%) contributed 10.64% of gross positive sales.** Their average purchase frequency is **1.6 orders**, compared with **11.2 orders for Champions**.

**Recommendation:** Test repeat-purchase incentives, product recommendations and targeted promotions designed to build stronger purchasing habits.

**Decision supported:** Look for opportunities to increase repeat purchasing within the largest segment.

### Finding 4 — Loyal Customers Represent an Existing Relationship to Strengthen

**505 Loyal Customers (11.64%) contributed £939,911.31 (10.55% of sales)** and averaged **5.2 orders** per customer.

**Recommendation:** Consider referral rewards, loyalty tiers and complementary product recommendations.

### Finding 5 — Low-Frequency Recent Customers May Need Nurturing

**309 New or Promising Customers (7.12%) generated £137,565.10 (1.54% of sales)** and averaged **1.2 orders** per customer.

**Recommendation:** Explore second-purchase offers or follow-up recommendations.

*This segment is recent and low-frequency; it does not necessarily consist entirely of first-time customers.*

### Finding 6 — Hibernating Customers Show Long Purchase Gaps

**668 Hibernating Customers (15.40%) contributed 3.56% of historical sales** and averaged **278.0 days** since their last purchase.

**Recommendation:** Try limited, low-cost re-engagement tests before committing substantial marketing spend.

**Source:** [Average RFM behavior by segment](results/rfm_segment_behavior.csv).

## 4. Suggested Marketing Priorities

| Priority | Segment | Proposed action | Rationale |
|---|---|---|---|
| 1 | Champions | VIP loyalty and personalized retention | 64.48% of gross positive sales |
| 2 | At Risk | Targeted win-back offers | 659 customers associated with £822K in prior purchases |
| 3 | Regular Customers | Repeat-purchase incentives | Largest group, average 1.6 orders |
| 4 | Loyal Customers | Referrals and cross-selling | Average 5.2 orders |
| 5 | New or Promising | Second-purchase nurturing | Average 1.2 orders |
| 6 | Hibernating | Low-cost reactivation experiments | Average 278.0 days since last purchase |

The [top 10 highest-spending At Risk customers](results/high_value_at_risk_customers.csv) are an example of a prioritized reactivation shortlist. This is an analytical example using a public research dataset, not a live CRM contact list.

## 5. Conclusion

RFM analysis categorized **4,338 customers** into six groups and revealed that a relatively small share of customers generated most historical positive sales. It also identified **659 At Risk customers** with substantial previous purchase value, supporting a focused approach to customer retention and reactivation.

These findings can guide **proposed** marketing priorities; they do not establish that any proposed campaign improved results.

## 6. Limitations

- Transaction history covers 2010–2011.
- Cancelled and nonpositive transactions were excluded, so purchase values are **not net revenue**.
- Segments reflect **relative RFM behavior** and do not prove churn or future purchases.
- Scores use `NTILE(5)`, which may split tied values across scoring groups.
- No marketing intervention was implemented or measured; outcomes are **recommendations, not demonstrated uplift**.
