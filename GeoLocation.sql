-- Neue Datenbank für Test (Daten) anlegen 
 CREATE DATABASE [GeoTest]; 
 GO 
 -- Und verwenden 
 USE [GeoTest]; 
 GO 
   
 -- Geography Unterricht Teil 1 
 -- Punkte von ein paar Großstädten anlegen 
 CREATE TABLE Locations 
   (ID int IDENTITY(1, 1) NOT NULL Primary Key, 
   Ctry char(2), 
   City varchar(40), 
   Coordinate geography); 
   
 INSERT INTO Locations VALUES 
   ('DE', 'Berlin',  'POINT(13.4000 51.5166)') 
   ,('DE', 'Hamburg',  'POINT(10.0000 53.5500)') 
   ,('DE', 'Köln',  'POINT( 6.9572 50.9413)') 
   ,('DE', 'Hannover',  'POINT( 9.7361 52.3744)') 
   ,('DE', 'Frankfurt (M)', 'POINT( 8.6859 50.1118)') 
   ,('DE', 'Bonn',  'POINT( 7.0998 50.7339)') 
   ,('DE', 'Düsseldorf',  'POINT( 6.7827 51.2255)') 
   ,('DE', 'München',  'POINT(11.5744 48.1397)') 
   ,('DE', 'Nürnberg',  'POINT(11.0777 49.4527)') 
   ,('DE', 'Frankfurt (O)', 'POINT(14.5500 52.3500)') 
   ,('DE', 'Dortmund',  'POINT( 7.4652 51.5138)') 
   ,('DE', 'Regensburg',  'POINT(12.0833 49.0166)') 
   ,('DE', 'Dresden',  'POINT(13.7383 51.0492)') 
   ,('DE', 'Leipzig',  'POINT(12.3747 51.3403)') 
   ,('DE', 'Halle (Saale)', 'POINT(11.9700 51.4827)') 
   ,('DE', 'Magdeburg',  'POINT(11.6166 52.1333)') 
   ,('DE', 'Cottbus',  'POINT(14.3341 51.7605)') 
   ,('DE', 'Flensburg',  'POINT( 9.4366 54.7819)') 
   ,('GB', 'London',  'POINT(-0.1183 51.5094)') 
   ,('GB', 'Greenwich',  'POINT(-0.0080 51.4812)') 
   
 GO 
 -- Heimat-Lokation festlegen; hier über die statische Methode 
 -- für WKT = Well Known Text. 
 DECLARE @Burghausen geography; 
 SET @Burghausen = geography::STGeomFromText ('POINT( 12.8310753 48.1725613)', 4326) 
   
 -- Wie weit ist es von mir aus? 
 SELECT Ctry, City 
   ,Coordinate 
   ,Coordinate.ToString()  -- Klartext über ToString() 
   ,Coordinate.STDistance(@Burghausen) / 1000 AS [Abstand KM] 
 FROM Locations 
 ORDER BY Coordinate.STDistance(@Burghausen); 
 GO 
   
 -- Abstand zwischen den Städten in km 
 SELECT LOC1.City AS Von 
   ,LOC1.Coordinate.STAsText() -- Klartext über STAsText() 
   ,LOC2.City AS Nach 
   ,LOC2.Coordinate.STAsText() 
   ,LOC1.Coordinate.STDistance(LOC2.Coordinate) / 1000 AS [Abstand KM] 
 FROM Locations AS LOC1 
   INNER JOIN Locations AS LOC2 
   ON LOC1.ID <> LOC2.ID 