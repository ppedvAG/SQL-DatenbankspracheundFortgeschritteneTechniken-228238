/*
Graph Databases/Tables

SQL Server unterst�tzt Graph Tables; sogar innerhalb der selben DB wie relationale Tables

Bestehen aus Nodes (Tabellen) & Edges (Beziehungen)
*/

--Nodes erstellen:
CREATE TABLE Kunden (
ID int identity PRIMARY KEY,
Nachname varchar(50),
Vorname varchar(50),
Ort_ID int)
as Node

CREATE TABLE Restaurants (
Rest_ID int identity PRIMARY KEY,
RestName varchar(50),
Ort_ID int )
as NODE

CREATE TABLE Orte (
Ort_ID int identity PRIMARY KEY,
Ortsname varchar(50),
Koordinaten geography,
Koordinaten2 AS Koordinaten.STAsText() )
AS NODE

--Edges erstellen:
CREATE TABLE WohnenIn
AS EDGE 
CREATE TABLE AngesiedeltIn
AS EDGE 

--Nodes bef�llen:
INSERT INTO Kunden
VALUES 
('M�ller', 'Peter', 1),
('Meier', 'Renate', 2)

INSERT INTO Restaurants 
VALUES
('Subway', 1),
('Mces', 2),
('D�ner', 1)

INSERT INTO Orte
VALUES
('Burghausen', 'POINT(12.8310753 48.1725613)')

INSERT INTO Orte
VALUES
('M�nchen', 'POINT(11.5819806 48.1351253)')

SELECT * FROM Orte
SELECT * FROM Restaurants
SELECT * FROM Kunden

--Edges bef�llen:

INSERT INTO WohnenIn
VALUES 
(
(SELECT $node_id FROM Kunden WHERE ID = 1), (SELECT $node_id FROM Orte WHERE Ort_ID = 1)
)
INSERT INTO AngesiedeltIn
VALUES 
(
(SELECT $node_id FROM Restaurants WHERE Rest_ID = 1), (SELECT $node_id FROM Orte WHERE Ort_ID = 1)
),
(
(SELECT $node_id FROM Restaurants WHERE Rest_ID = 3), (SELECT $node_id FROM Orte WHERE Ort_ID = 1)
)


SELECT * FROM AngesiedeltIn
SELECT * FROM WohnenIn

--Abfrage Syntax mit WHERE MATCH:
SELECT Nachname, Vorname, Ortsname, RestName FROM Kunden, Orte, Restaurants, WohnenIn, AngesiedeltIn
WHERE MATCH (Kunden-(WohnenIn)->Orte<-(AngesiedeltIn)-Restaurants)

--SHORTEST PATH Funktion


SELECT Koordinaten.STDISTANCE((SELECT Koordinaten FROM Orte WHERE Ort_ID = 2)) FROM Orte
WHERE ort_ID = 1


/*
2 Datentypen f�r Geodaten:

geometry 
geography
*/