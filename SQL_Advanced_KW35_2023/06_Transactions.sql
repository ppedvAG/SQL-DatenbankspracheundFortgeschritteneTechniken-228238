/*
Errorhandling & Umgang mit Transactions:
TRY & CATCH (RAISERROR & THROW)
*/
USE Northwind
GO

--Idee: Beide Statements sollen fehlerfrei durchgef�hrt werden; Falls irgendwo ein Fehler, beides Rollback
BEGIN TRANSACTION

INSERT INTO Links
SELECT 'abc'

UPDATE Rechts
SET Werte = 'abc'
WHERE ID = 1

COMMIT --OR ROLLBACK?
--Geht so leider nicht; alles was fehlerfrei funktioniert hat wird am Ende commited...


--L�sung �ber TRY & CATCH Bl�cke
BEGIN TRANSACTION

BEGIN TRY --�ffnet Try Block

INSERT INTO Links
SELECT 'abc'

UPDATE Rechts
SET Werte = 'abc'
WHERE ID = 1
--(COMMIT auch am Ende des Try Blocks m�glich)
END TRY --Schlie�t Try Block

BEGIN CATCH --�ffnet Catch Block
ROLLBACK
END CATCH --Schlie�t Catch Block
COMMIT

/*
TRY & CATCH Bl�cke immer als Paar - treten nur gemeinsam auf
Anweisungen in den TRY Block; Wenn kein Fehler auftritt:
alles gut und der zugeh�rige CATCH Block wird ignoriert

Sollte ein Fehler im TRY auftreten, wird die Programmsteuerung sofort an den zugeh�rigen CATCH Block �bertragen
Hier k�nnen wir dann bspw. ein ROLLBACK einbauen
*/


/*
Custom Fehlermeldungen generieren oder generell Fehlermeldung zum Skriptstop ausgeben
�ber THROW & RAISERROR
Beide sehr �hnlich, RAISERROR allerdings etwas flexibler da es nicht immer das Skript stoppt 
(Variable severity)
*/

BEGIN TRANSACTION
BEGIN TRY
INSERT INTO Links
SELECT 'abc'
UPDATE Rechts
SET Werte = 'abc'
WHERE ID = 1
--COMMIT
END TRY
BEGIN CATCH
RAISERROR(50001, 10, 1) --Custom Error aus dem Katalog
ROLLBACK
END CATCH
COMMIT


--Gibt (Custom-)Fehlermeldung aus dem Fehlerkatalog aus
RAISERROR(50001, 20, 1) WITH LOG --ErrorID, Severity, Ebene

--Errorkatalog aufrufen:
SELECT * FROM sys.messages WHERE message_id = 1205

--Eigene Fehlermeldung zum Katalog hinzuf�gen:
EXEC sp_addmessage 50002, 16, 'Severity 16!', 'us_english'

/*
Severity = Schweregrad des Fehlers
1-10 : "nicht schwerwiegender Fehler"; Skript wird nicht gestoppt
11-18: "Critical Error"; Skript wird gestoppt
19-25: "Critical Errors die geloggt werden sollen"; (WITH LOG)
*/

--THROW (ohne Parameter) funktioniert nur innerhalb eines CATCH Blocks & hat IMMER Severity 16:

--Problem in diesem Beispiel: THROW beendet das Skript, ROLLBACK wird nicht mehr ausgef�hrt!
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO Links
SELECT 'abc'
UPDATE Rechts
SET Werte = 1/0
WHERE ID = 1
COMMIT
END TRY
BEGIN CATCH
THROW --stoppt immer das Skript!
ROLLBACK
END CATCH

SELECT * FROM Rechts
SELECT * FROM Links

--Eigene Fehlermeldung mit THROW ausgeben:
SELECT * FROM Customers;
THROW 50002, 'test', 1;


--Tats�chlichen Fehler der entstanden ist ausgeben mit RAISERROR:

DECLARE @Msg int, @Sev int, @State int --Variablen definieren um Error integer zu speichern

BEGIN TRANSACTION
BEGIN TRY
INSERT INTO Links
SELECT 'abc'
UPDATE Rechts
SET Werte = 1/0
WHERE ID = 1
COMMIT
END TRY
BEGIN CATCH
SET @Msg = ERROR_MESSAGE() --Variablen mit dem entstandenen Fehler "bef�llen"
SET @Sev = ERROR_SEVERITY()
SET @State = ERROR_STATE()
RAISERROR(@Msg, @Sev, @State) --RAISERROR mit den Werten der Variablen ausf�hren
ROLLBACK
END CATCH

SELECT @@TRANCOUNT

SELECT * FROM Rechts
SELECT * FROM Links