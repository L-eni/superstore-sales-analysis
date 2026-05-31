#----- DATA PREPROCESSING ----------#
# Create and select database
create database superstore;
use superstore;

# Check imported tables
show tables;

# Rename table for cleaner naming
rename table `data superstore` to data_superstore;

# View table contents
select *from data_superstore;

# Check table structure
describe data_superstore;


# Change column names to snake_case format
alter table data_superstore
change `Row ID` row_id int,
change `Order ID` order_id varchar(30),
change `Order Date` order_date varchar(20),
change `Ship Date` ship_date varchar(20),
change `Ship Mode` ship_mode varchar(50),
change `Customer ID` customer_id varchar(30),
change `Customer Name` customer_name varchar(100),
change `Postal Code` postal_code varchar(20),
change `Product ID` product_id varchar(50),
change `Sub-Category` sub_category varchar(50),
change `Product Name` product_name text;


# Temporarily disable safe update mode
set sql_safe_updates = 0;

# Change the date column format from text to date
update data_superstore
set
    order_date = str_to_date(order_date, '%m/%d/%Y'),
    ship_date = str_to_date(ship_date, '%m/%d/%Y');

# Re-enable safe update mode
set sql_safe_updates = 1;


# Change date column data type to date
alter table data_superstore
modify order_date date,
modify ship_date date;

# Re-check table structure
describe data_superstore;


# Count total number of records
select count(*) as total_rows
from data_superstore;


# Check the range and count of row_ids
select
    min(row_id) as min_row_id,
    max(row_id) as max_row_id,
    count(row_id) as total_row_id
from data_superstore;


# Check for duplicate row_ids
select
    row_id,
    count(*) as duplicate_count
from data_superstore
group by row_id
having count(*) > 1;


# Check for null row_ids
select *
from data_superstore
where row_id is null;


# Increase recursion limit to find missing row_ids
set @@cte_max_recursion_depth = 10000;

# Find missing row_ids
with recursive numbers as (
    select 1 as n
    union all
    select n + 1
    from numbers
    where n < 9994
)
select n as missing_row_id
from numbers
where n not in (
    select row_id
    from data_superstore
);


#---- DATA ANALYSIS -----#
# Business questions

# 1. What is the company's total sales and total profit?
select sum(Sales) as total_sales,
sum(Profit) as total_profit from data_superstore;

# 2. Which product category generates the highest sales and profit?
select category, sum(Sales) as total_sales, sum(Profit) as total_profit
from data_superstore group by category
order by total_sales desc;

# 3. Which sub-categories are the most profitable, and which are causing losses?
select sub_category, sum(Profit) as total_profit
from data_superstore
group by sub_category
order by total_profit desc;

# 4. Which region has the best sales and profit performance?
select region, sum(Sales) as total_sales, sum(Profit) as total_profit
from data_superstore
group by region
order by total_profit desc;

# 5. Which customer segment contributes the most to total sales?
select segment, sum(Sales) as total_sales
from data_superstore
group by segment
order by total_sales desc;

# 6. Who are the top 10 customers by total purchases?
select Customer_Name, sum(Sales) as total_purchase
from data_superstore 
group by Customer_Name
order by total_purchase desc
limit 10;

# 7. How does sales trend change over time?
select date_format(order_date, '%Y-%m') as month,
sum(sales) as total_sales
from data_superstore
group by month
order by month;

# 8. Does discount given affect company profit?
select Discount, avg(Profit) as average_profit
from data_superstore
group by discount
order by discount;

# 9. Which products have high sales but generate low or negative profit?
select product_name,
sum(sales) as total_sales,
sum(profit) as total_profit
from data_superstore
group by product_name
having sum(profit) < 0
order by total_sales desc
limit 5;
