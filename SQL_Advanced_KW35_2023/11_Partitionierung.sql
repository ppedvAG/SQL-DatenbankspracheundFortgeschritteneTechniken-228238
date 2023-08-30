/*
Idee: Großen Sales Table in Partitionen nach Geschäftsjahren splitten

1. Filegroups & Files erstellen

2. Partitionfunction erstellen

3. Partitionsscheme erstellen basierend auf der Function

4. tatsächliche Partitionierung durchführen

*/

SELECT MIN(Datum), MAX(Datum) FROM Sales

--FILEGROUP erstellen:

ALTER DATABASE Northwind
ADD FILEGROUP Filegroupname

--Files erstellen:

ALTER DATABASE Northwind
ADD FILE Filename (
	NAME = Filename,
	FILENAME = 'C:\...'
	SIZE = 100
	AUTOGRWOTH = 64 )
	TO FILEGROUP Filegroupname

--2. Partitionsfunktion erstellen

CREATE PARTITION FUNCTION pfSalesNachJahr (date)
AS
RANGE LEFT FOR VALUES ('20191231', '20201231', '20211231', '20221231', '20231231')
 

--3. Partitionsschema/Scheme erstellen

CREATE PARTITION SCHEME psSalesNachJahr
AS PARTITION pfSalesNachJahr
TO ('Sales2019', 'Sales2020', 'Sales2021', 'Sales2022', 'Sales2023', 'PRIMARY')
--TO FILEGROUPS (Nicht Files); Immer eine "Notfall" Filegroup angeben (bspw. PRIMARY)

--4. Partitionierung durchführen

--Für neuen Table:
CREATE TABLE irgendwas (
ID int identity,
Datum date)
ON psSalesNachJahr (Datum)

--Für vorhandenen Table, CIX neu anlegen mit Partitionsscheme:
ALTER TABLE Sales
DROP CONSTRAINT [PK__Sales__3214EC27D99BA88B]

CREATE CLUSTERED INDEX CIX_SalesByYear ON Sales (ID) ON psSalesNachJahr (Datum)


--Partitionen prüfen:

SELECT $PARTITION.pfSalesNachJahr(Datum),* FROM Sales
WHERE Datum BETWEEN '20211231' AND '20220101'


SELECT DISTINCT o.name as table_name, rv.value as partition_range, fg.name as file_groupName, p.partition_number, p.rows as number_of_rows
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id
INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id 
LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
WHERE o.object_id = OBJECT_ID('Sales');


INSERT INTO Sales
VALUES ('20240101', 'ABC', 50)

SELECT ID, Datum FROM Sales
WHERE Datum BETWEEN '20210101' AND '20211231'

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('Sales'), NULL, NULL, 'detailed')