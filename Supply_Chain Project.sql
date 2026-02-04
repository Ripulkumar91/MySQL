USE supplychain;

-- Top 3 sales executives by total sales
SELECT 
    sales_rep_name,
    ROUND(SUM(total_amt_usd), 2) AS total_sales,
    RANK() OVER (ORDER BY SUM(total_amt_usd) DESC) AS top_seller_rank
FROM ftable
GROUP BY sales_rep_name
ORDER BY total_sales DESC
LIMIT 3;

-- Sales by month-year with Month-on-Month Cumulative Sales
SELECT 
    omonth,
    oyear,
    total_sales,
    ROUND(SUM(total_sales) OVER (PARTITION BY oyear ORDER BY oyear, omonth), 2) AS mom_cumulative
FROM (
    SELECT 
        omonth,
        oyear,
        ROUND(SUM(total_amt_usd), 2) AS total_sales
    FROM ftable
    GROUP BY oyear, omonth
) t
ORDER BY oyear, omonth;

-- Month-on-Month growth analysis
WITH month_sales AS (
    SELECT 
        oyear,
        omonth,
        ROUND(SUM(total_amt_usd), 2) AS total_sales
    FROM ftable
    GROUP BY oyear, omonth
)
SELECT 
    omonth,
    oyear,
    total_sales,
    CONCAT(
        ROUND(
            ((total_sales - LAG(total_sales) OVER (PARTITION BY oyear ORDER BY omonth)) /
             LAG(total_sales) OVER (PARTITION BY oyear ORDER BY omonth) * 100),
            2
        ),
        '%'
    ) AS pct_change
FROM month_sales
ORDER BY oyear, omonth;

-- Region and product-wise sales summary
SELECT 
    region,
    ROUND(SUM(standard_amt_usd), 2) AS standard_sales,
    ROUND(SUM(gloss_amt_usd), 2) AS gloss_sales,
    ROUND(SUM(poster_amt_usd), 2) AS poster_sales,
    ROUND(SUM(total_amt_usd), 2) AS total_sales
FROM ftable
GROUP BY region
ORDER BY total_sales DESC;

-- Account-wise orders and sales details
SELECT 
    name AS account_name,
    COUNT(*) AS no_of_orders,
    ROUND(SUM(total_amt_usd), 2) AS total_sales
FROM ftable
GROUP BY name
ORDER BY total_sales DESC;

-- Channel-wise sales by month-year
SELECT 
    omonth,
    oyear,
    ROUND(SUM(CASE WHEN channel = 'twitter' THEN total_amt_usd END), 2) AS Twitter,
    ROUND(SUM(CASE WHEN channel = 'organic' THEN total_amt_usd END), 2) AS Organic,
    ROUND(SUM(CASE WHEN channel = 'facebook' THEN total_amt_usd END), 2) AS Facebook,
    ROUND(SUM(CASE WHEN channel = 'banner' THEN total_amt_usd END), 2) AS Banner,
    ROUND(SUM(CASE WHEN channel = 'adwords' THEN total_amt_usd END), 2) AS Adwords,
    ROUND(SUM(CASE WHEN channel = 'direct' THEN total_amt_usd END), 2) AS Direct,
    ROUND(SUM(total_amt_usd), 2) AS Total
FROM ftable
GROUP BY oyear, omonth
ORDER BY oyear, omonth;
