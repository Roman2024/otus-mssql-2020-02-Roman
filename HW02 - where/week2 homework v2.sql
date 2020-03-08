
 --1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal

  select * from [WideWorldImportersDW].[Dimension].[Stock Item]
  where [Stock Item] like '%urgent%' 
	OR [Stock Item] like 'Animal%';

 
 /** 2. �����������, � ������� �� ���� ������� �� ������ ������ 
  (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)**/
  
  select * from 
  [WideWorldImportersDW].[Fact].[Purchase] P right join [WideWorldImportersDW].[Dimension].[Supplier] S
  on p.[Supplier Key] = s.[Supplier Key]
  where [Purchase Key] is null;




/**3. ������� � ��������� ������, � ������� ���� �������, ������� ��������, � �������� ��������� �������,
 �������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������, 
 ���� ������ ������ ������ ���� ������, � ����� ������ ����� 100$ ���� ���������� ������ ������
  ����� 20. �������� ������� ����� ������� � ������������ �������� ��������� ������ 1000 � ��������� 
  ��������� 100 �������. ���������� ������ ���� �� ������ ��������, ����� ����, ���� �������.**/



select datepart(month,[Delivery Date Key]) Month, datename(quarter,[Delivery Date Key]) Q
, sum([Quantity]) [Sum of Qty],sum([Total Including Tax]) [$$$]
	,CASE
		WHEN MONTH(S.[Delivery Date Key]) > 8 THEN 3
		WHEN MONTH(S.[Delivery Date Key]) > 4 THEN 2
	ELSE 1
	END AS InvoiceThirdOfTheYear
  
  from [WideWorldImportersDW].[Fact].[Sale] S
  where [Delivery Date Key] is not null AND ([Quantity]>20 OR [Total Including Tax]>100)
  group by datepart(month,[Delivery Date Key]),datename(quarter,[Delivery Date Key])
  order by Month;


/**4. ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post, 
�������� �������� ����������, ��� ����������� ���� ������������ ����� **/

select PS.SupplierName,  P.FullName, O.*
  from [WideWorldImporters].[Purchasing].[PurchaseOrders] O
  join Application.DeliveryMethods D
  on D.DeliveryMethodID = O.DeliveryMethodID
  join Purchasing.Suppliers PS
  on PS.SupplierID = O.SupplierID
  join Application.People P
  on P.PersonID = O.ContactPersonID
  
  where year(OrderDate) = 2014 and D.DeliveryMethodName IN ('Road Freight','Post');



--5. 10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����.
  Select top 10 O.[Order Date Key], E.[Employee],C.[Customer]

  from [WideWorldImportersDW].[Fact].[Order] O 
  join [WideWorldImportersDW].[Dimension].[Employee] E
  on O.[Salesperson Key]=E.[Employee Key]
  join [WideWorldImportersDW].[Dimension].[Customer] C
  on O.[Customer Key]=C.[Customer Key]
  Order by O.[Order Date Key] desc;

 -- 6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g

 Select O.CustomerID, C.CustomerName, C.PhoneNumber
  from [WideWorldImporters].[Sales].[Orders] O
  join [WideWorldImporters].[Sales].[OrderLines] OL
  on O.OrderID = OL.OrderID
  join Sales.Customers C
  on C.CustomerID = C.CustomerID
   where OL.[Description] = 'Chocolate frogs 250g' ;


