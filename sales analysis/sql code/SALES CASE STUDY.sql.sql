SELECT
  *
FROM
  "SALES_DATA"."PUBLIC"."SALES"
LIMIT
  10;
---------------------------------------------------------------------------------------------------------------covert ate column

CREATE OR REPLACE VIEW SALES_DATA.Public.SALES_CLEAN AS
SELECT
    TO_DATE(DATE, 'DD/MM/YYYY') AS DATE,
    SALES,
    COST_OF_SALES,
    QUANTITY_SOLD
FROM SALES_DATA.PUBLIC.SALES;

SELECT *
FROM SALES_DATA.PUBLIC.SALES_CLEAN
LIMIT 10;


-------------------------------------------------------------------------------------------------------------
-- DAILY SALES PRICE PER UNIT

SELECT 
    DATE,
    SALES,
    QUANTITY_SOLD,
    (SALES/QUANTITY_SOLD) AS DAILY_SALES_PRICE_PER_UNIT
FROM SALES_DATA.PUBLIC.SALES_CLEAN
ORDER BY DATE;

-------------------------------------------------------------------------------------------------------------
-- AVERAGE UNIT SALES PRICE

SELECT 
    SUM(SALES) / SUM (QUANTITY_SOLD) AS AVG_UNIT_SALES_PRICE
FROM SALES_DATA.PUBLIC.SALES_CLEAN;

-------------------------------------------------------------------------------------------------------------
--DAILY % GROSS PROFIT

SELECT
    DATE,
    SALES,
    COST_OF_SALES,
    (SALES - COST_OF_SALES) AS DAILY_GROSS_PROFIT
FROM SALES_DATA.PUBLIC.SALES_CLEAN
ORDER BY DATE;
-------------------------------------------------------------------------------------------------------------
--Daily % Gross Profit Per Unit

SELECT
    DATE,
    (SALES - COST_OF_SALES) AS GROSS_PROFIT,
    ((SALES - COST_OF_SALES)/ SALES) * 100 AS GROSS_PROFIT_PERCENT
FROM SALES_DATA.PUBLIC.SALES_CLEAN
ORDER BY DATE;
-------------------------------------------------------------------------------------------------------------
-- AVERAGE PRICE AND DEMAND PER MONTH
SELECT
    DATE_TRUNC('month', Date) AS Month,
    SUM(Sales) AS Total_Sales,
    SUM(QUANTITY_SOLD) AS Total_Units,
    SUM(Sales) / SUM(QUANTITY_SOLD) AS Avg_Price
FROM SALES_DATA.PUBLIC.SALES_CLEAN
GROUP BY 1
ORDER BY 1;

-------------------------------------------------------------------------------------------------------------
-- AVERAGE PRICE DURING PROMO 1

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', Date) AS Month,
        SUM(Sales) / SUM(QUANTITY_SOLD) AS Price,
        SUM(QUANTITY_SOLD) AS Quantity
    FROM SALES_DATA.PUBLIC.SALES_CLEAN
    GROUP BY 1
)
SELECT
    m1.Month AS Period1,
    m2.Month AS Period2,
    ((m2.Quantity - m1.Quantity) / NULLIF(m1.Quantity,0)) /
    ((m2.Price - m1.Price) / NULLIF(m1.Price,0)) AS Elasticity
FROM monthly m1
JOIN monthly m2
    ON m2.Month = DATEADD('month', 1, m1.Month)
ORDER BY m1.Month;

-------------------------------------------------------------------------------------------------------------
-- MONTHLY SALES TREND
SELECT
    DATE_TRUNC('month', Date) AS Month,
    SUM(Sales) AS Monthly_Sales
FROM SALES_DATA.PUBLIC.SALES_CLEAN
GROUP BY 1
ORDER BY 1;

-------------------------------------------------------------------------------------------------------------
--BEST AND WORST MONTHS
SELECT
    MONTH(Date) AS Month_Num,
    SUM(Sales) AS Total_Sales
FROM SALES_DATA.PUBLIC.SALES_CLEAN
GROUP BY 1
ORDER BY Total_Sales DESC;

-------------------------------------------------------------------------------------------------------------
-- PRICE VS DEMAND RELAtionship

SELECT 
    CORR((Sales / QUANTITY_SOLD), QUANTITY_SOLD) AS Price_Demand_Correlation
FROM SALES_DATA.PUBLIC.SALES_CLEAN;

-------------------------------------------------------------------------------------------------------------
-- data from the only the extract period
SELECT *
FROM SALES_DATA.PUBLIC.SALES_CLEAN
WHERE DATE_TRUNC('month', Date) IN (
    '2014-01-01',
    '2014-06-01',
    '2014-12-01'
)
ORDER BY Date;
------------------------------------------------------------------------------------------------------------
--average price & total units for the 3 promo months
SELECT
    DATE_TRUNC('month', Date) AS Month,
    SUM(Sales) AS Total_Sales,
    SUM(QUANTITY_SOLD) AS TotalUnits,
    SUM(Sales) / SUM(QUANTITY_SOLD) AS Avg_Unit_Price
FROM SALES_DATA.PUBLIC.SALES_CLEAN
WHERE DATE_TRUNC('month', Date) IN (
    '2014-01-01',
    '2014-06-01',
    '2014-12-01'
)
GROUP BY 1
ORDER BY 1;
-----------------------------------------------------------------------------------------------------------
-- elasticity calculation (jan-june-december)

WITH promo AS (
    SELECT
        DATE_TRUNC('month', Date) AS Month,
        SUM(Sales) / SUM(QUANTITY_SOLD) AS Price,
        SUM(QUANTITY_SOLD) AS Qty
    FROM SALES_DATA.PUBLIC.SALES_CLEAN
    WHERE DATE_TRUNC('month', Date) IN (
        '2014-01-01',
        '2014-06-01',
        '2014-12-01'
    )
    GROUP BY 1
)
SELECT
    p1.Month AS Period1,
    p2.Month AS Period2,
    ((p2.Qty - p1.Qty) / p1.Qty) /
    ((p2.Price - p1.Price) / p1.Price) AS Elasticity
FROM promo p1
JOIN promo p2
  ON p2.Month = DATEADD('month', 5, p1.Month)  
ORDER BY 1;






