/*
Parallelism = mehrere CPU Cores arbeiten gleichzeitig (parallel) an einer Abfrage
Kann u.U. Performance verbessern

MAXDOP - Maximum Degree Of Parallelism
MAXDOP Setting in DB/Server gibt an, wieviele Cores maximal verwendet werden dürfen
(0 = Alle die verfügbar sind)
Cost Threshold definiert Kostenschwelle (= "SQL Dollars"), ab wann Parallelism verwendet werden darf
Default Setting ist 5 - in realen Umgebungen relativ niedrig!
*/


SELECT SUM(Bestellwert), ProduktID FROM Bestellungen1
GROUP BY ProduktID

--Query Hint um MAXDOP Einstellungen des Servers zu überschreiben (Cores reduzieren):

SELECT SUM(Bestellwert), ProduktID FROM Bestellungen1 --WITH (MAXDOP = 4)
GROUP BY ProduktID
OPTION (MAXDOP 4)

--Query Plan mit Parallelism "forcen" (auch wenn Threshold nicht erreicht ist):

SELECT OrderID, SUM(Freight) FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY OrderID
OPTION (USE HINT ('ENABLE_PARALLEL_PLAN_PREFERENCE'))


