DECLARE @cars xml
 
SELECT @cars = C
FROM OPENROWSET (BULK 'D:\Cars.xml', SINGLE_BLOB) AS Cars(C)
    
SELECT @cars
    
DECLARE @hdoc int
    
EXEC sp_xml_preparedocument @hdoc OUTPUT, @cars
SELECT *
FROM OPENXML (@hdoc, '/Cars/Car/CarInfo' , 1)
WITH(
    Name VARCHAR(100),
    Make VARCHAR(100)
    )
    
    
EXEC sp_xml_removedocument @hdoc
-------------------------------------------------------------------
DECLARE @cars xml
 
SELECT @cars = C
FROM OPENROWSET (BULK 'D:\Cars.xml', SINGLE_BLOB) AS Cars(C)
    
SELECT @cars
    
DECLARE @hdoc int
    
EXEC sp_xml_preparedocument @hdoc OUTPUT, @cars
SELECT *
FROM OPENXML (@hdoc, '/Cars/Car' , 2)
WITH(
    CarInfo INT,
    Price INT,
    Type VARCHAR(100)
    )
    
    
EXEC sp_xml_removedocument @hdoc