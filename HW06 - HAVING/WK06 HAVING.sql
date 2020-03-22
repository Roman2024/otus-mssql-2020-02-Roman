--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
USE [WideWorldImporters];

Select AVG(IL.UnitPrice) as 'Средняя цена товара'
	, SUM(IL.[ExtendedPrice]) as 'Сумма продаж'
	, Month(I.[InvoiceDate]) as 'Мес'
	, year(I.[InvoiceDate]) as 'Год'

FROM [WideWorldImporters].[Sales].[InvoiceLines] IL 
	join [WideWorldImporters].[Sales].[Invoices] I
	ON IL.InvoiceID= I.InvoiceID
GROUP BY Month(I.[InvoiceDate]), year(I.[InvoiceDate])
ORDER BY year(I.[InvoiceDate]), Month(I.[InvoiceDate]);

--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
USE [WideWorldImporters];

Select AVG(IL.UnitPrice) as 'Средняя цена товара'
	, SUM(IL.[ExtendedPrice]) as 'Сумма продаж'
	, Month(I.[InvoiceDate]) as 'Мес'
	, year(I.[InvoiceDate]) as 'Год'

FROM [WideWorldImporters].[Sales].[InvoiceLines] IL 
	join [WideWorldImporters].[Sales].[Invoices] I
	ON IL.InvoiceID= I.InvoiceID
GROUP BY Month(I.[InvoiceDate]), year(I.[InvoiceDate])
-- условие по группе
HAVING SUM(IL.[ExtendedPrice])>10000
ORDER BY year(I.[InvoiceDate]), Month(I.[InvoiceDate]);


/** 3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, 
по товарам, продажи которых менее 50 ед в месяц.
Группировка должна быть по году и месяцу. **/


4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
Дано :
CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);
INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

Результат вывода рекурсивного CTE:
EmployeeID Name Title EmployeeLevel
1 Ken Sánchez Chief Executive Officer 1
273 | Brian Welcker Vice President of Sales 2
16 | | David Bradley Marketing Manager 3
23 | | | Mary Gibson Marketing Specialist 4
274 | | Stephen Jiang North American Sales Manager 3
276 | | | Linda Mitchell Sales Representative 4
275 | | | Michael Blythe Sales Representative 4
285 | | Syed Abbas Pacific Sales Manager 3
286 | | | Lynn Tsoflias Sales Representative 4

