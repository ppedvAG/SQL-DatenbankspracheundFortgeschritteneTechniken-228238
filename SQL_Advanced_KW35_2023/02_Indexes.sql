--Abfrageplan: Scan �ber ganze Tabelle; alle Seiten mussten gelesen werden (schlecht):
SELECT * FROM Pages
WHERE ID = 50

/*
Warum? Weil Table ohne (gruppierten) Index = Heap (Haufen)
Heap ist nicht sortiert, d.h. Datens�tze/Pages "liegen irgendwo"
Ein Heap muss IMMER komplett gescannt werden, um einzelne Datens�tze auszugeben
*/
SELECT * FROM Pages

/*
Arten von Indizes:

1. Clustered Index/gruppierter Index/CIX erstellen
- 1 pro Tabelle; "sortiert" Datens�tze (im File) nach indizierter Spalte
- Wenn wir einen PK (Primary Key) erstellen, wird daf�r automatisch ein CIX erstellt
- Filter auf Spalte im CIX k�nnen jetzt gezielt gefunden werden (=Seek) statt ganze Tabelle zu lesen (=Scan)
*/

ALTER TABLE Pages
ADD CONSTRAINT PK_Pages PRIMARY KEY (ID)

--Mit CIX = Seek/Suche; grunds�tzlich w�nschenswert
SELECT * FROM Pages
WHERE ID = 50


/*
2. Non Clustered Index/nicht gruppierter Index/NCIX
- soviele wie wir wollen pro Tabelle (ca. 1000)
- "Kopie" des CIX, mit anderer Sortierung, und u.U. nur einem Teil der Spalten
- Jeder Datensatz im NCIX hat noch einen "Querverweis"

Ein paar "Faustregeln":
- mehr als 5 Spalten in einem NCIX meistens "schlecht"!
- nicht mehr als 5-6 NCIX pro Table
- Je mehr Writes auf einem Table, desto weniger Indizes
- Umgekehrt: Wenn viel gelesen wird, und wenig geschrieben: Indizes grunds�tzlich besser
- CIX auf ID Spalten (PK Spalten/unique Spalten)
- NCIX auf Spalten die oft gefiltert werden; ebenso auf FK Spalten (Joins)

*/

--Systemviews f�r Index Metadaten:
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Customers2'), NULL, NULL, 'detailed') --'limited'
SELECT * FROM sys.dm_db_index_usage_stats
--SELECT * FROM sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('Customers2'), NULL, NULL)

SELECT * INTO Customers2 FROM Customers

CREATE CLUSTERED INDEX CIX_Customers2_ID ON Customers2 (CustomerID)

SELECT * FROM Customers2
WHERE CustomerID = 'ALFKI'

SELECT Country, City, Address FROM Customers2
WHERE Country = 'Germany'

CREATE NONCLUSTERED INDEX NCIX_Customers2_CountryCity ON Customers2 (Country) INCLUDE (City, Address)


SELECT Country, City, Address from Customers2
WHERE Country = 'Germany'

SELECT CustomerID, Country, City, Address FROM Customers2
WHERE Country = 'Germany'


CREATE NONCLUSTERED INDEX NCIX_Customers2_CountryCity1 ON Customers2 (Country) INCLUDE (City, Address)
--Leichter in der Wartung, weil weniger Sortiervorg�nge, dadurch auch weniger Fragmentierung

CREATE NONCLUSTERED INDEX NCIX_Customers2_CountryCity2 ON Customers2 (Country,City,Address)
--u.U. schneller, wenn nach mehr als einer Spalte gefiltert wird

-->F�r die Readvorg�nge aber irrelevant

SELECT Country, City, Address, PostalCode FROM Customers2
WHERE Country = 'Germany'


INSERT INTO Customers2
SELECT * FROM Customers2
GO 2

SELECT * FROM Customers2

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Customers2'), NULL, NULL, 'limited') --'limited'
SELECT * FROM sys.dm_db_index_usage_stats

SELECT Country, City, Address, PostalCode FRom Customers2
WHERE Country = 'Germany'

--Monitoring Statistiken:

SET STATISTICS TIME, IO ON --OFF


/*
3. Columnstore Index
- Speichert Datens�tze spaltenweise, d.h. Spalte 1, Spalte 2 usw...
- F�r sehr gro�e Datenmengen (Datawarehouse; generell OLAP System)
- Bis zu 10 Mal bessere compression als Rowstore
--> sehr viel weniger I/O --> bessere Performance
- Sehr gut f�r Aggregatbildung (weil spaltenweise)
- (k�nnen auch nonclustered parallel zu rowstore Tabellen erstellt werden (F�r Live Analytics))
*/


SELECT * FROM Bestellungen1

CREATE CLUSTERED COLUMNSTORE INDEX COLIX_Bestellungen2 ON Bestellungen2

SET STATISTICS TIME ON

SELECT BestellDatum, SUM(Bestellwert) FROM Bestellungen1
GROUP BY BestellDatum

SELECT BestellDatum, SUM(Bestellwert) FROM Bestellungen2
GROUP BY BestellDatum