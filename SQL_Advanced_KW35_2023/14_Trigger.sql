/*
2 Arten von Triggern: 
Database Trigger (DDL Statements)
Table Trigger (DML Statements)

Pr�fen (permanent) eine/mehrere Triggerconditions, und f�hren wenn ausgel�st irgendein hinterlegtes Statement aus

*/

ALTER TABLE Customers
ADD LastModified datetime
GO

CREATE TRIGGER trgLastModified ON Customers
AFTER UPDATE --FOR oder INSTEAD OF
AS
DECLARE @CustomerID char(5)
SET @CustomerID = (SELECT CustomerID FROM inserted)

UPDATE Customers
SET LastModified = getdate()
WHERE CustomerID = @CustomerID

/*******/

UPDATE Customers
SET ContactName = 'Peter'
WHERE CustomerID = 'ALFKI'

SELECT * FROM Customers

--Trigger "macht mit", wird aber auch gerollbacked wenn n�tig
BEGIN TRANSACTION
UPDATE Customers
SET ContactName = 'Hans'
WHERE CustomerID = 'ALFKI'
ROLLBACK


--Mehr als eine Zeile:
UPDATE Customers
SET ContactName = 'Hans'
WHERE Country = 'Germany'

--Trigger wirft Fehlermeldung

ALTER TRIGGER trgLastModified ON Customers
AFTER UPDATE --FOR oder INSTEAD OF
AS
UPDATE Customers
SET LastModified = getdate()
WHERE CustomerID IN (SELECT CustomerID FROM inserted)

UPDATE Customers
SET ContactName = 'Hans'
WHERE Country = 'Germany'

SELECT * FROM Customers



--Unterschiede in inserted und deleted
ALTER TRIGGER trgLastModified ON Customers
AFTER UPDATE --FOR oder INSTEAD OF
AS
UPDATE Customers
SET LastModified = getdate()
WHERE CustomerID IN (SELECT CustomerID FROM inserted)
UPDATE Customers
SET Aenderung = (SELECT ContactName FROM deleted)
WHERE CustomerID IN (SELECT CustomerID FROM inserted)

UPDATE Customers
SET ContactName = 'Michaela'
WHERE CustomerID = 'ALFKI'

SELECT * FROM Customers

SELECT * FROM sys.triggers --Parent_ID = Table ID des Triggers
SELECT OBJECT_ID('Customers')
SELECT * FROM INFORMATION_SCHEMA.ROUTINES

--Trigger ausschalten:

ALTER TABLE Customers
DISABLE TRIGGER [trgLastModified]

ALTER TABLE Customers
ENABLE TRIGGER [trgLastModified]



--Database Trigger: Nur mit FOR und f�r DDL Statements; n�tzlich f�r Infos �ber �nderung, Logging etc.

CREATE TRIGGER trgDDLTest ON DATABASE
FOR ALTER_TABLE
AS
SELECT 'Lass das!'

ALTER TABLE Customers 
ADD NochmalNeu int

SELECT * FROM Customers

--INTERSECT: gibt nur Ergebnisse zur�ck, die in beiden Teilabfragen vorkommen
SELECT * FROM Customers
INTERSECT
SELECT * FROM Customers
WHERE Country = 'Germany'

--EXCEPT: Gibt Ergebnisse aus Abfrage 1 zur�ck, die NICHT in Abfrage 2 ebenfalls vorkommen
SELECT * FROM Customers
EXCEPT
SELECT * FROM Customers
WHERE Country = 'Germany'

