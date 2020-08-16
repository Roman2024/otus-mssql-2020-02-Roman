USE [WideWorldImporters]
GO



/* 1) Написать функцию возвращающую Клиента с наибольшей суммой покупки. ******/
create function function1z ()
Returns table as
RETURN
		select top 1 
		[CustomerID]
		,[TransactionAmount]
		from [WideWorldImporters].[Sales].[CustomerTransactions]
		order by [TransactionAmount] desc
;
select * from function1z ()

/* 2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines */


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* ALTER PROCEDURE [dbo].[SP_Max] AS */

-- Select CustomerID, InvoiceSum
--	from [Sales].[Invoices] 
--	join (
--		  select top 1 InvoiceID, SUM(ExtendedPrice) as InvoiceSum
--		   from [WideWorldImporters].[Sales].[InvoiceLines]
--		  group by InvoiceID
--		  order by SUM(ExtendedPrice) desc) as MaxInvoice
--  on Invoices.InvoiceID=MaxInvoice.InvoiceID ;
  
--GO
CREATE PROCEDURE [dbo].[SP_Max] (@klient_id int) AS --CREATE/ALTER
SELECT SUM(ExtendedPrice), CustomerID, COUNT(I.InvoiceID) AS NumberOfInvoices

FROM [WideWorldImporters].[Sales].[InvoiceLines] IL
JOIN [WideWorldImporters].[Sales].[Invoices] I
ON I.[InvoiceID] = IL.[InvoiceID]
WHERE [CustomerID] = @klient_id
GROUP BY CustomerID
;
GO  

EXECUTE SP_Max 834;

/*3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
set statistics time on;

GO  
CREATE PROCEDURE SP2343232 AS
SELECT * FROM [WideWorldImporters].[Sales].[InvoiceLines];
GO
/*SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 122 ms.*/


GO  
CREATE FUNCTION Function1234422 (@customer_id int) 
RETURNS TABLE	
AS RETURN
SELECT * FROM [WideWorldImporters].[Sales].[InvoiceLines]
;
/* SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 45 ms.*/


/*4) Создайте табличную функцию покажите как ее можно вызвать для каждой 
строки result set'а без использования цикла.
*/

create function fn_city2 (@CityID int) 
returns VARCHAR(50)
as
begin
DECLARE @site_name VARCHAR(50); 
IF @CityID < 10 SET @site_name = 'to be destroyed'; 
ELSE SET @site_name = 'not to be destroyed';
 RETURN @site_name; 
 END;

 --EXEC fn_city2 @CityID=1;

 select cityId, cityName, dbo.fn_city2 (CityID) from Application.cities
 where CityID <15;
 
   