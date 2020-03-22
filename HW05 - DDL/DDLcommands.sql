IF DB_id(N'Capex') IS NOT NULL DROP DATABASE Capex;

/* ���� ������ �� ��� ��������. � Production �������������� ������ � �������� �� �������, 
 ������������ ������ - � ������������ ���������. 
 ����� - ������ ���������� �������� �� 3� ������: ������, ������, ������ �����������. */

CREATE database Capex;

USE Capex;
-- ������ ��� ������ c constraint �� ����
CREATE table Capex.dbo.Budget ([BudgetReference] nvarchar(50)  primary key,
			[YEAR] INT NULL,
			[BudgetCost] money null);

ALTER TABLE Capex.dbo.Budget ADD CONSTRAINT year_chk CHECK ([YEAR]>2000);

--Insert into Capex.dbo.Budget values ('BUDAU12', 2020, 1000), ('BUDAU13', 1999, 1000);

-- IP = Investment Proposal - ������ �� ����������� �������
CREATE TABLE IP_Master (id uniqueidentifier primary key default NEWID(),
						NumberIP int not null,
						[SiteID] int not null,
						[DateofIP] date null,
						[Description] nvarchar(300) null)

CREATE SEQUENCE NumberIP AS INT START WITH 1 INCREMENT BY 1;

-- ������� �� ������� �����������
CREATE TABLE Sites (SiteID int primary key, 
					[Site] nvarchar(30) not null); 

CREATE SEQUENCE SiteID AS INT START WITH 1 INCREMENT BY 1;
-- ���������� FK ����� IP_Master � Sites
ALTER TABLE [Capex].[dbo].[IP_Master] ADD CONSTRAINT fk_site FOREIGN KEY ([SiteID]) REFERENCES [Capex].[dbo].[Sites]([SiteID]);

-- ���������� �������� � ������� IP_Master � Sites
INSERT INTO Sites VALUES (NEXT VALUE FOR SiteID,'Prospect')
						,(NEXT VALUE FOR SiteID,'Murarrie')
						,(NEXT VALUE FOR SiteID,'Dalgety');

INSERT INTO [Capex].[dbo].[IP_Master] Values (default, NEXT VALUE FOR NumberIP, 1, '10/01/2020', 'Compressor upgrade'), 
											(default, NEXT VALUE FOR NumberIP, 2, '11/01/2020', 'Underfloor heating');

