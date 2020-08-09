/*������� �������
1. ����������� ���� ������ ���� ��� ������� �������. */

set statistics time on;
USE WideWorldImporters;

drop table if exists #temtab;

SELECT I.CustomerID, SUM(IL.ExtendedPrice) AS InvSum, I.InvoiceDate AS InvDate
into #temtab
	FROM Sales.Invoices I JOIN Sales.InvoiceLines IL
	ON I.InvoiceID = IL.InvoiceID
	GROUP BY I.CustomerID, I.InvoiceDate;

SELECT TM.*, (SELECT SUM(InvSum) 
			FROM #temtab AS t2 
			WHERE t2.InvDate <= TM.InvDate) AS NakoplenItog
	FROM #temtab AS TM
	where year(InvDate)>= 2015
ORDER BY InvDate;
/*
CPU time = 0 ms, elapsed time = 1033 ms.
CPU time = 0 ms,  elapsed time = 261 ms.
CPU time = 125 ms,  elapsed time = 7770 ms. */

/*2. � ������� ������� �������.
�������� 2 �������� ������� - ����� windows function � ��� ���. �������� ����� ������� �����������, �������� �� set statistics time on;
*/
set statistics time on;
USE WideWorldImporters;
SELECT DISTINCT I.InvoiceDate, SUM (IL.ExtendedPrice) OVER (ORDER BY I.InvoiceDate) AS Total
	FROM Sales.Invoices I JOIN Sales.InvoiceLines IL
		ON I.InvoiceID = IL.InvoiceID
	WHERE YEAR(InvoiceDate)>=2015
GROUP BY I.InvoiceDate,IL.ExtendedPrice
ORDER BY I.InvoiceDate;

/*SQL Server Execution Times:
   CPU time = 172 ms,  elapsed time = 1650 ms.*/
/* ����� �������� ���������� */

/* �� �� ����� - ���� ����������*/
select InvoiceDate, RunningTotal from 
	(SELECT  Invoices.InvoiceDate, trans.TransactionAmount,
		SUM(TransactionAmount) over (order by InvoiceDate) As RunningTotal
		FROM Sales.Invoices AS Invoices
		JOIN Sales.CustomerTransactions AS trans
		ON Invoices.InvoiceID = trans.InvoiceID) as RT
group by InvoiceDate, RunningTotal
order by InvoiceDate;


/*3. ������� ������ 2� ����� ���������� ��������� (�� ���-�� ���������) � ������ ������ �� 2016� ���
 (�� 2 ����� ���������� �������� � ������ ������)*/

 ; WITH CTE AS
 (SELECT IL.StockItemID, IL.Quantity AS Qty,I.InvoiceDate, month(I.InvoiceDate) as Mes,
  sum (IL.Quantity) over (partition by month(I.InvoiceDate),IL.StockItemID order by IL.Quantity desc)as RecurringSum,
  DENSE_RANK () OVER (PARTITION BY month(I.InvoiceDate) ORDER BY IL.Quantity DESC) AS RNK
  FROM Sales.InvoiceLines AS IL
							join Sales.Invoices AS I
								ON I.InvoiceID = IL.InvoiceID
	where year(I.InvoiceDate)=2016
	)
Select distinct Mes, StockItemID, RNK
FROM CTE
where RNK IN (1)
order by Mes;

/**
4. ������� ����� ��������
���������� �� ������� �������, � ����� ����� ������ ������� �� ������, ��������, ����� � ����
���������� ����� ���������� ������� � �������� ����� � ���� �� �������*/
 SELECT [StockItemID],[Description],[UnitPrice],
	SUM(Quantity) over () as TotalQty
 FROM [WideWorldImporters].[Sales].[InvoiceLines]

/* ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������ */

 SELECT [StockItemID],[Description],[UnitPrice],
	LEFT ([Description],1) AS Letter,
	ROW_NUMBER () OVER (partition by LEFT ([Description],1) order by LEFT ([Description],1)) As Num
 FROM [WideWorldImporters].[Sales].[InvoiceLines]

 /*���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� �����
���������� �� ������ � ��� �� �������� ����������� (�� �����) 
�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"*/


 SELECT [StockItemID],[Description],[UnitPrice],
	LEFT ([Description],1) AS Letter,
	ROW_NUMBER () OVER (partition by LEFT ([Description],1) order by LEFT ([Description],1)) As Num,
	LAG ([Description]) over (Order by [Description]) As [Preceding],
	LAG ([Description],2,'No items') over (Order by [Description]) As [Preceding2]

 FROM [WideWorldImporters].[Sales].[InvoiceLines]

 /*����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
 �� ����� ������� � �����, ������ NTILE �� ���� */

  SELECT [StockItemID],[Description],[UnitPrice],
	NTILE (30) OVER (Order by [UnitPrice])
	
 FROM [WideWorldImporters].[Sales].[InvoiceLines]

/*4. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������
� ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������*/
Select * FROM
		(SELECT SalespersonPersonID
				, Inv.CustomerID
				, InvoiceID
				, InvoiceDate
				,Ppl.FullName
			  ,Ppl.PreferredName
			  ,Cust.CustomerName
			  ,CASE WHEN  ROW_NUMBER() OVER (PARTITION BY SalespersonPersonID ORDER BY InvoiceDate) = 1 THEN 1
			  ELSE 0 END AS Sort
		FROM [WideWorldImporters].[Sales].[Invoices] As Inv 
			join [WideWorldImporters].[Application].[People_Archive] As Ppl
			ON Inv.SalespersonPersonID = Ppl.PersonID
			join [WideWorldImporters].[Sales].[Customers_Archive] As Cust
			ON Cust.CustomerID = Inv.CustomerID 
		) AS T1
WHERE T1.Sort = 1;

/*5. �������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� ������� */

Select * FROM
		(SELECT   Inv.CustomerID
				, Inv.InvoiceID
				, InvoiceDate
				, Cust.CustomerName
				, IL.UnitPrice
				, IL.Description
			  ,CASE WHEN  ROW_NUMBER() OVER (PARTITION BY Inv.CustomerID ORDER BY IL.UnitPrice DESC) < 3 THEN 1
			  ELSE 0 END AS Sort 
		FROM [WideWorldImporters].[Sales].[Invoices] As Inv 
			join [WideWorldImporters].[Sales].[Customers_Archive] As Cust
			ON Cust.CustomerID = Inv.CustomerID 
			join Sales.InvoiceLines IL
			ON Inv.InvoiceID = IL.InvoiceID
		) AS T1
WHERE T1.Sort = 1;


