use supplychain;

-- Top 3 sales executives
Select sales_rep_name,
	round(sum(total_amt_usd) ,2) as totalsale, 
    rank() over(order by sum(total_amt_usd) desc) topseller 
from ftable
group by sales_rep_name
ORDER BY totalsale DESC
limit 3;

-- Sales by month-year and Month-on-Month Cumulative Sales 
select omonth, oyear,totalsale, 
	round(sum(totalsale) over(partition by oyear order by oyear,omonth),2) as momsale
from(
Select omonth, oyear,round(sum(total_amt_usd),2) totalsale from ftable
group by oyear,omonth) t
order by  oyear,omonth;

-- Analyze MOM growth
with month_sale as
(Select oyear,omonth ,round(sum(total_amt_usd),2) totalsale from ftable
group by oyear,omonth
)
select omonth, oyear, totalsale, 
	concat(round((totalsale-lag(totalsale) over(partition by oyear order by omonth))
	/lag(totalsale) over(partition by oyear order by omonth)*100,2),"%") as pct_change
from month_sale;


-- region and product wise sales
select region, round(sum(standard_amt_usd),2) as standard,round(sum(gloss_amt_usd),2) as gloss,
round(sum(poster_amt_usd),2) as poster,round(sum(total_amt_usd),2) as totalsale from ftable
group by region;

-- orders details
select name,count(*) no_of_orders, round(sum(total_amt_usd),2) totalsale from ftable
group by name;

-- channel and monthyear wise sales.
select omonth,oyear,
	round(sum(case when channel="twitter" then total_amt_usd end),2) as Twitter,
	round(sum(case when channel="organic" then total_amt_usd end),2) as Organic,
	round(sum(case when channel="facebook" then total_amt_usd end),2) as Facebook,
	round(sum(case when channel="banner" then total_amt_usd end),2) as Banner,
	round(sum(case when channel="adwords" then total_amt_usd end),2) as Adwords,
	round(sum(case when channel="direct" then total_amt_usd end),2) as Direct,
	round(Sum(total_amt_usd), 2) AS Total
from ftable
group by oyear,omonth
order by oyear,omonth;
