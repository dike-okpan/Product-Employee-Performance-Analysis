--1)Orders in May 2011
select T.Name
	, SalesOrderID
	, CustomerID
	, S.TerritoryID
	, SubTotal
	, TaxAmt
	, + '$' + CONVERT(varchar(12), TotalDue, 1) AS 'Total Due($)'
from Sales.SalesOrderHeader S
INNER JOIN [Sales].[SalesTerritory] T
	on T.TerritoryID =S.TerritoryID
where [OrderDate] BETWEEN '5/1/2011' AND '5/31/2011'
---------------------------------------------------------------------------------------------------------------------------------

--2)Number of Orders that were due in June 2011
select count(*)
from Sales.SalesOrderHeader
where [DueDate] BETWEEN '6/1/2011' AND '6/12/2011'
-----------------------------------------------------------------------------------------------------------------------------------------

--3)sub total, total taxes and total sales by Territory
SELECT t.Name
	, SUM(s.SubTotal) as [Sub Total]
	, Sum(TaxAmt) as 'Total Taxes'
	, Sum(TotalDue) as 'Total Sales'
from Sales.SalesOrderHeader s
INNER JOIN Sales.SalesTerritory t 
	on s.TerritoryID = t.TerritoryID
group by t.Name
order by 2 desc
-----------------------------------------------------------------------------------------------------------------------------------------

--4)sub total, total due by customer ID by each saleorderID
select CustomerID
, SalesOrderID
, SUM(SubTotal) as 'Sub Total'
, SUM(TotalDue) as 'Total w Taxes & Freight'
from Sales.SalesOrderHeader
group by ROLLUP(CustomerID, SalesOrderID)
----------------------------------------------------------------------------------------------------------------------------------------

--5)sub total, total due by customer ID by each saleorderID
select CustomerID
, SalesOrderID
, SUM(SubTotal) as 'Sub Total'
, SUM(TotalDue) as 'Total w Taxes & Freight'
from Sales.SalesOrderHeader
group by ROLLUP(CustomerID, SalesOrderID)
-------------------------------------------------------------------------------------------------------------------------------------------

--6)Line Items count and sales order total of each Sales Order ID
select SalesOrderID 
	, count(SalesOrderDetailID) as Line_Items
	, str(sum(UnitPrice * OrderQty)) as Sales_Order_Total
from Sales.SalesOrderDetail
group by SalesOrderID
-------------------------------------------------------------------------------------------------------------------------------------------

--7) Number of Order Quantities, Average Prices, sum of Line Total of each product
select p.ProductID
	, p.Name
	, s.SpecialOfferID
	, so.Description
	, count(OrderQty) as OrderQyt_Count
	, avg(UnitPrice) as Average_Price
	, str(sum(LineTotal)) as SubTotal
from [Sales].[SalesOrderDetail] s
join [Sales].[SpecialOffer] so
	on s.SpecialOfferID = so.SpecialOfferID
join [Production].[Product]p
	on p.ProductID = s.ProductID
group by p.ProductID, p.name, s.SpecialOfferID, so.Description
order by ProductID, OrderQyt_Count desc
------------------------------------------------------------------------------------------------------------------------------------------
--8)Products with average unit price greater or equal to 1500
select p.ProductID
, Name
, AVG(UnitPrice) as Average_Price_List
from [Production].[Product] p
join sales.SalesOrderDetail s
	on p.ProductID = s.ProductID
group by p.ProductID, Name
having AVG(UnitPrice) >= 1500
order by 1
------------------------------------------------------------------------------------------------------------------------------------------

--9)Average prices of top 5 products with order quantity count more than 20 in 2012
select top 5 
	sod.ProductID
	, p.Name
	, avg(sod.UnitPrice) as Average_Price
from [Sales].[SalesOrderDetail] sod
join [Sales].[SalesOrderHeader] soh
	on sod.SalesOrderDetailID = soh.SalesOrderID
join [Production].[Product] p
	on sod.ProductID = p.ProductID
where OrderQty > '20' 
	and YEAR(soh.OrderDate) = '2012'
group by sod.ProductID, p.Name
order by Average_Price desc
---------------------------------------------------------------------------------------------------------------------------------------

--10)Total Sub-category Sales of 2012 or 2013
select DATEPART(YY, soh.OrderDate) as year
	, 'Q' + DATENAME(QQ, soh.OrderDate) as Qtr
	, psc.Name as sub_category
	, pc.Name as category
	, str(sum((sod.UnitPrice * sod.OrderQty))) as sales
from Production.ProductSubcategory psc
join [Production].[ProductCategory] pc
	on psc.ProductCategoryID = pc.ProductCategoryID
join [Production].[Product] p
	on psc.ProductSubcategoryID = p.ProductSubcategoryID
join [Sales].[SalesOrderDetail] sod
	on p.ProductID = sod.ProductID
join [Sales].[SalesOrderHeader] soh
	on sod.SalesOrderID = soh.SalesOrderID
where YEAR(soh.OrderDate) = '2012' or YEAR(soh.OrderDate) = '2013'
group by  DATEPART(YY, soh.OrderDate), DATENAME(QQ, soh.OrderDate), pc.Name, psc.Name
order by year, category, sub_category, Qtr
-------------------------------------------------------------------------------------------------------------------------------------------------

--11)Total tax amount for each customer
select CustomerID
	, SalesOrderID
	, TaxAmt
	, SUM(TaxAmt)
over(partition by customerid order by customerid) as TotalTaxAmt
from [Sales].[SalesOrderHeader]
--OR
select CustomerID
	, SUM(TaxAmt) as TotalTaxAmt
from [Sales].[SalesOrderHeader]
group by CustomerID
order by 1
------------------------------------------------------------------------------------------------------------------------------------------

--12)Total Territory Sales in 2011, 2012, 2013 and 2014
select Name
	, sum(CASE WHEN YEAR([OrderDate]) = 2011 THEN ([SubTotal]) END) AS '2011'
	, sum(CASE WHEN YEAR([OrderDate]) = 2012 THEN ([SubTotal]) END) AS '2012'
	, sum(CASE WHEN YEAR([OrderDate]) = 2013 THEN ([SubTotal]) END) AS '2013'
	, sum(CASE WHEN YEAR([OrderDate]) = 2014 THEN ([SubTotal]) END) AS '2014'
	, sum([SubTotal]) AS Total
from [Sales].[SalesOrderHeader] soh
join [Sales].[SalesTerritory] st
	on st.TerritoryID = soh.TerritoryID
group by Name
order by Name
--------------------------------------------------------------------------------------------------------------------------------------

--13)Customers/Sales Performances
select CONCAT([FirstName], + ' ', +[LastName]) as Employee
	, t.[TerritoryID]
	, t.[Name] as Territory
	, s.SalesLastYear as Emp_Sales_Last_Year
	, [SalesQuota] as Emp_Sales_Quota
	, s.SalesYTD as Emp_Sales_YTD
	, [Bonus] as Emp_Bonus
	, [CommissionPct] as Emp_Commission
	, [HireDate]
	, [MaritalStatus]
	, t.[SalesLastYear] as Territory_Sales_Last_Year
	, t.[SalesYTD] as Territory_Sales_YTD
from HumanResources.Employee e
inner join Person.Person p 
	on p.BusinessEntityID = e.BusinessEntityID
inner join Sales.SalesPerson s 
	on s.BusinessEntityID = e.BusinessEntityID
inner join [Sales].[SalesTerritory] t 
	on t.[TerritoryID] = s.TerritoryID
order by TerritoryID
--------------------------------------------------------------------------------------------------------------------------------------------

--14)All the products in 'classic vest' product model

SELECT distinct Name
FROM Production.Product AS p 
WHERE EXISTS
    (SELECT *
     FROM Production.ProductModel AS pm 
     WHERE p.ProductModelID = pm.ProductModelID
           AND pm.Name LIKE 'classic vest%')

--OR
SELECT p.Name
FROM Production.ProductModel pm
join [Production].[Product] p
	on p.ProductModelID = pm.ProductModelID
where pm.Name LIKE 'classic vest%'
---------------------------------------------------------------------------------------------------------------------------------------------

--15)First and Last names of employees with 5000 bonus
SELECT distinct p.FirstName 
	, p.LastName
	, JobTitle
FROM Person.Person AS p 
JOIN HumanResources.Employee AS e
    ON e.BusinessEntityID = p.BusinessEntityID WHERE 5000.00 IN
    (SELECT Bonus
     FROM Sales.SalesPerson AS sp
     WHERE e.BusinessEntityID = sp.BusinessEntityID)

SELECT p.FirstName
	, p.LastName
	, JobTitle
FROM Person.Person AS p 
JOIN HumanResources.Employee AS e
    ON e.BusinessEntityID = p.BusinessEntityID
join Sales.SalesPerson sp
	on e.BusinessEntityID = sp.BusinessEntityID
where Bonus = 5000
order by 1
---------------------------------------------------------------------------------------------------------------------------------------------

--16)List of products greater or equal to the average price list of all the products
select p1.ProductModelID
	, p1.Name
	, ListPrice
from Production.Product AS p1
group by p1.ProductModelID, p1.Name, ListPrice
having max(p1.ListPrice) >=
    (select AVG(p2.ListPrice) 
      Production.Product AS p2)
order by 3
-----------------------------------------------------------------------------------------------------------------------------------------------------------

--17)List of Employees who have sold Chain
select distinct pp.LastName
	, pp.FirstName 
from Person.Person pp 
join HumanResources.Employee e
	on e.BusinessEntityID = pp.BusinessEntityID 
where pp.BusinessEntityID IN 
	(select SalesPersonID 
	from Sales.SalesOrderHeader
	where SalesOrderID IN 
		(select SalesOrderID 
		from Sales.SalesOrderDetail
		where ProductID IN 
			(select ProductID
			from Production.Product p 
			where Name = 'chain')))
---------------------------------------------------------------------------------------------------------------------------------------------

--18)Product ID of products with price less than 25 with more than 5 average_order_quantity
select ProductID
	, AVG(OrderQty) as AvgOrderQty
from Sales.SalesOrderDetail
where UnitPrice < 25.00
group by ProductID
having AVG(OrderQty) > 5
order by AvgOrderQty desc
--------------------------------------------------------------------------------------------------------------------------------------------

--19)Total sum of product ID which sold more 1500 items
select ProductID
	, SUM(LineTotal) AS Total
from Sales.SalesOrderDetail
group by ProductID
having COUNT(*) > 1500


