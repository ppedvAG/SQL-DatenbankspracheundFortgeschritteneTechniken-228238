/*

Datensätze werden auf sog. Pages/Seiten abgespeichert

1 Datensatz muss grundsätzlich vollständig auf eine Seite passen
- LOB Datentypen dürfen größer werden als 8kb; werden auf sog. LOB Pages gespeichert
- bspw. varchar(MAX), (text)
- oder maximal ca. 700 Datensätze pro Page (wenn Speicherplatz noch nicht voll ist)

1 Seite hat ca. 8kb Speicherplatz für Daten, Rest (ca. 130Byte reserviert für Metadaten)
(8 Seiten nennt man 1 Block)

1 Byte = tinyint
2 Byte = smallint
4 Byte = int
8 Byte = bigint


*/
USE Northwind
GO

CREATE TABLE Pages (
ID int identity,
BadDatatype char(4100) )

INSERT INTO Pages
SELECT 'abc'
GO 100

--Metadaten zu Seitenzahl/Dichte/Füllgrad etc. ausgeben:
dbcc showcontig('Pages')

CREATE TABLE Pages2 (
ID int identity,
BadDatatype varchar(4100) )

INSERT INTO Pages2
SELECT 'abc'
GO 100

dbcc showcontig('Pages2')

SELECT * FROM Pages
SELECT * FROM Pages2