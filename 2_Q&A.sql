--- Q&A STEP ---

--Top 10 stores per transacted amount--------------------------------
SELECT TOP 10
	b.store_id, SUM(a.amount) sum_amount
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id		
	WHERE tr_status = 'accepted'
	GROUP BY store_id
	ORDER BY SUM(a.amount) DESC;

--Top 10 products sold-----------------------------------------------
--First we check if SKUs are unique to stores
SELECT
	a.product_sku, COUNT(DISTINCT b.store_id) count_distinct_stores
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id
	WHERE tr_status = 'accepted'
	GROUP BY a.product_sku;

--Secondly whe check if SKUs and Product Names are unique combinations for each store
SELECT a.product_sku, b.store_id,
	COUNT(DISTINCT a.product_name) count_distinct_product_name
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id
	WHERE tr_status = 'accepted'
	GROUP BY a.product_sku, b.store_id;

--Assuming SKU+Store are correct uniqueness identifiers, Top 10 products sold by AMOUNT
SELECT TOP 10
	a.product_sku, b.store_id,
	SUM(a.amount) sum_amount
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id
	WHERE tr_status = 'accepted'
	GROUP BY a.product_sku, b.store_id
	ORDER BY SUM(a.amount) DESC;

--Assuming SKU+Store are correct uniqueness identifiers, Top 10 products sold by N° of TRANSACTIONS
SELECT TOP 10
	a.product_sku, b.store_id,
	COUNT(DISTINCT a.tr_id) count_tr_id
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id
	WHERE tr_status = 'accepted'
	GROUP BY a.product_sku, b.store_id
	ORDER BY COUNT(DISTINCT a.tr_id) DESC;

--Average transacted amount per store typology and country-----------
SELECT c.typology, SUM(a.amount) sum_amount
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id
	LEFT JOIN Store c
		ON b.store_id = c.store_id
	WHERE tr_status = 'accepted'
	GROUP BY c.typology
	ORDER BY SUM(a.amount) DESC;

SELECT c.country, SUM(a.amount) sum_amount
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id
	LEFT JOIN Store c
		ON b.store_id = c.store_id
	WHERE tr_status = 'accepted'
	GROUP BY c.country
	ORDER BY SUM(a.amount) DESC;

--Percentage of transactions per device type-------------------------
WITH Tr_agg AS
	(SELECT CAST(COUNT(DISTINCT tr_id) AS FLOAT) total_tr
		FROM Transactions
		WHERE tr_status = 'accepted')
SELECT b.device_type, COUNT(DISTINCT a.tr_id) count_tr_id,
	COUNT(DISTINCT a.tr_id)*100/c.total_tr percentage_of_transactions
FROM Transactions a
	LEFT JOIN Device b
		ON a.device_id = b.device_id
	LEFT JOIN Tr_agg c
		ON 1 = 1
	WHERE tr_status = 'accepted'
	GROUP BY b.device_type, c.total_tr
	ORDER BY COUNT(DISTINCT a.tr_id) DESC;

--Average time for a store to perform its 5 first transactions-------
WITH RankedTransactions AS (
    SELECT b.store_id, a.happened_at,
        ROW_NUMBER() OVER (PARTITION BY b.store_id ORDER BY a.happened_at) AS rn
    FROM Transactions a
		LEFT JOIN Device b ON a.device_id = b.device_id
		WHERE tr_status = 'accepted'),
StoresWithFive AS (
    SELECT b.store_id,
        COUNT(*) AS transaction_count
    FROM Transactions a
		LEFT JOIN Device b ON a.device_id = b.device_id
		WHERE tr_status = 'accepted'
		GROUP BY b.store_id
		HAVING COUNT(*) >= 5),
StoreTimes AS (
SELECT store_id,
    MAX(CASE WHEN rn = 1 THEN happened_at END) first_tr_timestamp,
    MAX(CASE WHEN rn = 5 THEN happened_at END) fifth_tr_timestamp,
	DATEDIFF(MINUTE, MAX(CASE WHEN rn = 1 THEN happened_at END), 
		MAX(CASE WHEN rn = 5 THEN happened_at END))/CAST(24*60 AS FLOAT) time_between
FROM RankedTransactions a
	WHERE store_id IN (SELECT store_id FROM StoresWithFive)
	GROUP BY store_id)
SELECT AVG(time_between) AverageTimeBetween --In Days
	FROM StoreTimes;



