/*
SQL ist ein transaktionales System; jede Abfrage "ist eine Transaktion"
Je nachdem was die Abfrage macht, wird die jeweilige Ressource gesperrt (Lock(ing))
Locks gibt es f�r: Row, Table, Scheme, Database
Andere Abfragen/Sessions k�nnen u.U. auf gelockte Ressource nicht zugreifen und m�ssen warten (Blocking)
Hinweis: Rowlocks k�nnen u.U. umgangen werden, wenn es geeignete Indizes gibt (Seek statt Scan)

Wenn sich 2 Transactions gegenseitig blocken, und diese Situation nicht von alleine l�sbar ist
--> sog. Deadlock
SQL Server pr�ft alle 5 Sekunden auf Deadlock Situation und terminiert eine der beiden Transactions (=Rollback)
(Theoretisch die mit dem geringeren Rollback-Aufwand)

Deadlock Situationen vermeiden:
- Retry ON SQL Error 1205 in Anwendungen einbauen
- Nicht zu viele Statements in dieselbe Transaction packen; nur wenn systemkritisch!
- Auf Programmierfluss achten! (Vergleiche Flie�band; immer dieselben Tabellen in der selben Reihenfolge ansprechen)
*/

--Umgehen von Locks mit WITH NOLOCK Hint - Nur f�r Leseanforderungen m�glich:
SELECT * FROM Customers WITH (NOLOCK)

--Umgeht eventuelle Sperre (Lock) der zu lesenden Ressource
--Aber Vorsicht: u.U. werden falsche/veraltete Daten gelesen!


--Leitet Transaktionsstatus ein:
BEGIN TRANSACTION --oder kurz TRAN

SELECT @@TRANCOUNT --Gibt aktuelles Transaktionslevel zur�ck (0 = keine Transaction)

--Beenden der Transaktion:
COMMIT --Schreibt in Datenbank ("Passt")
ROLLBACK --Macht Transaktion r�ckg�ngig ("Passt nicht")

--Tests mit Abfragen w�hrend einer Transaction; K�nnen andere Sessions die Ressource aufrufen?:
UPDATE Customers
SET City = 'Burghausen'
WHERE CustomerID = 'ALFKI'

CREATE TABLE BlockingFragezeichen (
ID int identity PRIMARY KEY,
BlockingBloed varchar(50) )

SELECT * FROM Customers
WHERE CustomerID = 'ALFKI'


CREATE NONCLUSTERED INDEX NCIX_Alles ON Customers (Country) 
INCLUDE ([CustomerID], [CompanyName], [ContactName], [ContactTitle], [Address], [City], [Region], [PostalCode], [Phone], [Fax], [NeueColumn])

--69 von 91 Rows: "Manchmal" sperrt SQL Server den ganzen Table, wenn sehr viele Rows gelockt werden
--> sog. "Lock Escalation"
SELECT * FROM Customers
WHERE Region IS  NULL

BEGIN TRANSACTION
SELECT @@TRANCOUNT
ROLLBACK

UPDATE Customers
SET City = 'Burghausen'
WHERE Region IS NULL


/********************************************************/

--Deadlock Simulation: 

USE Northwind
GO

DROP TABLE IF EXISTS Links
DROP TABLE IF EXISTS Rechts
GO

--F�r Anschaulichkeit unter "Fenster - Neue vertikale Registerkartengruppe" 2. Session erstellen

--Beispieltabellen erstellen & bef�llen:

CREATE TABLE Links (
ID int identity PRIMARY KEY,
Werte varchar(10) )
GO

INSERT INTO Links
SELECT 'Links'
GO 10

CREATE TABLE Rechts (
ID int identity PRIMARY KEY,
Werte varchar(10) )
GO

INSERT INTO Rechts
SELECT 'Rechts'
GO 10

--Transaktionsskripte vorbereiten (in Session "links"):

BEGIN TRAN

UPDATE Links
SET Werte = 'LinksNeu'

UPDATE Rechts
SET Werte = 'RechtsNeu'

ROLLBACK

--Transaktionsskripte vorbereiten (in Session "rechts"):

BEGIN TRAN

UPDATE Rechts
SET Werte = 'RechtsNeu'
WHERE ID = 2

UPDATE Links
SET Werte = 'LinksNeu'
WHERE ID = 2

ROLLBACK

/*
Transaktionen Schritt f�r Schritt abwechselnd in beiden Sessions ausf�hren
um Deadlock Szenario zu simulieren
*/

