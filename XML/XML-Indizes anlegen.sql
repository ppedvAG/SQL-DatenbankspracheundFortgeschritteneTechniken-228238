USE AdventureWorks 
GO

-- Tabelle anlegen
CREATE TABLE Orders
(
	OrderID int PRIMARY KEY,
	OrderDate datetime,
	OrderNumber nvarchar(25),
	CustomerID int,
	OrderDetails xml
)
GO

-- Prim�ren Index erstellen
CREATE PRIMARY XML INDEX OrderIdx
ON Orders (OrderDetails);
GO

-- Sekund�ren PATH-Index anlegen
CREATE XML INDEX OrderPathIdx ON Orders(OrderDetails)
USING XML INDEX OrderIdx FOR PATH
GO

-- Index entfernen
DROP INDEX OrderIdx 
ON Orders;
GO

-- Tabelle enfernen
DROP TABLE Orders
GO
