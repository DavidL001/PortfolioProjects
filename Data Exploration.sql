-- Before visulizing the data, I did Exploratory Data Analysis (EDA) to better understand the data
-- Checked how much data I'm working with in the orders table
SELECT 
  COUNT(*) 
FROM 
  dbo.orders 
-- I examined all the colums to see what information I had
SELECT 
  * 
FROM 
  dbo.orders 
ORDER BY 
  [Row ID] 
-- Row ID or Order ID could be the primary key so, I checked if either of them are unique
SELECT 
  [Order ID], 
  COUNT(*) 
FROM 
  dbo.orders 
GROUP BY 
  [Order ID] 
HAVING 
  COUNT(*) > 1 
-- Order ID is not unique, so I checked in Row ID is unique
SELECT 
  [Row ID], 
  COUNT(*) 
FROM 
  dbo.orders 
GROUP BY 
  [Row ID] 
HAVING 
  COUNT(*) > 1 
-- No results, indicating Row ID is the primary key
-- Ship date should always be less than Order Date so, I validated the data
SELECT
  *
FROM
  dbo.orders
WHERE
  [Order Date] > [Ship Date]
-- No errors
-- I evaluated the distinct ship modes the company provides
SELECT
  DISTINCT [Ship Mode]
FROM
  dbo.orders
-- 4 unique shipping modes
-- I checked how long it takes for each shipping mode
-- Second Class Shipping Time
SELECT 
  MIN(st.Shipping_Time) AS Shortest_Shipping_Date, 
  MAX(st.Shipping_Time) AS Longest_Shipping_Date 
FROM 
  (
    SELECT 
      *, 
      DATEDIFF(DAY, [Order Date], [Ship Date]) AS Shipping_Time 
    FROM 
      dbo.orders 
    WHERE 
      [Ship Mode] = 'Second Class'
  ) st
-- Standard Class Shipping Time
SELECT 
  MIN(st.Shipping_Time) AS Shortest_Shipping_Date, 
  MAX(st.Shipping_Time) AS Longest_Shipping_Date 
FROM 
  (
    SELECT 
      *, 
      DATEDIFF(DAY, [Order Date], [Ship Date]) AS Shipping_Time 
    FROM 
      dbo.orders 
    WHERE 
      [Ship Mode] = 'Standard Class'
  ) st
-- Same Day Shipping Time
SELECT 
  MIN(st.Shipping_Time) AS Shortest_Shipping_Date, 
  MAX(st.Shipping_Time) AS Longest_Shipping_Date 
FROM 
  (
    SELECT 
      *, 
      DATEDIFF(DAY, [Order Date], [Ship Date]) AS Shipping_Time 
    FROM 
      dbo.orders 
    WHERE 
      [Ship Mode] = 'Same Day'
  ) st
-- First Class Shipping Time
SELECT 
  MIN(st.Shipping_Time) AS Shortest_Shipping_Date, 
  MAX(st.Shipping_Time) AS Longest_Shipping_Date 
FROM 
  (
    SELECT 
      *, 
      DATEDIFF(DAY, [Order Date], [Ship Date]) AS Shipping_Time 
    FROM 
      dbo.orders 
    WHERE 
      [Ship Mode] = 'First Class'
  ) st
-- Can customers order multiple items ?
SELECT
  [Customer ID],
  [Order ID],
  COUNT(*)
FROM
  dbo.orders
GROUP BY
  [Customer ID],
  [Order ID]
