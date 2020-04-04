--Insert, Update, Merge
/*1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers*/
INSERT INTO WideWorldImporters.Purchasing.Suppliers
		( SupplierID
      ,SupplierName
      ,SupplierCategoryID
      ,PrimaryContactPersonID
      ,AlternateContactPersonID
      ,DeliveryMethodID
      ,DeliveryCityID
      ,PostalCityID
      ,SupplierReference
      ,BankAccountName
      ,BankAccountBranch
      ,BankAccountCode
      ,BankAccountNumber
      ,BankInternationalCode
      ,PaymentDays
      ,InternalComments
      ,PhoneNumber
      ,FaxNumber
      ,WebsiteURL
      ,DeliveryAddressLine1
      ,DeliveryAddressLine2
      ,DeliveryPostalCode
      ,DeliveryLocation
      ,PostalAddressLine1
      ,PostalAddressLine2
      ,PostalPostalCode
      ,LastEditedBy
      ,ValidFrom
      ,ValidTo)
VALUES
(default,'Woodgrove Shop2321',7,45,46,NULL,30378,30378,28034202,'Woodgrove Shop','Woodgrove San Francisco',325698,2147825698,65893,7,'Peter Pen','(415) 555-0103','(415) 555-0107','http://www.woodgroveshop.com','Level 3','8488 Vienna Boulevard',94101,0xE6100000010C529ACDE330E34240DFFB1BB4D79A5EC0,'PO Box 2390','Canterbury',94101,1,default,default),
(default,'The Company3222',2,43,44,7,17346,17346,237408032,'The Company','Woodgrove Bank Karlstad',214568,7896236589,25478,30,NULL,'(218) 555-0105','(218) 555-0105','http://www.thephone-company.com','Level 83','339 Toorak Road',56732,0xE6100000010C1D1B26BFEA494840BF993D75512158C0,'PO Box 3837','Ferny Wood',56732, 1,default,default),	
(default,'Woodgrove Shop2323',7,45,46,NULL,30378,30378,28034202,'Woodgrove Shop','Woodgrove San Francisco',325698,2147825698,65893,7,'Peter Pen','(415) 555-0103','(415) 555-0107','http://www.woodgroveshop.com','Level 3','8488 Vienna Boulevard',94101,0xE6100000010C529ACDE330E34240DFFB1BB4D79A5EC0,'PO Box 2390','Canterbury',94101,1,default,default),	
(default,'The Company2224',2,43,44,7,17346,17346,237408032,'The Company','Woodgrove Bank Karlstad',214568,7896236589,25478,30,NULL,'(218) 555-0105','(218) 555-0105','http://www.thephone-company.com','Level 83','339 Toorak Road',56732,0xE6100000010C1D1B26BFEA494840BF993D75512158C0,'PO Box 3837','Ferny Wood',56732, 1,default,default),	
(default,'The Company33325',2,43,44,7,17346,17346,237408032,'The Company','Woodgrove Bank Karlstad',214568,7896236589,25478,30,NULL,'(218) 555-0105','(218) 555-0105','http://www.thephone-company.com','Level 83','339 Toorak Road',56732,0xE6100000010C1D1B26BFEA494840BF993D75512158C0,'PO Box 3837','Ferny Wood',56732, 1,default,default)
;

--2. удалите 1 запись из Customers, которая была вами добавлена
Delete from WideWorldImporters.Purchasing.Suppliers
where SupplierName='Woodgrove Shop2321';

--3. изменить одну запись, из добавленных через UPDATE
UPDATE WideWorldImporters.Purchasing.Suppliers
SET InternalComments = 'Very important';

--4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть

CREATE TABLE #Otus();

Drop table IF EXISTS #Otus;
Select * 
into #Otus
from WideWorldImporters.Purchasing.Suppliers
where SupplierName = 'Woodgrove Shop';

UPDATE #Otus
SET SupplierName = 'Woodgrove Shop88';

MERGE WideWorldImporters.Purchasing.Suppliers S
USING #Otus O
ON S.SupplierID = O.SupplierID
WHEN MATCHED 
   THEN UPDATE SET
   S.SupplierName = O.SupplierName

WHEN NOT MATCHED BY TARGET 
   THEN INSERT
   VALUES (default
      ,O.SupplierName
      ,O.SupplierCategoryID
      ,O.PrimaryContactPersonID
      ,O.AlternateContactPersonID
      ,O.DeliveryMethodID
      ,O.DeliveryCityID
      ,O.PostalCityID
      ,O.SupplierReference
      ,O.BankAccountName
      ,O.BankAccountBranch
      ,O.BankAccountCode
      ,O.BankAccountNumber
      ,O.BankInternationalCode
      ,O.PaymentDays
      ,O.InternalComments
      ,O.PhoneNumber
      ,O.FaxNumber
      ,O.WebsiteURL
      ,O.DeliveryAddressLine1
      ,O.DeliveryAddressLine2
      ,O.DeliveryPostalCode
      ,O.DeliveryLocation
      ,O.PostalAddressLine1
      ,O.PostalAddressLine2
      ,O.PostalPostalCode
      ,O.LastEditedBy
      ,default
      ,default)
OUTPUT $action, deleted.*,  inserted.*;


--5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
select @@SERVERNAME

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  


--exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "E:\SQL WWI\InvoiceLines15.txt" -T -w -t, -S KRISTINAATWORK\MSSQLSERVER01'

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "C:\Samples\InvoiceLines16.txt" -T -w -t"@eu&$1&" -S LAPTOP-OOPA099K\SQLEXPRESS'

--BULK INSERT

BULK INSERT [WideWorldImporters].[Sales].[InvoiceLines_BulkDemo]
FROM "C:\Samples\InvoiceLines16.txt"
WITH 
	(
	BATCHSIZE = 1000,
	DATAFILETYPE = 'widechar',
	FIELDTERMINATOR = '@eu&$1&',
	ROWTERMINATOR = '\n',
	KEEPNULLS,
	TABLOCK
	);

