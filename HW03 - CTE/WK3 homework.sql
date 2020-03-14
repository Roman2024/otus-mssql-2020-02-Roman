--1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.
Select *
from Application.People P
where P.IsSalesperson = 1 and P.PersonID NOT IN (select  SalespersonPersonID from Sales.Invoices);

WITH ProdCTE (SalespersonPersonID,SalesCount) AS
 (select  SalespersonPersonID, Count(InvoiceId) AS SalesCount from Sales.Invoices
 GROUP BY SalespersonPersonID)
 select PersonID, FullName, ProdCTE.SalesCount
 from Application.People P  join ProdCTE
	on P.PersonID = SalespersonPersonID
	where P.IsSalesperson = 1 and ProdCTE.SalesCount = 0
	;

--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.
use WideWorldImporters;

Select * from Warehouse.StockItems
where UnitPrice = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems);


SELECT StockItemID, StockItemName, UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL (SELECT UnitPrice 
	FROM Warehouse.StockItems);

--3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
use WideWorldImporters;

Select distinct C.CustomerID, CustomerName, PhoneNumber
from Sales.Customers C join (select top (5)  CustomerID
	from [WideWorldImporters].[Sales].[CustomerTransactions] 
	Order by [TransactionAmount]) T
	on T.CustomerID = C.CustomerID;
	

with Top5_CTE (CustomerID)
AS (select top (5)  CustomerID
	from [WideWorldImporters].[Sales].[CustomerTransactions] 
	Order by [TransactionAmount])
select * from Sales.Customers C join Top5_CTE on C.CustomerID =  Top5_CTE.CustomerID;

with Top5_CTE (CustomerID)
AS (select top (5)  CustomerID
	from [WideWorldImporters].[Sales].[CustomerTransactions] 
	Order by [TransactionAmount])
select * from Sales.Customers 
where CustomerID IN (Select * from Top5_CTE);

-- 4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов

With Top3InvCTE AS
(
Select IL.InvoiceID from Sales.InvoiceLines IL 
join Warehouse.StockItems W
on IL.[StockItemID] = W.[StockItemID]
join 
	(select top (3) UnitPrice, StockItemID from Warehouse.StockItems
	Order by UnitPrice desc) T3 
	on IL.[StockItemID] = T3.StockItemID
)
Select CityName, DeliveryCityID, A.FullName As [Packed by] from Sales.Customers C join Sales.Invoices I on C.CustomerID = I.InvoiceID
											join Application.Cities CT on CT.CityID= DeliveryCityID
											join Application.People A on PackedByPersonID = A.PersonID;


--5. Объясните, что делает и оптимизируйте запрос:

/* Объяснение: Cравнивает сумму инвойса с суммой заказа для уже собраных заказов 
стоимостью (по инвойсу) > 27тыс.*/

SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
-- Показывает FullName всех продавцов
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
-- Обращается к подзапросу SalesTotals, сумма инвойса
SalesTotals.TotalSumm AS TotalSummByInvoice,
-- подзапрос из Sales.OrderLines
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
-- только для уже собранных заказов
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
-- Основной запрос - из инвойсов
FROM Sales.Invoices
JOIN
-- подзапрос SalesTotals показывает сумму инвойса по InvoiceID для всех инвойсов >25тыс
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- Оптимизировать, извините, не в состоянии. Надеюсь, после следующей лекции про планы и оптимизацию - смогу.

