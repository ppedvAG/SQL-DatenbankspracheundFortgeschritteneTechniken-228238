USE Northwind
GO

/*
Stored Procedures super, weil QueryPlan wiederverwendbar ist! (EINER der Gründe warum SP nützlich)
Semantik der Abfrage immer gleich, daher auch immer der selbe Query Plan
Procedures compilen ihren Query Plan beim ersten AUFRUF (EXEC) der Prozedur
--> kann aber auch Nachteile haben
*/

--Wenn keine SP, dann sog. ADHOC Queries ("selbst geschrieben"): Wenn sich semantisch irgendetwas ändert --> neuer Plan
SelEcT						*
	   FroM


	CuSTOMERS

--Beispieltabelle:
CREATE TABLE Werte (
ID int identity PRIMARY KEY,
Werte varchar(10) )

CREATE NONCLUSTERED INDEX NCIX_Werte ON Werte (Werte)

INSERT INTO Werte
VALUES ('A')
GO 10

INSERT INTO Werte
VALUES ('B')
GO 500

INSERT INTO Werte
VALUES ('C')
GO 1000

SELECT * FROM Werte

--Procedure für Werte:

CREATE PROCEDURE spWerte @Werte varchar(10)
AS
SELECT * FROM Werte
WHERE Werte = @Werte

--Erster Aufruf der SP --> Plan wird compiled:
EXEC spWerte 'A'

--Zweiter Aufruf der SP:
EXEC spWerte 'C'

--(QueryPlan) Erwartete Zeilen viel zu wenig als tatsächlich, weil Plan für Wert 'A' optimiert wurde...

DROP PROCEDURE spWerte
CREATE PROCEDURE spWerte @Werte varchar(10)
AS
SELECT * FROM Werte
WHERE Werte = @Werte

--Erster Aufruf der SP --> Plan wird compiled:
EXEC spWerte 'C'

--Zweiter Aufruf der SP:
EXEC spWerte 'A'

--(QueryPlan) Selbes Problem nur andersrum; Erwartete Zeilen viel mehr als tatsächlich...

/*
Warum ist das ein Problem?
--> Ressourcenverteilung des SQL Servers 

- Weniger Zeilen als erwartet:
Mehr bereitgestellte Ressourcen als nötig --> andere Abfragen bekommen u.U. nicht mehr genug, da nichts mehr vorhanden
--> Server gerät ins Schleudern da immer mehr Abfragen "hängen" (Memory Starvation)

- Mehr Zeilen als erwartet:
Zu wenig bereitgestellte Ressourcen als nötig --> Abfrage läuft sehr langsam da wenig "Manpower für viel Arbeit"
--> Performance leidet stark --> schlimmstenfalls sogar Memoryleak (Spill to disc)


"Lösungsmöglichkeiten":

dbcc freeproccache
WITH RECOMPILE
(OPTIMIZE FOR)
*/

--löscht gesamten Plancache des Servers:
dbcc freeproccache 
--Nur im Notfall!!! Nicht zu empfehlen!


--Abfrage Hint WITH RECOMPILE erzwingt neuen Abfrageplan; Kann an verschiedenen Stellen stehen:

--im Aufruf der SP:
EXEC spWerte 'B' WITH RECOMPILE 

DROP INDEX NCIX_Werte ON Werte
CREATE NONCLUSTERED INDEX NCIX_Werte ON Werte (Werte)

EXEC spWerte 'A' WITH RECOMPILE
EXEC spWerte 'B' WITH RECOMPILE
EXEC spWerte 'C' WITH RECOMPILE

--(Der erster Aufruf ohne Recompile generiert neuen, wiederverwendbaren Plan)


--Im CREATE PROCEDURE Header:
--(bitte so nicht, da nie ein Plan gecached wird --> "unsichtbar" fürs Monitoring)
CREATE PROCEDURE spWerte2 @Werte varchar(10) WITH RECOMPILE
AS
SELECT * FROM Werte
WHERE Werte = @Werte

--Im Code der Procedure:
--(lieber so im Code, da wenigstens ein letzter verwendeter Plan gechached wird)
CREATE PROCEDURE spWerte3 @Werte varchar(10)
AS
SELECT * FROM Werte 
WHERE Werte = @Werte
OPTION (RECOMPILE)

EXEC spWerte3 'a'
EXEC spWerte3 'B'
EXEC spWerte3 'C'


--Systemviews für Query Stats & QueryPlans:
SELECT * FROM sys.dm_resource_governor_resource_pools
SELECT * FROM sys.dm_exec_query_plan()--Planhandle = Plan-ID als Parameter nötig
SELECT * FROM sys.dm_exec_sql_text()--Planhandle = Plan-ID als Parameter nötig
SELECT * FROM sys.dm_exec_cached_plans
SELECT * FROM sys.dm_exec_query_stats

SELECT
[qs].[last_execution_time],
[qs].[execution_count],
[qs].[total_logical_reads]/[qs].[execution_count] [AvgLogicalReads],
[qs].[max_logical_reads],
[qs].[plan_handle],
[p].[query_plan]
FROM sys.dm_exec_query_stats [qs]
CROSS APPLY sys.dm_exec_sql_text([qs].sql_handle) [t]
CROSS APPLY sys.dm_exec_query_plan([qs].[plan_handle]) [p]
GO
