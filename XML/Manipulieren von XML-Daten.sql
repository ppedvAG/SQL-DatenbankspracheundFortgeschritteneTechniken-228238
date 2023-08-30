USE AdventureWorks 
GO

-- Variable mit XML erstellen
DECLARE @OrderDetails xml
SET @OrderDetails = 
'<Root>
	<OrderDetail OrderDetailID="1"/>
</Root>'

-- Daten einfügen mit der insert-Methode
SET @OrderDetails.modify('
insert <OrderDetail OrderDetailID="2"/>
into (/Root)[1]') 
select @OrderDetails

-- Daten am Anfang einfügen mit insert/first
SET @OrderDetails.modify('
insert <OrderDetail OrderDetailID="2"/>
as first
into (/Root)[1]') 
select @OrderDetails

-- Daten löschen mit der delete-Methode
SET @OrderDetails.modify('
delete /Root/OrderDetail[@OrderDetailID = 1]')
select @OrderDetails

-- Daten ändern mit der replace value of-Methode
SET @OrderDetails.modify('
replace value of (/Root/OrderDetail/@OrderDetailID)[1]
with 100')
select @OrderDetails