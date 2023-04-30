create database finalproject;
use finalproject;
#EDA
select * from booksonly limit 5;
select * from inventorytable limit 5;
select distinct current_quantity_on_order from inventorytablec; 
#Renaming Table
alter table clothesonlyxlsx rename to clothesonly;
alter table inventorytablec rename to inventorytable;
#EDA
select distinct itemname from itemtable;
drop table itemtable;

#query which items are over, quantity zero
SELECT itemtable.ItemName
FROM itemtable 
INNER JOIN inventorytable 
ON itemtable.upccode = inventorytable.upc_code
where current_quantity_on_hand = 0
and Current_Quantity_On_Order != 0;

#query items are from which vendor
select * from vendortable;
select itemtable.itemname, vendortable.vendor_name 
from vendortable
inner join inventorytable
on vendortable.vendor_id = inventorytable.vendor_id
inner join itemtable
on itemtable.upccode = inventorytable.upc_code
where current_quantity_on_hand = 0
and Current_Quantity_On_Order != 0;

#eda
select distinct category from misctable limit 10;
select * from customer;
select * from item_invoice limit 10;
#change dtartype column in item_invoice
alter table item_invoice
modify column upc_code bigint;
select * from item_invoice limit 10;
#eda
drop table item_invoice.upc_code;
#query to find items with quantity less than 10% items
select item_invoice.upc_code, sum(item_invoice.quantity)
from itemtable
inner join item_invoice
on item_invoice.upc_code = itemtable.upccode
group by item_invoice.upc_code
having sum(item_invoice.quantity)<10
order by sum(item_invoice.quantity) desc;
#query to create calculated column quantity threshold
alter table inventorytable
add column quantity_threshold int as (0.20 * (Quant_sold + current_quantity_on_hand + current_quantity_on_order));

select * from inventorytable limit 10;
#query to get item name which have quantity less threshold
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select itemtable.itemname
from itemtable
inner join item_invoice
on item_invoice.upc_code = itemtable.upccode
inner join inventorytable
on inventorytable.upc_code = item_invoice.upc_code
group by itemtable.itemname
having sum(item_invoice.quantity)<=sum(inventorytable.quantity_threshold)
order by sum(item_invoice.quantity) desc;

select * from vendortable limit 10;
select * from itemtable limit 10;
select * from item_invoice limit 10;

#removing group by error
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

#top 50 customers of the month
select * from customer limit 10;
select * from item_invoice limit 10;

select customer.name
from customer 
inner join item_invoice
on customer.invoice_id = item_invoice.invoice_id
group by item_invoice.invoice_id, item_invoice.quantity, customer.name
having sum(item_invoice.quantity) > 0
order by sum(item_invoice.quantity) desc
limit 50;

#highest 20 selling items
select * from itemtable limit 10;
select item_invoice.upc_code, itemtable.itemname
from itemtable
inner join item_invoice
on itemtable.upccode = item_invoice.upc_code
group by item_invoice.upc_code, itemtable.itemname
having sum(item_invoice.quantity) > 0
order by sum(item_invoice.quantity) desc
limit 20;



	





