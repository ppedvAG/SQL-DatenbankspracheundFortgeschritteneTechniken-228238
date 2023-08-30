/*
Datacompression: Verringert Datenvolumen (somit auch Reads), aber muss bei Aufruf dekomrpimiert werden
Aber: Hält sich i.d.R. die Waage: weniger Reads bessere Perfomance, decompression schlechtere Performance

Page & Row Compression; Page Compression beinhaltet auch Row Compression
Komprimierungspotential prüfen über system Procedure sp_estimate_data_compression_savings
*/

dbcc showcontig('Pages')

EXEC sp_estimate_data_compression_savings dbo, Bestellungen1, NULL, NULL, ROW
EXEC sp_estimate_data_compression_savings dbo, Bestellungen1, NULL, NULL, PAGE

ALTER TABLE Pages
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = ROW)

SELECT * FROM Pages

INSERT INTO Pages
SELECT 'abc                                                           xyz'
GO 100

ALTER TABLE Pages
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE)

--Empfehlung: Grundsätzlich Page-Compression verwenden

--Page Aufbau/Fragmentierung (siehe Whiteboard)