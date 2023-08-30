/*

Guten Morgen! :-)

Start 09:00 Uhr
Ende ca. 16.30 Uhr

Mittag ca. 12:00 Uhr

Vor-Nachmittags 15 min Kaffeepause



Agenda:

Tag 1:
- Database Design Basics
- Indexes
(- Columnstore Index)
- Stored Procedures
Vor/Nachteile; Parameter Sniffing, Statistics, Plancache
- "BadQueries"
- Locking/Blocking/Deadlocks

Tag 2:
- Query Store
- sp_Blitz
- Transactions 101
- Error Handling: TRY/CATCH, RAISERROR, THROW
- Views (partitionierte/updateable Views)
- Parallelism
- Subqueries & #Tables
- Programmsteuerung mit WHILE, IF, BREAK, CONTINUE 


Tag 3:
- Partitionierung, Data Compression
- Trigger 101, Database & Tables
- INTERSECT/EXCEPT
- SP 2.0 OUTPUT, RETURN, Dynamic Sql
- Graph Tables: n:m Beziehungen usw. + Geography + Methoden
- WAITFOR

- (Windowfunctions/Ranking Functions) (LAG)
- (CTEs recursive)
- (Semantiksuche/Volltextsuche)
- (MERGE)

Tuning Step by Step:
sp_Blitz
Abfrageplan grob prüfen (v.a Actual vs. Estimated Rows) + (Seeks vs. Scans)
Parallelism? Wenn an, mal ohne prüfen (oder weniger MAXDOP); Wenn nicht an, Parallelism forcen
Lookups? Lösbar über neuen NCIX?
Indexes checken --> neue Indizes sinnvoll?
Neue Spalten in bestehenden Index aufnehmen? Je kleiner/je ähnlicher desto "ungefährlicher"

Abwägen, weiteres Tuning sinnvoll?

Fragmentierung bestehender Indexes prüfen --> evtl. Reorganize oder sogar rebuild
Statistics updaten? Sample Size erhöhen bzw. Fullscan forcen

Query selber prüfen:
Subqueries eher vermeiden wenn möglich
#Tables einbauen

Empfehlung: Brent Ozar (Lets fix this Query)

Mailadresse Nico:

nicolass@ppedv.de


*/
