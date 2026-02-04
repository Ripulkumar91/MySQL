USE supplychain;
SET SQL_SAFE_UPDATES = 0;

-- Cleaning web_events table: Convert data string to date format
UPDATE web_events
SET occurred_at = STR_TO_DATE(occurred_at, '%Y-%m-%dT%H:%i:%s.%fZ');

ALTER TABLE web_events
MODIFY COLUMN occurred_at DATETIME;

-- Cleaning orders table: Convert date string to date, handle missing values
UPDATE orders
SET occurred_at = STR_TO_DATE(occurred_at, '%Y-%m-%dT%H:%i:%s.%fZ'),
    standard_qty = IF(standard_qty = '', 0, standard_qty),
    gloss_qty = IF(gloss_qty = '', 0, gloss_qty),
    poster_qty = IF(poster_qty = '', 0, poster_qty);

ALTER TABLE orders
MODIFY COLUMN occurred_at DATETIME,
    MODIFY COLUMN standard_qty INT,
    MODIFY COLUMN gloss_qty INT,
    MODIFY COLUMN poster_qty INT;

-- Calculate total quantity and update amounts
UPDATE orders
SET total = poster_qty + gloss_qty + standard_qty
WHERE total = '';

ALTER TABLE orders
MODIFY COLUMN total INT,
    MODIFY COLUMN standard_amt_usd DOUBLE,
    MODIFY COLUMN gloss_amt_usd DOUBLE,
    MODIFY COLUMN poster_amt_usd DOUBLE,
    MODIFY COLUMN total_amt_usd DOUBLE;

-- Analyze Non-Ordering Accounts
SELECT a.name
FROM accounts a
LEFT JOIN orders o ON a.id = o.account_id
WHERE o.account_id IS NULL;

-- Analyze sales representatives with no accounts
SELECT sr.name
FROM sales_rep sr
LEFT JOIN accounts a ON sr.id = a.sales_rep_id
WHERE a.sales_rep_id IS NULL;

-- Recreate ftable view with proper joins
DROP VIEW IF EXISTS ftable;

CREATE VIEW ftable AS
SELECT 
    o.id,
    o.account_id,
    YEAR(o.occurred_at) AS oyear,
    MONTH(o.occurred_at) AS omonth,
    o.occurred_at,
    o.standard_qty,
    o.gloss_qty,
    o.poster_qty,
    o.total,
    o.standard_amt_usd,
    o.gloss_amt_usd,
    o.poster_amt_usd,
    o.total_amt_usd,
    r.name AS region,
    a.name AS account_name,
    a.website,
    a.lat,
    a.long,
    a.primary_poc,
    sr.name AS sales_rep_name,
    we.channel
FROM orders o
INNER JOIN accounts a ON o.account_id = a.id
INNER JOIN sales_rep sr ON a.sales_rep_id = sr.id
INNER JOIN region r ON sr.region_id = r.id
INNER JOIN web_events we ON we.account_id = o.account_id 
    AND we.occurred_at = o.occurred_at;
