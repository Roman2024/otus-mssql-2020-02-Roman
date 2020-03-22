IF DB_id(N'Capex') IS NOT NULL DROP DATABASE Capex;

/* База данных по кап затратам. В Production сопоставляются бюджет с заявками на затраты, 
 утвержденные заявки - с фактическими расходами. 
 Здесь - сильно упрощенный набросок из 3х таблиц: Бюджет, Заявки, Список предприятий. */

CREATE database Capex;

USE Capex;
-- Бюджет кап затрат c constraint по году
CREATE table Capex.dbo.Budget ([BudgetReference] nvarchar(50)  primary key,
			[YEAR] INT NULL,
			[BudgetCost] money null);

ALTER TABLE Capex.dbo.Budget ADD CONSTRAINT year_chk CHECK ([YEAR]>2000);

--Insert into Capex.dbo.Budget values ('BUDAU12', 2020, 1000), ('BUDAU13', 1999, 1000);

-- IP = Investment Proposal - заявки на капитальные затраты
CREATE TABLE IP_Master (id uniqueidentifier primary key default NEWID(),
						NumberIP int not null,
						[SiteID] int not null,
						[DateofIP] date null,
						[Description] nvarchar(300) null)

CREATE SEQUENCE NumberIP AS INT START WITH 1 INCREMENT BY 1;

-- Таблица со списком предприятий
CREATE TABLE Sites (SiteID int primary key, 
					[Site] nvarchar(30) not null); 

CREATE SEQUENCE SiteID AS INT START WITH 1 INCREMENT BY 1;
-- Добавление FK между IP_Master и Sites
ALTER TABLE [Capex].[dbo].[IP_Master] ADD CONSTRAINT fk_site FOREIGN KEY ([SiteID]) REFERENCES [Capex].[dbo].[Sites]([SiteID]);

-- Добавление значений в таблицы IP_Master и Sites
INSERT INTO Sites VALUES (NEXT VALUE FOR SiteID,'Prospect')
						,(NEXT VALUE FOR SiteID,'Murarrie')
						,(NEXT VALUE FOR SiteID,'Dalgety');

INSERT INTO [Capex].[dbo].[IP_Master] Values (default, NEXT VALUE FOR NumberIP, 1, '10/01/2020', 'Compressor upgrade'), 
											(default, NEXT VALUE FOR NumberIP, 2, '11/01/2020', 'Underfloor heating');

