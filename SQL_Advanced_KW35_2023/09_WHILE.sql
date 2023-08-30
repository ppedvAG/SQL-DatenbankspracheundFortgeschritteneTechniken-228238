WHILE 1 = 1
BEGIN
SELECT 'Hallo'

END

DECLARE @Counter int = 1

WHILE @Counter < 5
BEGIN
SELECT 'Hallo'
SET @Counter += 1      --@Counter = @Counter + 1
END

--WHILE Schleifen können weitere WHILE Schleifen beinhalten

--GOTO, BREAK & CONTINUE (WAITFOR)

--GOTO NameDesPunktes springt im Skript zu zugehörigem Punkt
Start:

SELECT 'Hallo'

GOTO Start
GOTO Ende

Ende:


--BREAK: beendet aktuelle Schleife komplett und führt weiteres Skript aus

--CONTINUE: "springt" zum Anfang der aktuelle Schleife; Wenn Continue ausgeführt wird,
--wird der Rest des Codes innerhalb der Schleife ignoriert 

DECLARE @Counter int = 1

WHILE @Counter < 5
BEGIN
IF @Counter = 3 
BEGIN 
GOTO Ende 
END
SET @Counter += 1      --@Counter = @Counter + 1
SELECT 'Hallo'
END
Ende:
SELECT 'Ende'

-- Top Produktkategorie (CategoryName) je Verkaufsland 

USE Northwind 
GO

SELECT * FROM Categories
SELECT DISTINCT Country FROM Customers

--Ergebnis in etwa so: Land, Categoriename, GesamtUmsatz (=SUM(Freight) aus Tabelle Orders)
--21 Ergebniszeilen, für jedes land, nur die Kategorie mit dem höchsten Umsatz

--Grundlage:
SELECT c.Country, CategoryName, SUM(Freight) as GesamtUmsatz
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories cat ON cat.CategoryID = p.CategoryID
GROUP BY c.Country, CategoryName
ORDER BY Country, GesamtUmsatz DESC

SET STATISTICS TIME, IO ON

--Window Function into #table
DROP TABLE IF EXISTS #t1
SELECT RANK() OVER (PARTITION BY c.Country ORDER BY SUM(Freight) DESC) as rank, c.Country, CategoryName, SUM(Freight) as Summe
INTO #t1
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od on od.OrderID = o.OrderID
JOIN Products p on p.ProductID = od.ProductID
JOIN Categories cat on cat.CategoryID = p.CategoryID
GROUP BY c.Country, CategoryName
ORDER BY Country, SUM(Freight) DESC
SELECT Country, CategoryName, Summe FROM #t1 WHERE rank = 1

--CTE mit Window Function:
;with q as(
SELECT c.Country, [CategoryName] , SUM(Freight) GesamtUmsatz
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories cat ON cat.CategoryID = p.CategoryID
GROUP BY c.Country, CategoryName
--order by Country, CategoryName)
), q2 as(
select Country, CategoryName, GesamtUmsatz, ROW_NUMBER() over (  partition by Country order by GesamtUmsatz desc) as rank from Q)
select  Country, CategoryName, GesamtUmsatz from q2 where RANK = 1


--"Komplizierter" While loop der eine #Table befüllt

USE Northwind
GO

DROP TABLE IF EXISTS #Länder
DROP TABLE IF EXISTS #IdLänder
DROP TABLE IF EXISTS #Ergebnis
GO

SELECT DISTINCT Country INTO #Länder FROM Customers WHERE Country IS NOT NULL
SELECT ROW_NUMBER() OVER(ORDER BY Country) as ID, Country INTO #IdLänder FROM #Länder
GO

--SELECT * FROM #IdLänder

DECLARE @Counter int = 1 
WHILE @Counter <= (SELECT COUNT(*) FROM #IdLänder)
BEGIN
IF OBJECT_ID('tempdb..#Ergebnis') IS NULL
BEGIN
SELECT TOP 1 Country, CategoryName, SUM(Freight) as Summe 
INTO #Ergebnis
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories cat ON cat.CategoryID = p.CategoryID
WHERE Country = (SELECT Country FROM #IdLänder WHERE ID = @Counter)
GROUP BY c.Country, CategoryName
ORDER BY Summe DESC
END
ELSE
BEGIN
INSERT INTO #Ergebnis 
SELECT TOP 1 Country, CategoryName, SUM(Freight) as Summe 
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON od.OrderID = o.OrderID
JOIN Products p ON p.ProductID = od.ProductID
JOIN Categories cat ON cat.CategoryID = p.CategoryID
WHERE Country = (SELECT Country FROM #IdLänder WHERE ID = @Counter)
GROUP BY c.Country, CategoryName
ORDER BY Summe DESC
END
SET @Counter += 1
END

SELECT * FROM #Ergebnis


SELECT ROW_NUMBER() OVER (ORDER BY Country) as Nummer, c.Country, CategoryName, SUM(Freight) as GesamtUmsatz
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] od ON od.OrderID = o.OrderID
LEFT JOIN Products p ON p.ProductID = od.ProductID
LEFT JOIN Categories cat ON cat.CategoryID = p.CategoryID

GROUP BY c.Country, CategoryName
ORDER BY Country, GesamtUmsatz DESC

--WHERE ID = %8
