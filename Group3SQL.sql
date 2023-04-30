Create database FinalProjectNew;
use finalprojectnew;

select * from vendor limit 10;
select * from iteminventory limit 10;
select * from vendorbilling limit 10;
select * from bookstore limit 10;
select * from books limit 10;
select * from customer limit 10;
select * from clothes limit 10;
select * from misc limit 10;
select * from employee limit 10;
select * from iteminvoice limit 10;

#Adding Primary Key to all tables
ALTER TABLE books ADD PRIMARY KEY (UPC_CODE);

alter table bookstore modify column book_store_id varchar(255);
ALTER TABLE bookstore ADD PRIMARY KEY (book_store_id);

ALTER TABLE clothes ADD PRIMARY KEY (UPC_CODE);

ALTER TABLE customer ADD PRIMARY KEY (cust_id);

ALTER TABLE employee ADD PRIMARY KEY (employeeid);

ALTER TABLE iteminventory ADD PRIMARY KEY (UPC_CODE);

ALTER TABLE misc ADD PRIMARY KEY (UPC_CODE);

alter table vendor modify column vendor_id varchar(255);
ALTER TABLE vendor ADD PRIMARY KEY (vendor_id);

alter table vendorbilling modify column vendor_id varchar(255);
ALTER table vendorbilling ADD PRIMARY KEY (UPC_CODE,vendor_id);

alter table iteminvoice modify column invoice_id varchar(255);
ALTER TABLE iteminvoice ADD PRIMARY KEY (UPC_CODE,invoice_id);

#Adding Foreign Key to tables as required
alter table employee modify column book_store_id varchar(255);
ALTER TABLE Employee
ADD FOREIGN KEY (Book_Store_ID) REFERENCES bookstore(Book_Store_ID);

alter table iteminventory modify column book_store_id varchar(255);
alter table iteminventory modify column vendor_id varchar(255);
ALTER TABLE iteminventory
ADD FOREIGN KEY (Book_Store_ID) REFERENCES bookstore(Book_Store_ID),
ADD FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_ID);

ALTER TABLE iteminvoice
ADD FOREIGN KEY (cust_ID) REFERENCES customer(cust_ID);

ALTER TABLE vendorbilling
ADD FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_ID);

#Query to be run prior to running the other queries
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- Scenario 1: Customer Analysis
-- Gender Wise Popular Products:
-- Query 1:
#top popular products in women
select gender,iteminventory.item_name,quant_sold
from iteminventory
inner join clothes
on iteminventory.upc_code = clothes.upc_code
group by clothes.gender,iteminventory.item_name,quant_sold
having gender = 'women'
order by quant_sold desc
limit 10;

-- Query 2:
#top popular products in male
select gender,iteminventory.item_name,quant_sold
from iteminventory
inner join clothes
on iteminventory.upc_code = clothes.upc_code
group by clothes.gender,iteminventory.item_name,quant_sold
having gender = 'men'
order by quant_sold desc
limit 10;

-- Buyer Pattern during the week:
-- Query 3:
SET SQL_SAFE_UPDATES = 0;
SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';
update iteminvoice set date =  STR_TO_DATE(date, "%d/%m/%Y");
select dayname(Date), count(distinct Invoice_ID) as number_of_purchases_per_day from iteminvoice 
group by dayname(Date) order by number_of_purchases_per_day desc limit 10;

-- Scenario 2: Vendor Analysis
-- Dependency on Vendor:
-- Query 4:
select item_name, vendor_name, v.vendor_id
from iteminventory as i
inner join vendor as v
on i.vendor_id = v.vendor_id
where current_quantity_on_hand= 0
and current_quantity_on_order=0;

-- One Vendor One Invoice:
-- Query 5:
-- all stockout items for vendor 02
-- suppose below is the query to get list of all items to be ordered from vendor v02
select item_name, vendor_name, v.vendor_id
from iteminventory as i
inner join vendor as v
on i.vendor_id = v.vendor_id
where current_quantity_on_hand= 0
and current_quantity_on_order=0
and v.vendor_id='v02';

-- Scenario 3: Inventory Replenishment
-- Best Selling Items:
-- Query 6:
select iteminvoice.UPC_code, count(*) as number_of_times_purchased, iteminventory.Item_Name from iteminvoice inner join iteminventory 
on iteminvoice.UPC_code=iteminventory.UPC_code 
group by iteminvoice.UPC_Code,iteminventory.item_name order by number_of_times_purchased desc limit 10;

-- When to Restock:
-- Query 7: 
select item_name, vendor_name, v.vendor_id
from iteminventory as i
inner join vendor as v
on i.vendor_id = v.vendor_id
where current_quantity_on_hand= 0
and current_quantity_on_order=0;
-- Query 8:
alter table iteminventory
add column quantity_threshold int as (0.20 * (Quant_sold + current_quantity_on_hand + current_quantity_on_order));
select item_name,vendor_id from iteminventory where current_quantity_on_hand < quantity_threshold;

-- Scenario 4: Inventory Management
-- Restock Alert for 50 Best Sellers:
-- Query 9:
select item_name,price,Current_Quantity_On_Hand from iteminventory
where current_quantity_on_hand < quantity_threshold
and current_quantity_on_order = 0
order by price desc
limit 50;

-- Restock Alert for 50 below average sellers:
-- Query 10:
select item_name,price,Current_Quantity_On_Hand from iteminventory
where current_quantity_on_hand = 0
and current_quantity_on_order = 0
order by price asc
limit 50;

-- Scenario 5: Employee Analysis
-- Query 11:
select max(salary),min(salary),avg(salary) from employee;
-- Query 12:
select distinct position from employee;











 









