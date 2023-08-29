--Views machen manchmal komische Sachen...
--Ein Beispiel:

CREATE TABLE StadtLandFluss (
ID int,
Stadt int,
Land int )

INSERT INTO StadtLandFluss
VALUES (1, 10, 100),
(2, 20, 200),
(3, 30, 300)

CREATE VIEW vStadtLandFluss
AS
SELECT * FROM StadtLandFluss

SELECT * FROM StadtLandFluss
SELECT * FROM vStadtLandFluss

--Column zu Table hinzufügen & befüllen:
ALTER TABLE StadtLandFluss
ADD Fluss int

UPDATE StadtLandFluss
SET Fluss = ID * 1000

SELECT * FROM StadtLandFluss

--Wie sieht die View aus?
SELECT * FROM vStadtLandFluss

--Column aus Table löschen:
ALTER TABLE StadtLandFluss
DROP COLUMN Land

SELECT * FROM StadtLandFluss

--Wie sieht die View jetzt aus?
SELECT * FROM vStadtLandFluss
-- :-O

--Lösung (zumindestens für DROP Column) über WITH SCHEMABINDING:

DROP TABLE StadtLandFluss
DROP VIEW vStadtLandFluss
GO
--(IntelliSense Cache leeren: STRG+SHIFT+R)

--Spaltennamen explizit (kein *) und Tabellenaufruf mit Schemaname.Tabellenname
CREATE VIEW vStadtLandFluss WITH SCHEMABINDING
AS
SELECT ID, Stadt, Land FROM dbo.StadtLandFluss

ALTER TABLE StadtLandFluss
DROP COLUMN Land
--nicht möglich da ein Objekt (unsere View) von dieser Spalte abhängig ist (Schemabinding)


--View indizieren:
--Step 1: View WITH SCHEMABINDING erstellen
--Step 2: Unique Clustered Index auf View erstellen
--Step 3: NCIX auf View wie gewünscht
--Vorsicht: View Indexes müssen auch geupdatet/gewartet werden!

CREATE UNIQUE CLUSTERED INDEX CIX_ViewSLF ON vStadtLandFluss (ID)

--Query Optimizer kann indizierte Views verwenden,um Abfragen auf den zugehörigen Tabellen zu machen!

SELECT * FROM StadtLandFluss
WHERE ID = 1


/*
Wir können Views "partitionieren"
*/

SELECT * FROM Sales

--Aus einer großen Tabelle, mehrere kleine erstellen

CREATE TABLE Sales2021 (
ID int Identity PRIMARY KEY,
Datum date,
Umsatz int )

INSERT INTO Sales2021
SELECT '20210501', 15

CREATE TABLE Sales2022 (
ID int Identity PRIMARY KEY,
Datum date,
Umsatz int )

INSERT INTO Sales2022
SELECT '20220501', 15

SELECT * FROM Sales2021
SELECT * FROM Sales2022

CREATE NONCLUSTERED INDEX NCIXSales2021 ON Sales2021 (Datum)
CREATE NONCLUSTERED INDEX NCIXSales2022 ON Sales2022 (Datum)


--View erstellen, die alle Teiltabellen abdeckt:

CREATE VIEW SalesALL
AS
SELECT * FROM Sales2021
UNION
SELECT * FROM Sales2022

SELECT ID, Datum FROM SalesAll
WHERE Datum BETWEEN '20210101' AND '20211231'

--Check Constraints auf Einzeltabellen legen: (ohne Functions! Sonst funktioniert nicht!)

ALTER TABLE Sales2021
ADD CONSTRAINT CHK_Datum2021 CHECK (Datum BETWEEN '20210101' AND '20211231')

ALTER TABLE Sales2022
ADD CONSTRAINT CHK_Datum2022 CHECK (Datum BETWEEN '20220101' AND '20221231')

INSERT INTO Sales2021
SELECT '20220501', 99

INSERT INTO Sales2022
SELECT '20210501', 50

--View liest jetzt nur noch einzelne Tables, die relevant sind:
SELECT ID, Datum FROM SalesAll
WHERE Datum BETWEEN '20210101' AND '20211231'



--Updateable Views  /WIP

INSERT INTO SalesALL
VALUES ('20221224', 999)

DROP TABLE Sales2021_2
DROP TABLE Sales2022_2
DROP VIEW vSalesAll_2

CREATE TABLE Sales2021_2 (
ID int PRIMARY KEY,
Datum date NOT NULL,
Umsatz int )

INSERT INTO Sales2021_2
SELECT 1, '20210501', 15

CREATE TABLE Sales2022_2 (
ID int PRIMARY KEY,
Datum date NOT NULL,
Umsatz int )

INSERT INTO Sales2022_2
SELECT 1, '20220501', 15

SELECT * FROM Sales2021_2
SELECT * FROM Sales2022_2

CREATE VIEW vSalesALL_2 AS
SELECT * FROM Sales2021_2
UNION
SELECT * FROM Sales2022_2

INSERT INTO vSalesALL_2
VALUES (2, '20221224', 99)

CREATE NONCLUSTERED INDEX NCIXSales2021 ON Sales2021_2 (Datum)
CREATE NONCLUSTERED INDEX NCIXSales2022 ON Sales2022_2 (Datum)

ALTER TABLE Sales2021_2
ADD CONSTRAINT CHK_Datum2021_2 CHECK (Datum BETWEEN '20210101' AND '20211231')

ALTER TABLE Sales2022_2
ADD CONSTRAINT CHK_Datum2022_2 CHECK (Datum BETWEEN '20220101' AND '20221231')

SELECT ID, Datum FROM vSalesAll_2
WHERE Datum BETWEEN '20210101' AND '20211231'

--Sequence für ID Spalte erstellen:

CREATE SEQUENCE sq_AutoID_2
START WITH 2
INCREMENT BY 1

INSERT INTO vSalesALL_2
VALUES (NEXT VALUE FOR sq_AutoID, '20210101', 15)

SELECT * FROM Sales2021_2
