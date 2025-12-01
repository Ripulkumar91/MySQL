use supplychain;
SET SQL_SAFE_UPDATES = 0;
-- Cleaning web_events table, convert data string to date format
update web_events
set occurred_at=str_to_date(occurred_at,'%Y-%m-%dT%H:%i:%s.%fZ');
alter table web_events
modify column occurred_at datetime;

-- Cleaning orders table, convert data string to date, handling missing value and cast to int and double
update orders
set occurred_at=str_to_date(occurred_at,'%Y-%m-%dT%H:%i:%s.%fZ'),
	standard_qty= if(standard_qty="",0,standard_qty),
	gloss_qty= if(gloss_qty="",0,gloss_qty),
    poster_qty= if(poster_qty="",0,poster_qty);
    
alter table orders
modify column occurred_at datetime,
modify column poster_qty int, 
modify column gloss_qty int,
modify column standard_qty int;

update orders
set total= poster_qty+gloss_qty+standard_qty
where total ="";

alter table orders
modify column total int,
modify column standard_amt_usd double,
modify column gloss_amt_usd double,
modify column poster_amt_usd double,
modify column total_amt_usd double;

-- Analyze Non-Ordering Accounts
Select a.name from accounts a left join orders o
on a.id=o.account_id
where o.account_id is null;

-- analyze sales_representative with no sale
select sr.name from sales_rep sr left join accounts a
on sr.id=a.sales_rep_id
where a.sales_rep_id is null;

drop view ftable ;
create view ftable as
(select o.id,o.account_id,Year(o.occurred_at) as oyear,Month(o.occurred_at) as omonth,o.occurred_at,o.standard_qty,o.gloss_qty,o.poster_qty,
o.total,o.standard_amt_usd,o.gloss_amt_usd,o.poster_amt_usd,o.total_amt_usd,
r.name as region, a.name,a.website,a.lat,a.long,a.primary_poc,sr.name as sales_rep_name,we.channel
from orders o join accounts a 
on  o.account_id=a.id join sales_rep sr
on a.sales_rep_id= sr.id join region r
on sr.region_id=r.id join web_events we
on (we.account_id&we.occurred_at)=(o.account_id&o.occurred_at));