-- Show table schema 
\d+ retail;

-- Q1: Show first 10 rows
SELECT * FROM retail limit 10;

-- Q2: Check # of records
SELECT COUNT(*) AS count
FROM retail;

-- Q3: number of clients (e.g. unique client ID)
SELECT COUNT(DISTINCT client_id) AS "Number of Clients"
FROM retail;

-- Q4: invoice date range (e.g. max/min dates)
SELECT
    MAX(invoice_date) AS max_date,
    MIN(invoice_date) AS min_date
FROM retail;

-- Q5: number of SKU/merchants (e.g. unique stock code)
SELECT COUNT(DISTINCT stock_code) AS "Number of SKU"
FROM retail;

-- Q6: Calculate average invoice amount excluding invoices with a negative amount (e.g. canceled orders have negative amount)
SELECT AVG(invoice_sum) AS "Average Invoice Amount"
FROM (
  SELECT SUM(unit_price*quantity) AS invoice_sum
  FROM retail
  GROUP BY invoice_no
  HAVING SUM(unit_price * quantity) > 0
) AS sum_table;

-- Q7: Calculate total revenue (e.g. sum of unit_price * quantity)
SELECT SUM(unit_price * quantity) AS "Total Revenue"
FROM retail;

-- Q8: Calculate total revenue by YYYYMM (we could also use ::int for casting, however here PSQL do the casting internally)
SELECT
    CAST(EXTRACT(YEAR FROM invoice_date) * 100
         + EXTRACT(MONTH FROM invoice_date) AS INTEGER) AS yyyymm,
    SUM(unit_price * quantity) AS "Total Revenue"
FROM retail
GROUP BY yyyymm
ORDER BY yyyymm;
