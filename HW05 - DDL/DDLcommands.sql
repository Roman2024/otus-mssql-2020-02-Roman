CREATE database Capex;

USE Capex;

CREATE table Budget ([Budget Reference] nvarchar(50)  primary key,
			[YEAR] INT NULL,
			[Budget cost] money null);

CREATE TABLE IP_Master (id int not null,
						[Site] nvarchar(30) not null,
						[Date of IP] date null,
						[Description] nvarchar(300) null)



CREATE TABLE Sites ([Site] nvarchar(30) not null primary key); 

CREATE SEQUENCE id AS INT START WITH 1 INCREMENT BY 1;

CREATE INDEX pk_ind on IP_Master (id);


ALTER TABLE [Capex].[dbo].[IP_Master] ADD CONSTRAINT fk_site FOREIGN KEY ([Site]) REFERENCES [Capex].[dbo].[Sites]([Site]);

INSERT INTO Sites VALUES ('Prospect'),('Murarrie'),('Dalgety');

INSERT INTO [Capex].[dbo].[IP_Master] Values (NEXT VALUE FOR id, 'Prospect', '10/01/2020', 'Compressor upgrade'), 
					(NEXT VALUE FOR id, 'Murarrie', '11/01/2020', 'Underfloor heating');

