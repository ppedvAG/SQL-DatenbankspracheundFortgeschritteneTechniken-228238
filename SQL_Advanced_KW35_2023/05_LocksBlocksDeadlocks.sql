/*
SQL ist ein transaktionales System; jede Abfrage "ist eine Transaktion"
Je nachdem was die Abfrage macht, wird die jeweilige Ressource gesperrt (Lock(ing))
Locks gibt es für: Row, Table, Scheme, Database
Andere Abfragen/Sessions können u.U. auf gelockte Ressource nicht zugreifen und müssen warten (Blocking)
Hinweis: Rowlocks können u.U. umgangen werden, wenn es geeignete Indizes gibt (Seek statt Scan)

Wenn sich 2 Transactions gegenseitig blocken, und diese Situation nicht von alleine lösbar ist
--> sog. Deadlock
SQL Server prüft alle 5 Sekunden auf Deadlock Situation und terminiert eine der beiden Transactions (=Rollback)
(Theoretisch die mit dem geringeren Rollback-Aufwand)

Deadlock Situationen vermeiden:
- Retry ON SQL Error 1205 in Anwendungen einbauen
- Nicht zu viele Statements in dieselbe Transaction packen; nur wenn systemkritisch!
- Auf Programmierfluss achten! (Vergleiche Fließband; immer dieselben Tabellen in der selben Reihenfolge ansprechen)
*/

--Umgehen von Locks mit WITH NOLOCK Hint - Nur für Leseanforderungen möglich:
SELECT * FROM Customers WITH (NOLOCK)

--Umgeht eventuelle Sperre (Lock) der zu lesenden Ressource
--Aber Vorsicht: u.U. werden falsche/veraltete Daten gelesen!


--Leitet Transaktionsstatus ein:
BEGIN TRANSACTION --oder kurz TRAN

SELECT @@TRANCOUNT --Gibt aktuelles Transaktionslevel zurück (0 = keine Transaction)

--Beenden der Transaktion:
COMMIT --Schreibt in Datenbank ("Passt")
ROLLBACK --Macht Transaktion rückgängig ("Passt nicht")

--Tests mit Abfragen während einer Transaction; Können andere Sessions die Ressource aufrufen?:
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

--Für Anschaulichkeit unter "Fenster - Neue vertikale Registerkartengruppe" 2. Session erstellen

--Beispieltabellen erstellen & befüllen:

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
Transaktionen Schritt für Schritt abwechselnd in beiden Sessions ausführen
um Deadlock Szenario zu simulieren
*/

