-- SQL Retail Sales Analysis

CREATE DATABASE SQL_Retail_Sales_Analysis;

-- Creating the Table
-- Grabbing the column names from the spreadsheet and pasting them into the code below

DROP TABLE IF EXISTS retail_sales; --prevents duplicates
CREATE TABLE retail_sales
	(
	transactions_id	INT PRIMARY KEY,
	sale_date DATE,  -- need to ensure date format in the SS is y-m-d
	sale_time TIME,
	customer_id	INT,
	gender VARCHAR(15),
	age	INT,
	category VARCHAR(15), --make sure to check the max length of this column max(len())
	quantiy	INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
	);

-- Confirming table was created correctly. There won't be any data yet
Select *
FROM retail_sales;

-- Next importing the data. Right clicking the table in the object explorer and 
-- choosing import/export data. Better to browse and pick the folder than paste the path.

-- Now we can see the data (looking at the first 15 rows)
Select *
FROM retail_sales
LIMIT 15;

-- Counting the number of records (confirm rows in spreadsheet)
Select 
	Count(*)
From retail_sales;

-- Checking for Nulls
Select *
From retail_sales
Where transactions_id IS Null; -- No Nulls present, can do for each column

Select *
From retail_sales
Where transactions_id IS NULL -- looking through multiple columns, will stop at the first 'True' though
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULl
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL; 
-- 13 nulls found. 10 in 'age' and 3 in 'quantiy'

-- deleting the nulls using the same conditions as before
Delete From retail_sales
Where transactions_id IS NULL 
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULl
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL; -- deleted 13 rows

-- Re-counting the number of records, should have 1987
Select 
	Count(*)
From retail_sales;

-- Data Exploration
-- Counting How # of sales (will be the same number of records)
Select 
	count(*) as total_sales
From retail_sales;

-- counting # of customers
Select
	Count(Distinct customer_id) as total_customers
From retail_sales;

-- how all the catagories we have
Select
	Distinct category as category_list -- will list the unique values in this column
From retail_sales;

-- Data Analysis & Business Key Problems & Answers

-- Q1: retrieve all columns for sales made on 2022-11-05 (should give 11 records)
Select *
From retail_sales
Where sale_date = '2022-11-05';

--Q2: retrieve all transactions where the category  is 'clothing' and the quantity sold
-- is more than 4 in the month of Nov-2022 (should give 17 records)
Select *
From retail_sales
Where category = 'Clothing' 
	and TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	and quantiy >= 4;

-- Q3: Calculate the total sales (total_sale) for each category
Select 
	Category,
	SUM(total_sale) as total_sales_by_category
From retail_sales
Group by category;

-- Q4: Finding the average age of customers who purchases items from the 'Beauty' category. (A:40.42)
Select ROUND(avg(age),2) as avg_age
From retail_sales
Where category = 'Beauty';

-- Q5: Finding all the transactions where the total_sale is greater than 1000. (A: 306)
select *
from retail_sales
where total_sale > 1000;

-- Q6: Finding total number of transations made by each gender in each category
select category,
	gender,
	count(*) as sales_by_gender
From retail_sales
group by category, gender
Order by category;

-- Q7: Calculate the average sale for each month. What month of each year is the best?
-- will need a nested query (2022 $541, 2023 $535

select year,
	month,
	average_sales
from (
select 
	extract(year from sale_date) as year, -- pulling the year from the datetime value
	extract(month from sale_date) as month, -- same but for month
	avg(total_sale) as average_sales,
	RANK() over(partition by extract(year from sale_date) order by avg(total_sale) desc) as rank -- adding a rank column for total_sales by year
From retail_sales
group by year, month
) as TB1
where rank = 1;
--order by year, average_sales desc --add to the inner query if you want to avoid nested query. another format opion
--avg_sales desc so we can see the top sales month for each year first. 

--Q8: Find top 5 customers based on highest total sale
select customer_id,
	sum(total_sale) as total_sales
from retail_sales
group by customer_id
order by total_sales desc 
limit 5;

-- Q9: Find the number of unique customers who purchased items from each category
select category,
	count(distinct customer_id) as unique_customers
From retail_sales
group by category

--Q10: Create time shifts and the number of orders within them
--(ex. Morning <=12, Afternoon 12< X >17, and evevning >17)
select Shift,
	count(transactions_id) as total_orders
From(
select *,
	CASE
		when extract(hour from sale_time) < 12 then 'Morning'
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		else 'Evening'
	End as Shift
From retail_sales
)
group by Shift

-- End of project