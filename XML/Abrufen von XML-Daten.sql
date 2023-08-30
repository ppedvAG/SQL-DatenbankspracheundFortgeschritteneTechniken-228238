USE Northwind
GO



select * from customers for xml RAW
select * from customers for xml Auto, elements

select * from Customers for xml PATH ('KUNDE'), ROOT('Kunden')

select 
	CustomerID as [Customerid/ID],
	City as [Customerid/ID/STADT],
	country as [Customerid/ID/LAND]
from customers  for xml PATH



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

-- Testdatensatz anlegen
INSERT INTO Orders (OrderID, OrderDate, OrderNumber, CustomerID, OrderDetails)
VALUES (43659, '2001-07-01 00:00:00.000', 'SO43659', 676,
N'<Root>
	<OrderDetail OrderDetailID="1" OrderID="43659" Quantity="1" ProductID="776" UnitPrice="2024.9940" />
	<OrderDetail OrderDetailID="2" OrderID="43659" Quantity="3" ProductID="777" UnitPrice="2024.9940" />
	<OrderDetail OrderDetailID="3" OrderID="43659" Quantity="1" ProductID="778" UnitPrice="2024.9940" />
</Root>')
GO

-- Zugriff mit der query-Methode (XPath)
SELECT	OrderDetails.query('/Root/OrderDetail[@ProductID = 776]') AS OrderDetails
FROM	Orders
GO

-- Zugriff mit der query-Methode (XQuery)
SELECT	OrderDetails.query('
		for $i in /Root/OrderDetail
		where /Root/OrderDetail[@ProductID = 776]
		return $i
		') AS OrderDetails
FROM	Orders
GO

-- Zugriff mit der exist-Methode
SELECT	OrderDetails
FROM	Orders
WHERE	OrderDetails.exist('/Root/OrderDetail[@ProductID = 776]') = 1
GO

-- Zugriff mit der value-Methode
SELECT	OrderDetails.value('(/Root/OrderDetail/@ProductID)[1]', 'int') AS ProductID
FROM	Orders
WHERE	OrderDetails.exist('/Root/OrderDetail[@OrderDetailID = 1]') = 1
GO

-- Zugriff mit der nodes-Methode
SELECT	Orders2.OrderDetails.query('.') AS OrderDetails
FROM	Orders
CROSS APPLY OrderDetails.nodes('/Root/OrderDetail[@OrderDetailID]') AS Orders2(OrderDetails)
GO

-- Tabelle enfernen
DROP TABLE Orders
GO
