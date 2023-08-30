use tempdb;
GO

create table tblTest1
 (
	ID int constraint pkid1  primary key nonclustered,
	Wert varchar(20), 
	Zahl int	
);
GO


create table tblTest2
 (
	ID int constraint pkid2  primary key nonclustered,
	Wert varchar(20), 
	Zahl int	
);
GO

Insert into tblTest1 values(1,'abc',1);
Insert into tblTest1 values(2,'abc',2);
Insert into tblTest1 values(3,'abc',3);
Insert into tblTest1 values(5,'abc',5);

Insert into tblTest2 values(1,'abc',1);
Insert into tblTest2 values(2,'xyz',2);
Insert into tblTest2 values(3,'abc',4);
Insert into tblTest2 values(4,'uiui',4);
GO


---###########################################################################################
--MERGE:		..Datensätze
--MACTHED		.. die in beiden vorhanden sind
--NOT MATCHED BY TARGET .. In Quell- aber nicht in Zieltabelle vorhanden
--NOT MATCHED BY SOURCE .. In Ziel- aber nicht in Quelltabelle vorhanden

--  !! Änderungen werden aber nur in der Zieltabelle vorgenommen  !!
--  ==> Tabellen können also nicht vollständig synchronsiert werden
---###########################################################################################


-- mögliche SYNTAX
 --when MACTHED UPDATE , DELETE
 --when NOT MACTHED BY TARGET INSERT
 --when NOT MACTHED BY SOURCE UPDATE, DELETE


 --DEMO

 MERGE tbltest2 as T2 USING tblTEST1 as T1 ON (t1.id = t2.id)
 WHEN MATCHED then 
				update SET T2.wert = T1.WERT, T2.Zahl=T1.Zahl; --   <-- SEMIKOLON!!

 select * from tbltest2


MERGE tblTEST2 as T2 USING tblTest1 as T1 On (t1.id=t2.id)
WHEN
	MATCHED THEN DELETE
WHEN
	NOT MATCHED BY SOURCE THEN Update set Wert ='k.a.'
WHEN
	NOT MATCHED BY TARGET THEN INSERT values(id, wert, zahl);


--GEFILTERT

MERGE tblTEST2 as T2 USING tblTEst1 as T1
on 
	(t1.id =t2.Id AND T1.Wert='abc')
WHEN 
	MATCHED THEN UPDATE SET Wert ='juhu!';

select * from tbltest2

--oder auch so:
MERGE tblTEST2 as T2 USING tblTEst1 as T1
on 
	(t1.id =t2.Id)
WHEN 
	MATCHED AND t1.Wert='abc' THEN UPDATE SET Wert ='ohje!';

	select * from tbltest2


--OUTPUT: Ergebnis des Merge beobachten

Merge tblTest2 as T2 using tblTest1 T1 ON (t1.id=t2.id)
WHEN MATCHED THEN DELETE
WHEN NOT MATCHED  BY SOURCE THEN DELETE
OUTPUT $action, inserted.*, deleted.*;