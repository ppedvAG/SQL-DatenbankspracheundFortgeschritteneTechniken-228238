USE AdventureWorks 
GO

-- Tabelle anlegen
CREATE TABLE Orders
(
	OrderID int,
	OrderDate datetime,
	CustomerID int,
	OrderItems xml DEFAULT CAST(N'<Items/>' AS xml)
)
GO

DECLARE @items nvarchar(200)
SET @Items = 
	N'<Items>
		<Item ProductID="1" Quantity="10"/>
	</Items>'

-- Datensatz einfügen
INSERT INTO Orders
VALUES (1, GetDate(), 1, @Items)

-- Datensatz in lokaler Variable speichern
DECLARE	@OrderItems xml
SELECT	@OrderItems = OrderItems FROM Orders

-- Ergebnis ausgeben
SELECT @OrderItems

-- Tabelle entfernen
DROP TABLE Orders
GO
