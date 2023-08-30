--Syntax von Pivot
--SELECT <nicht pivotierte Spalte>,
--[erste pivotierte Spalte] AS <Spaltenname>,
--[zweite pivotierte Spalte] AS <Spaltenname>,
--...
--[letzte pivotierte Spalte] AS <Spaltenname>
--FROM
--(<SELECT-Abfrage, die die Daten erzeugt>)
--AS <Alias für die Quellabfrage>
--PIVOT
--(
--<Aggregationsfunktion>(<Spalte, die aggregiert wird>)
--FOR
--[<Spalte, die die Werte enthält, die zu Spaltenheadern werden>]
--IN ( [erste pivotierte Spalte], [zweite pivotierte Spalte],
--... [letzte pivotierte Spalte])
--) AS <Alias für die PivotTable>
--<optionale ORDER BY-Klausel>;
select * from Tabelle
Pivot (aggregat(Quellspalte)
for Pivot-Spalte in Spaltenliste
as Alias

-- Erstellung einer Tabelle 
create table Sales (State Char(2), SalesAmt decimal (18,2))
select * from sales

insert into sales values ('ND', 10000),
('SD', 30000), ('TN', 2500.50), ('OR', 5500.50),
('VA', 6500.50), ('SD', 7000), ('ND', 8000)


select * from sales
-- Hier geben wir an welche Spalten wir Pivotieren wollen
select [ND], [SD], [TN], [OR], [VA] --also reale Werte
from (select state, salesamt from sales) pivot_tabelle
pivot
(
-- Wir wollen noch das die Summe gebildet wird
sum(salesamt)
for state in
([ND], [SD], [TN], [OR], [VA])
) as pvt

select * from sales
-- Kompatibilitätsgrad ist bei dieser Tabelle für ein Pivot (muss 90 sein) zu niedrig
-- Kompatibilitätsgrad setzt sich aus der SQL Server Version zusammen
-- SQL Server 2000 (80)
-- SQL Server 2005 (90)
-- SQL Server 2008 (100)

-- Mit dieser stored Procedure setzen wir den Kompatibilitätsgrad auf 100
exec sp_dbcmptlevel Northwind, 150

select country, count(*) from customers
group by country

select [UK], [USA], [Germany] from (select country from customers) c
pivot (count(country) for country in ( [UK], [USA], [Germany]))
 as pvt



 --UNPIVOT
 CREATE TABLE pvt (VendorID int, Emp1 int, Emp2 int,
    Emp3 int, Emp4 int, Emp5 int);
GO
INSERT INTO pvt VALUES (1,4,3,5,4,4);
INSERT INTO pvt VALUES (2,4,1,5,5,5);
INSERT INTO pvt VALUES (3,4,3,5,4,4);
INSERT INTO pvt VALUES (4,4,2,5,5,4);
INSERT INTO pvt VALUES (5,5,1,5,5,5);
GO
--Unpivot the table.
SELECT VendorID, Employee, Orders
FROM 
   (SELECT VendorID, Emp1, Emp2, Emp3, Emp4, Emp5
   FROM pvt) p
UNPIVOT
   (Orders FOR Employee IN 
      (Emp1, Emp2, Emp3, Emp4, Emp5)
)AS unpvt;
GO







 -- Hier wird eine Tabelle erstellt um ein Beispiel für das Unpivot parrat zu haben
 create table StudentMarks([Name] varchar(50),
 Subject1 Varchar(10),
 Mark1 int,
 Subject2 varchar(10),
 Mark2 int,
 Subject3 varchar(10),
 Mark3 int)
 
INSERT INTO StudentMarks([Name],Subject1,Mark1,Subject2,Mark2,Subject3,Mark3)  
VALUES('AAA','Science',98,'Maths',89,'English',76)  
INSERT INTO StudentMarks([Name],Subject1,Mark1,Subject2,Mark2,Subject3,Mark3)  
VALUES('XXX','Biology',78,'Chemistry',85,'Physics',67)  
INSERT INTO StudentMarks([Name],Subject1,Mark1,Subject2,Mark2)  
VALUES('YYY','Batany',60,'Zoology',54)  
INSERT INTO StudentMarks([Name],Subject1,Mark1,Subject2,Mark2)  
VALUES('ZZZ','Maths',67,'Physics',78) 

select * from StudentMarks

 -- Hier das unpivot das die umgekehrte Wirkung hat
select [Name], Subjectname,
case when Subject = 'Subject1' then Mark1
	when Subject = 'Subject2' then Mark2
	when Subject = 'Subject3' then Mark3
	else Null end as marks
from 
(select [Name],  Subject1, Mark1, Subject2, Mark2, Subject3, Mark3
from Studentmarks) p
Unpivot
(Subjectname for Subject in 
(Subject1, Subject2, Subject3)
) as unpvt

 

