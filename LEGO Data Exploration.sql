-- Question 1:
-- What is the total number of parts used per theme ?
CREATE VIEW dbo.analytics_main AS -- Create a view of the infromation I need from the themes and set tables. This will allow for simple queries later. 
SELECT 
  s.set_num, 
  s.name AS Set_Name, 
  s.year, 
  s.theme_id, 
  CAST(s.num_parts AS numeric) AS Number_Of_Parts,   -- Number of parts was imported as a string, need to convert to numeric data
  t.name AS Theme_Name, 
  t.parent_id, 
  pt.name AS Parent_Theme_Name,
  CASE 
    WHEN s.year BETWEEN 1901 and 2000 then '20th_Century'
    WHEN s.year BETWEEN 2001 and 2100 then '21st_Century'
	END AS Century -- This will be useful for later question about centuries
FROM 
  [Rebrickable].[dbo].[sets] AS s 
  LEFT JOIN [Rebrickable].[dbo].[themes] AS t -- Left join because I want everything from the sets table, which has the number of parts
    ON s.theme_id = t.id 
  LEFT JOIN dbo.themes AS pt -- I want to be able to view the parent_theme name so, I need to combine it with the parend_id in the same table
    ON t.parent_id = pt.id 

-- Check to see if the table was created properly 
SELECT 
  *
FROM 
  dbo.analytics_main 

-- Now, this is the query that will let me see the total numebr of parts used by each LEGO theme
SELECT 
  Theme_Name, 
  SUM(Number_Of_Parts) AS Total_Parts -- Adds all the parts used
FROM 
  dbo.analytics_main 
GROUP BY 
  Theme_Name
ORDER BY 
  Total_Parts DESC

-- Question 2:
-- How many parts where used per year ?
SELECT 
  year, 
  SUM(Number_Of_Parts) AS Total_Parts 
FROM 
  dbo.analytics_main 
GROUP BY 
  year 
ORDER BY 
  Total_Parts DESC

-- Question 3:
-- How many sets were used per century ?
SELECT 
  Century, 
  COUNT(set_num) AS Number_Of_Sets_Created -- Counts the distinct amount of LEGO sets created
FROM 
  dbo.analytics_main 
GROUP BY 
  Century 
ORDER BY 
  Number_Of_Sets_Created DESC

-- Question 4:
-- What percentage of sets released in the 21st Century had a Super Heroes Marvel parent theme ?
WITH TEMP AS -- Need to create a CTE table so we can query from it to find the percentage
(
  SELECT 
    Century, 
    COUNT(set_num) AS Number_Of_Sets_Created, 
    Parent_Theme_Name 
  FROM 
    dbo.analytics_main 
  WHERE 
    Century = '21st_Century' 
  GROUP BY 
    Century, 
    Parent_Theme_Name
) 
SELECT 
  * 
FROM -- Must subquery from the following table so I can filter by Parent_Theme_Name without affecting the percentage
  (
    SELECT 
      Century, 
      Parent_Theme_Name, 
      Number_Of_Sets_Created, 
      SUM(Number_Of_Sets_Created) OVER() AS Total_Sets, -- Need window function because no grouping, don't need any partitioning 
      CAST(
        1.00 * Number_Of_Sets_Created / SUM(Number_Of_Sets_Created) OVER() as decimal(5, 4)
      ) * 100 AS Percentage_Of_Total -- Have to chnage columns to the same data type, if not it will give 0.000
    FROM 
      TEMP
  ) Subquery 
WHERE 
  Parent_Theme_Name = 'Super Heroes Marvel'
 -- 1.24% of the total sets released in the 21st century had a parent theme of Super Heroes Marvel

 -- Question 5:
-- What was the most popular theme (theme_name) in 2022 in terms of sets released
SELECT 
  year, 
  COUNT(set_num) AS Number_Of_Sets_Created, 
  Theme_Name 
FROM 
  dbo.analytics_main 
WHERE 
  year = '2022' 
GROUP BY 
  Theme_Name, 
  year 
ORDER BY 
  year DESC, 
  Number_Of_Sets_Created DESC
-- The most popular theme was Books with 80 sets released

--Question 6
-- What is the the color with the highest amount of LEGO parts produced
SELECT 
  Color, 
  SUM(Item_Quantity) AS Total_Amount_Of_Parts 
FROM 
  -- Create a subquery joining all the tables with the necessary data so I can query off of it the information I need
  (
    SELECT 
      inv.color_id, 
      inv.inventory_id, 
      inv.part_num, 
      CAST(inv.quantity as numeric) AS Item_Quantity, 
      -- Must convert quantity to a numeric value for caluclations
      inv.is_spare, 
      c.name AS Color, 
      c.rgb, 
      p.name AS Part_Name, 
      p.part_material, 
      pc.name AS Category_Name 
    FROM 
      inventory_parts AS inv 
      INNER JOIN colors AS c ON inv.color_id = c.id -- Joining the tables containing all the information I need for this question. Joining the colorids
      INNER JOIN parts AS p ON inv.part_num = p.part_num -- Joining the part numbers
      INNER JOIN part_categories AS pc ON p.part_cat_id = pc.id -- Joining the catgeory IDs in both tables
      ) Subquery2 
GROUP BY 
  Color 
ORDER BY 
  SUM(Item_Quantity) DESC

-- The color with the highest amount of LEGO parts prodcued in Black with 709,669 parts