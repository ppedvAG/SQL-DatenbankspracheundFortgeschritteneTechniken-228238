--Transactions können mit sog. Checkpoints angelegt werden; es können einzelne Checkpoints gerollbacked werden
SELECT @@TRANCOUNT
BEGIN TRAN

SAVE TRANSACTION CheckpointName1
UPDATE Customers
SET City = 'München'
WHERE CustomerID = 'ALFKI'

SAVE TRANSACTION CheckpointName2
UPDATE Customers
SET City = 'Frankfurt'
WHERE CustomerID = 'ALFKI'

SAVE TRANSACTION CheckpointName3
UPDATE Customers
SET City = 'Hamburg'
WHERE CustomerID = 'ALFKI'

ROLLBACK TRANSACTION CheckPointName3

SELECT * FROM Customers
WHERE CustomerID = 'ALFKI'

COMMIT

--Rollback to Checkpoint macht einen Rollback, aber beendet die Transaktion dabei NICHT


