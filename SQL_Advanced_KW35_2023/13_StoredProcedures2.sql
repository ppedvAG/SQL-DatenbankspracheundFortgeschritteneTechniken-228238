/*
WAITFOR TIME/DELAY
*/

CREATE PROC spWaitFor @Country varchar(50)
AS
WAITFOR DELAY '00:00:10' --TIME 'Uhrzeit' = warte bis eingetragene Uhrzeit
SELECT * FROM Customers
WHERE Country = @Country

EXEC spWaitFor Germany


/*
Ergebnis einer SP kann weiterverwendet werden (weiteres Skript oder durch weitere SP)
1. RETURN Value; 2. OUTPUT Parameter
*/


--Return Value ist by default ein int-Wert, der uns sagt ob eine SP erfolgreich gelaufen ist oder nicht
--> 0 = Fehlerfrei; ungleich 0 = Fehler
CREATE PROCEDURE spReturnDemo @Jahr int, @Quartal int
AS
SELECT 
OrderID, OrderDate
FROM Orders 
WHERE DATEPART(YEAR,OrderDate) = @Jahr AND DATEPART(QUARTER,OrderDate) = @Quartal
GO

EXEC spReturnDemo 1997, 1

DECLARE @Return int
EXEC 
@Return = spReturnDemo
@Jahr = 1997,
@Quartal = 2
SELECT @Return

--Return Value kann geändert werden zu einem beliebigen int Wert (NUR int!):

CREATE PROCEDURE spReturnDemo2 @Jahr int, @Quartal int
AS
DECLARE @GesamtUmsatz int
SELECT 
@GesamtUmsatz = SUM((Quantity * UnitPrice) * (1 - Discount)) 
FROM Orders 
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
JOIN Customers ON Customers.CustomerID = Orders.CustomerID
WHERE DATEPART(YEAR,OrderDate) = @Jahr AND DATEPART(QUARTER,OrderDate) = @Quartal
RETURN @GesamtUmsatz --Ändern des Standard-Returnwerts der Procedure
GO

DECLARE @Return2 int
EXEC 
@Return2 = spReturnDemo2
@Jahr = 1997,
@Quartal = 3
SELECT @Return2



--OUTPUT Parameter: Ergebnis einer SP ausgeben, um mit dem Ergebnis weiterarbeiten zu können
--Im Gegensatz zu RETURN kann ein OUTPUT Parameter quasi jeden Datentyp haben

--(Welcher Mitarbeiter hat in übergebenem Jahr & Quartal am meisten Umsatz generiert)
CREATE PROCEDURE spOutputDemo @Jahr int, @Quartal int, @Mitarbeiter varchar(50) OUTPUT
AS
SELECT 
LastName + ' ' + FirstName as Mitarbeiter, SUM((Quantity * UnitPrice) * (1 - Discount)) as GesamtUmsatz
INTO #t1
FROM Orders 
JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
JOIN Customers ON Customers.CustomerID = Orders.CustomerID
JOIN Employees ON Employees.EmployeeID = Orders.EmployeeID
WHERE DATEPART(YEAR,OrderDate) = @Jahr AND DATEPART(QUARTER,OrderDate) = @Quartal
GROUP BY LastName + ' ' + FirstName
SET @Mitarbeiter = 
(
SELECT TOP 1 Mitarbeiter FROM #t1
ORDER BY GesamtUmsatz DESC
)
GO

EXEC spOutputDemo 1997, 2 --Geht nicht, OUTPUT Parameter muss übergeben werden??

--Stattdessen: Variable definieren, die den OUTPUT der SP "auffängt"

DECLARE @Output varchar(100)
EXEC spOutputDemo
@Jahr = 1996,
@Quartal = 3,
@Mitarbeiter = @Output OUTPUT --Syntax: NameOutputParameter = NameAuffangvariable OUTPUT
SELECT @Output

CREATE PROCEDURE spMitarbeiterStats @Mitarbeiter varchar(50)
AS
SELECT * FROM Employees
WHERE Lastname + ' ' + Firstname = @Mitarbeiter


DECLARE @Output varchar(100)
EXEC spOutputDemo
@Jahr = 1997,
@Quartal = 4,
@Mitarbeiter = @Output OUTPUT
EXEC spMitarbeiterStats @Output



--Dynamic SQL; Schreiben von dynamischen/flexiblen SQL Abfragen über eine Procedure

ALTER PROC spDynamic @Column varchar(50)
AS
SELECT @Column FROM Customers

EXEC spDynamic Country --Funktioniert leider nicht; der @Country Parameter wird als String und nicht als DB Objekt interpretiert

--Lösung:

ALTER PROC spDynamic2 @Column varchar(50), @Table varchar(50)
AS
DECLARE @SQL varchar(250) --Variable für SQL Statement definieren
SET @SQL = 'SELECT ['+@Column+'] FROM ['+@Table+']'
EXEC (@SQL) --innerhalb der SP die "Variable ausführen"

EXEC spDynamic2 ProductName, products
