--1. �������� �����������, ������� �������� ������������, � ��� �� ������� �� ����� �������.
SELECT *
FROM Application.People P
WHERE P.IsSalesperson = 1 and P.PersonID NOT IN (
	SELECT SalespersonPersonID 
	FROM Sales.Invoices);

WITH ProdCTE (SalespersonPersonID,SalesCount) AS
	(SELECT SalespersonPersonID, 
		Count(InvoiceId) AS SalesCount 
	FROM Sales.Invoices
 	GROUP BY SalespersonPersonID)
SELECT  PersonID, 
	FullName, 
	ProdCTE.SalesCount
FROM Application.People P  
JOIN ProdCTE
	ON P.PersonID = SalespersonPersonID
WHERE P.IsSalesperson = 1 
	AND ProdCTE.SalesCount = 0;

--2. �������� ������ � ����������� ����� (�����������), 2 �������� ����������.
USE WideWorldImporters;

SELECT * 
FROM Warehouse.StockItems
WHERE UnitPrice = (
	SELECT MIN(UnitPrice) 
	FROM Warehouse.StockItems);


SELECT	StockItemID, 
	StockItemName, 
	UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL (
	SELECT UnitPrice 
	FROM Warehouse.StockItems);

--3. �������� ���������� �� ��������, ������� �������� �������� 5 ������������ �������� �� [Sales].[CustomerTransactions] ����������� 3 ������� (� ��� ����� � CTE)
use WideWorldImporters;

SELECT DISTINCT 
	C.CustomerID, 
	CustomerName, 
	PhoneNumber
FROM Sales.Customers C 
JOIN (SELECT TOP (5) CustomerID
      FROM [WideWorldImporters].[Sales].[CustomerTransactions] 
      Order by [TransactionAmount] DESC) T
  	ON T.CustomerID = C.CustomerID;
	

WITH Top5_CTE (CustomerID) AS (
	SELECT TOP (5)  CustomerID
	FROM [WideWorldImporters].[Sales].[CustomerTransactions] 
	Order by [TransactionAmount] DESC)
SELECT * 
FROM Sales.Customers C 
JOIN Top5_CTE 
	ON C.CustomerID =  Top5_CTE.CustomerID;

WITH Top5_CTE (CustomerID) AS (
	SELECT TOP (5)  CustomerID
	FROM [WideWorldImporters].[Sales].[CustomerTransactions] 
	Order by [TransactionAmount] DESC)
SELECT * 
FROM Sales.Customers 
WHERE CustomerID IN (SELECT * FROM Top5_CTE);

-- 4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, �������� � ������ ����� ������� �������, � ����� ��� ����������, ������� ����������� �������� �������

WITH Top3InvCTE AS (
	SELECT IL.InvoiceID FROM Sales.InvoiceLines IL 
	JOIN Warehouse.StockItems W
		ON IL.[StockItemID] = W.[StockItemID]
	JOIN (SELECT TOP (3) 
		UnitPrice, 
		StockItemID 
	      FROM Warehouse.StockItems
	      ORDER BY UnitPrice DESC) T3 
		ON IL.[StockItemID] = T3.StockItemID
)

SELECT  CityName, 
	DeliveryCityID, 
	A.FullName As [Packed by] 
FROM Sales.Customers C 
JOIN Sales.Invoices I 
	ON C.CustomerID = I.InvoiceID
JOIN Application.Cities CT 
	ON CT.CityID= DeliveryCityID
JOIN Application.People A 
	ON PackedByPersonID = A.PersonID
JOIN Top3InvCTE 
	ON  Top3InvCTE.InvoiceID = I.InvoiceID;