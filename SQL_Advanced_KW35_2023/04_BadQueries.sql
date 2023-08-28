/* 
Wenn der Index nicht funktioniert...
Systemfunktionen (bspw. DATEPART) im Filter verhindern manchmal das Verwenden eines Index (Scan statt Seek)

Merke: Filter muss Werte haben, die mit der Tabelle abzugleichen sind (ohne Funktionsumwandlung)
z.B.: BETWEEN date AND date statt DATEPART
*/

--Beispieltabelle erstellen & befüllen:
CREATE TABLE Sales (
ID int identity PRIMARY KEY,
Datum date,
Käufer varchar(10),
Umsatz decimal(10,2) )
GO

INSERT INTO Sales
SELECT
CAST(getdate()-365*4 + (365*4*RAND()) as date),
LEFT(CAST(NEWID() as varchar(255)), 6),
CAST(RAND()*90 + 10  as decimal(10,2))
GO 50000

SELECT RAND() --Zufalls float Wert zwischen 0 und 1

SELECT * FROM Sales

--"Aufgabe": Procedure, Top 100 Umsätze + Käufername in Quartal/Jahr xy

CREATE NONCLUSTERED INDEX NCIX_Sales_Datum ON Sales (Datum) INCLUDE (Käufer, Umsatz)

--Funktioniert mit Index (seek):
ALTER PROC spTopKaeuferQuartal3 @QuartalStart date, @QuartalEnde date
AS
SELECT TOP 100
Käufer, SUM(Umsatz) as Umsatz
FROM Sales
WHERE Datum BETWEEN @QuartalStart AND @QuartalEnde
GROUP BY Käufer
ORDER BY Umsatz DESC

EXEC spTopKaeuferQuartal3 '20220701', '20220930'


CREATE NONCLUSTERED INDEX NCIX_SALES_ALL ON SALES(DATUM, KÄUFER,UMSATZ)

--Funktioniert nicht mit Index (scan):
CREATE PROC SPTOPKAEUFERQUARTAL2 @QUARTAL VARCHAR(10)
AS
SELECT TOP 100 * FROM SALES WHERE 
( @QUARTAL = '1' AND MONTH(DATUM) BETWEEN 1 AND 3) OR
( @QUARTAL = '2' AND MONTH(DATUM) BETWEEN 4 AND 6) OR
( @QUARTAL = '3' AND MONTH(DATUM) BETWEEN 7 AND 9) OR
( @QUARTAL = '4' AND MONTH(DATUM) BETWEEN 10 AND 12)
ORDER BY UMSATZ DESC

EXEC SPTOPKAEUFERQUARTAL2 1

CREATE NONCLUSTERED INDEX NCIX_SALES_ALL3 ON SALES (Käufer, Datum, Umsatz)

--Funktioniert mit Index (seek):
SELECT * FROM Sales
WHERE Käufer LIKE 'E%'

--Funktioniert nicht mit Index (scan):
SELECT * FROM Sales
WHERE SUBSTRING(Käufer, 1, 1) = 'E'


/***************************************/
--"Exkurs": 

--Between auch für Strings möglich:
SELECT * FROM Sales
WHERE Käufer BETWEEN 'E' AND 'G'


--UNION vs IN (Legacy; pre SQL Server 2019):

--schlecht:
SELECT * FROM Tabelle
WHERE ID IN (1,2)

--besser:
SELECT * FROM Tabelle
WHERE ID = 1
UNION
SELECT * FROM Tabelle
WHERE ID = 2
