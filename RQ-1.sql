use CRM;
#Data Cleaning
#1. The sign-up date in accounts should be <= first start_date in the subscription table
#for all sunscriptions that are not free trial 
select * from accounts as acc
left join 
(select account_id,  min(str_to_date(start_date , '%d/%m/%Y') )as first_start_date  from subscriptions
where is_trial ='FALSE'
group by account_id) as subs on acc.account_id = subs.account_id
where str_to_date(signup_date, '%d/%m/%Y') > first_start_date;

#2. Every account id in subscriptions table should exists in the account table
select distinct account_id from subscriptions where account_id not in (
select  account_id from accounts);

#3. Every account id in chrun events table should exist in account table
select distinct account_id from churn_events where account_id not in  (
select account_id from accounts);

## Data Analysis
#1. Which acquisition cohorts drives the highest CLV, and which cause the highest churn revenue as well?
with acq as (
select  cohort, churn_flag,  sum(clv) as total_clv from (
select  date_format(first_start_date, '%Y-%m') as cohort, churn_flag, clv  from (
select  account_id, min(str_to_date(start_date , '%d/%m/%Y'))as first_start_date, churn_flag ,
sum(mrr_amount) as clv
  from subscriptions
  where subscriptions.is_trial = 'FALSE'
  group by account_id, churn_flag 
  ) as a
  ) as b
  group by cohort, churn_flag)
  
  select *, rank() over( order by active_revenue desc) as active_revenue_rank,
  rank() over( order by churned_revenue desc) as churned_revenue_rank from (
  select cohort, sum(case when churn_flag ='FALSE' then total_clv else 0 end) as active_revenue,
   sum(case when churn_flag ='TRUE' then total_clv else 0 end) as churned_revenue
  from acq
  group by cohort) as c
  order by cohort;
  
  # Acquisition cohorts from mid-to-late 2024 contribute the highest observed CLV, but they also account for a disproportionate share of churned revenue. This indicates that recent high-growth cohorts are driving revenue scale but exhibit higher revenue fragility
  
  #2. How much revenue is at risk due to churned high-value accounts compared to low-value accounts?

  select band_value, churn_flag ,sum(clv) as total_clv from (
  select a.account_id, churn_flag, clv, 
  case when clv <=18800 then 'low-value'
  when clv >18801 and clv <=26000 then 'mid-value'
  when clv > 26001 and clv <=45000 then 'high-value'
  when clv >45001 then 'very-high-value' 
  else 'NA' 
  end as band_value
  from accounts as a 
  join 
  (select account_id, sum(mrr_amount) as clv
  from subscriptions 
    where subscriptions.is_trial = 'FALSE'
  group by account_id)
as subs  on a.account_id =subs.account_id
) as a
where band_value in ('low-value','high-value') and churn_flag='TRUE'
group by churn_flag, band_value;

#Although low-value customers churn more frequently, high-value churn represents a significantly larger absolute revenue risk, making retention of high-value accounts a higher business priority.

#3. Do customers with unresolved support escalations contribute disproportionately to revenue churn?
with tab1 as ( 
 select accounts.account_id, total_escalations, clv, churn_flag from accounts join ( 
select subs.account_id, sum(escalations) as total_escalations, sum(mrr_amount) as clv
 from subscriptions  as subs 
   
join 
(select account_id, sum(case when escalation_flag ="TRUE" then 1 else 0 end) as escalations
 from support_tickets
 group by account_id) as support on subs.account_id =support.account_id
 where subs.is_trial = 'FALSE'
 group by account_id
 ) as b on accounts.account_id = b.account_id
 )


select *, round((total_clv/sum(total_clv) over() ) * 100,2)as 'clv_pct',
round((accounts/sum(accounts) over() )*100,2) as 'acct_pct'
 from (
select num_escalations, churn_flag, sum(clv) as total_clv, count(account_id) as accounts 
from(
select *, case when total_escalations=0 then " 0 Escalations"
when total_escalations>0 then "1 or more Escalations"
end as num_escalations from tab1) as c
group by num_escalations, churn_flag) as x ;

#slightly disproportionate revenue churn contribution in customers with 0 escalations and customers with >1 escalations

#4. Which acquisition cohorts contributed the most to total churned revenue?
with tab2 as (
select cohort,  sum(clv) as total_clv, count(account_id) as accounts_churned from (
select accounts.account_id, date_format(first_start_date, '%Y-%m') as cohort, accounts.churn_flag,
clv from (
select  account_id, min(str_to_date(start_date , '%d/%m/%Y') )as first_start_date,
sum(mrr_amount) as clv
  from subscriptions
  group by account_id
  ) as a
join accounts on a.account_id = accounts.account_id
 where accounts.churn_flag='TRUE'
) as b
group by cohort
) 

select *, round((total_clv / (select sum(total_clv) from tab2 )) *100,2) as churn_pct
  from tab2
  order by churn_pct desc;
# Cohorts acquired in mid-to-late 2024, particularly September 2024, contributed the largest share of churned revenue, indicating higher revenue volatility among recent acquisition cohorts.

#5. Which plan tiers generate high CLV but also require disproportionately high operational effort?
SELECT
  s.plan_tier,
  COUNT(DISTINCT s.account_id) AS customers,
  SUM(s.mrr_amount) AS total_clv,
  AVG(s.mrr_amount) AS avg_mrr,

  count(st.ticket_id) AS total_tickets,
  count(st.escalation_flag) AS total_escalations,
  AVG(st.resolution_time_hours) AS avg_resolution_time,
  
   count(st.ticket_id) / COUNT(DISTINCT s.account_id) AS tickets_per_customer,
  count(st.ticket_id) / SUM(s.mrr_amount) AS tickets_per_revenue_unit

FROM subscriptions s
LEFT JOIN support_tickets st
  ON s.account_id = st.account_id
WHERE s.is_trial = 'FALSE'
GROUP BY s.plan_tier
ORDER BY total_clv DESC;

#Enterprise drives the most CLV and appears operationally efficient relative to revenue (lowest tickets-per-revenue). Basic generates the least CLV but requires the highest support effort per revenue unit, indicating higher cost-to-serve pressure in lower tiers.

 


 

