# Customer Lifetime Value and Churn Risk Analysis in a Subscription Business
## Project Overview

This project analyses customer lifetime value (CLV) and churn risk in a B2B SaaS subscription business to understand how customer value is distributed across segments and how churn within those segments impacts overall revenue. The objective is to support data-driven customer prioritisation and targeted retention strategies focused on high-impact segments.

## Business Problem

The business is experiencing customer churn that directly impacts recurring revenue. While growth remains strong, it is unclear which customer segments contribute most to customer lifetime value, which segments contribute least, and where churn poses the greatest revenue risk. The business requires a clear, segment-level view of value concentration and churn impact to prioritise retention efforts effectively.

## Goals

1. Understand how customer value is distributed across customer segments and acquisition cohorts

2. Identify which segments drive the most and least observed CLV

3. Quantify the revenue impact of churn across segments

4. Support targeted, high-impact retention strategies rather than uniform churn reduction

## Key Metrics

#### Primary KPI

-> Customer Lifetime Value (Observed CLV)

#### Core KPIs

-> Customer Churn Rate (by segment and cohort)

-> Revenue Contribution by Segment (share of total CLV)

#### Supporting KPIs

-> Average Revenue Per User (ARPU)

-> Average Revenue per Churned Customer

#### Diagnostic KPIs

-> Cohort-level churn rates

-> Segment-level churn distribution

-> Product usage intensity

-> Support interaction intensity

## Research Question

Which customer segments contributed the most and least to observed customer lifetime value during 2023–2024, and how did customer churn across these segments impact overall business revenue over the same period?

## Dataset

Source: Kaggle – SaaS Subscription and Churn Analytics Dataset
https://www.kaggle.com/datasets/rivalytics/saas-subscription-and-churn-analytics-dataset

The dataset contains multiple related tables covering accounts, subscriptions, product usage, support tickets, and churn events, enabling realistic B2B SaaS analysis.

## Tools Used

1.Excel: Sanity checks, schema validation, spot checks

2.SQL: Data extraction, cleaning, cohort construction, account-level aggregation, CLV and churn metrics

3.Python: Exploratory data analysis, behavioural segmentation, churn and revenue impact analysis

4.Power BI: Executive dashboards to communicate CLV distribution, churn patterns, and revenue risk

## Business Rules & Definitions
1.Customer Churn

-> Defined at the account level using churn_flag from the accounts table

-> Trial and free accounts are excluded

->Subscription-level churn flags and churn events are not used to infer churn timing due to inconsistent alignment with revenue cessation

->Churn events are used only for qualitative context, not churn definition

2.Acquisition Cohorts

->Defined by the month of the first paid subscription start date

->Account-level, month-based (YYYY-MM)

->Used to compare CLV and churn patterns across 2023–2024 cohorts

3.Revenue & CLV

->Revenue sourced from mrr_amount in the subscriptions table

->Revenue aggregated to the account level to avoid double counting

->CLV represents observed cumulative revenue during 2023–2024, not a predictive lifetime estimate

## Data Validation & Preparation

1.Deduplication of account and subscription records

2.Strict null handling for identifiers, dates, and revenue fields

3.Standardisation of categorical values and date formats

4.Validation checks to prevent revenue double counting and churn misclassification

## Exploratory Data Analysis (EDA)

EDA was used to understand value concentration, churn distribution, and behavioural patterns.
Value bands were created for interpretation only to:

1. Understand CLV distribution

2. Validate segmentation outputs

3. Translate analytical results into business language

4. Value bands were not used in K-means clustering to avoid revenue-driven bias.

## SQL Analysis – Key Findings

1.Mid-to-late 2024 acquisition cohorts generated the highest observed CLV but also contributed a disproportionate share of churned revenue, indicating increased revenue fragility during high-growth periods

2.High-value customer churn, while less frequent, resulted in significantly greater absolute revenue loss than low-value churn

3.Enterprise plans generated the most CLV and were operationally efficient relative to revenue, while Basic plans required the highest support effort per revenue unit

4.Churn was not driven solely by low engagement; operational friction and support burden played a significant role

5.Segmentation & Deep Analysis (K-Means)

6.Customers were segmented using behavioural, revenue, and support-related features.

### K-Means Segment Summary

#### Low-Value, Low-Engagement Customers

-->Low CLV, expected churn

-->Limited retention ROI

#### High-Value, Highly Engaged Customers

-->Highest CLV contribution

-->Moderate churn risk

#### Engaged but Friction-Prone Customers (Highest Risk)

-->Strong usage and feature adoption

-->High support escalations and highest churn rates

-->Largest preventable revenue risk

#### Support-Dependent, Loyal Customers

-->Moderate CLV

-->High support usage but lowest churn

This segmentation confirmed that churn risk is not linear with customer value and that the most damaging churn occurs among engaged customers experiencing friction.

## Insight Synthesis

1.High-value and highly engaged segments drive most observed CLV but also account for a disproportionate share of churned revenue

2.Recent acquisition cohorts show strong CLV growth but increasing revenue volatility

3.The greatest revenue risk stems from engaged, friction-prone customers, not disengaged low-value users

## Recommendations

1.Prioritise proactive retention for engaged but friction-prone customers through customer success outreach and issue resolution

2.Reinforce value and loyalty among high-value, highly engaged customers

3.Improve self-service and support efficiency for support-dependent customers

4.Apply lightweight, automated retention strategies for low-value, low-engagement customers

## Conclusion

This analysis demonstrates that revenue risk in subscription businesses is driven less by low-value churn and more by churn among engaged, high-value customers experiencing operational friction. By combining cohort analysis, behavioural segmentation, and revenue-focused metrics, the project highlights how targeted retention strategies can protect long-term customer value more effectively than acquisition-led growth alone.
