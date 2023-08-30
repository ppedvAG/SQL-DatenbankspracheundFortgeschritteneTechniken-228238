/*
--VALUE IST dazu gedacht einen Wert zurückzugeben

xml.value('(Pfad)[1]','Datentyp') --> Ausgabe eines Wertes genau

--Query dient dazu einen Teil eines XML Dokuments zurückzugeben
--also etwa ein Element (<element>.. </element>

xml.query('Pfad')

xml.query('data(/Pfad)') --kann aber auch Daten zurückgeben
*/



use Northwind
go

--DDL Trigger erzeugen eine Message in Form eines XML Dokuemtens
--möchte man diese Nachricht abfangen, dann:
select EVENTDATA()


--BSP:
create trigger ddlxml
on database
for create_view
as
begin
	SELECT EVENTDATA() --komplette Ausgabe der Nachricht
	--Arbeiten mit XML variable möglich
	declare @ausgabe as nvarchar(1000)
	declare @xml as xml
	set @xml = EVENTDATA()
	set @ausgabe = convert(nvarchar(1000), @xml.value('(/EVENT_INSTANCE/SPID)[1]', 'float'))
	select @ausgabe
	
	--(/EVENT_INSTANCE/SPID)[1].. XML ist hierarchisch.. ähnlich DOS Verzeichnisaufruf
	------daher: SPID liegt unter EVENT_INSTANCE  
	------[1] ist lediglich der erste Treffer in <SPID>.. gäbe es mehrere kannst du 
	-----mit 1 bis n die Inhalte per Zähler ausgeben.. 
	-----es beginnt immer bei 1

	--query holt immer Element raus
	select convert(nvarchar(1000), @xml.query('EVENT_INSTANCE/SPID'))
	--<SPID>56</SPID>

	select convert(nvarchar(1000), @xml.query('data(//CommandText)'))
	--mit data() kann man aber auch aus der query Abfrage Werte rausholen
	--create view v_xmlgugg&#x0D; as&#x0D; select * from customers

	
	select convert(nvarchar(1000), @xml.query('data(/EVENT_INSTANCE/*)'))
	--auch wildcard * für alle Elemente möglich die genau eine 
	--Etage unter EVENT_INSTANCE sind

END
GO

drop view if exists v_xmlgugg
go
create view v_xmlgugg
as
select * from customers


--Daten als XML ausgeben
SELECT Companyname, customerid, country FROM customers FOR XML AUTO,ROOT('ROOT'), Elements



-- XML Beispiel.. 
--tabelle zum spielen
create table Artist
	 (ArtistID int primary key not null,
	 ArtistName varchar(38))
go
 

 create table Album(AlbumID int primary key not null,
ArtistID int not null,
AlbumName varchar(100) not null,
YearReleased smallint not null)
go

insert into Artist values(1,'Pink Floyd')
insert into Artist values(2,'Incubus')
insert into Artist values(3,'Prince')
insert into Album values(1,1,'Wish You Were Here',1975)
insert into Album values(2,1,'The Wall',1979)
insert into Album values(3,3,'Purple Rain',1984)
insert into Album values(4,3,'Lotusflow3r',2009)
insert into Album values(5,3,'1999',1982)
insert into Album values(6,2,'Morning View',2001)
insert into Album values(7,2,'Light Grenades',2006)




create proc prMusicCollectionXML
as
declare @XmlOutput xml 
set @XmlOutput = (select ArtistName,AlbumName,YearReleased 
	from Album join Artist on Album.ArtistID = Artist.ArtistID
	--dieser Teil generiert ein wohlgeformtes XML Dokument
	--mit Wurzelknoten Musiccollection
	--wellformed muss ein XML sein, damit es gülitg ist (valid)
	FOR XML AUTO, ROOT('MusicCollection'), ELEMENTS)
select @XmlOutput
go

exec prMusicCollectionXML

select * from Customers

-- .value.. gibt einen Wert genau aus.. kein XML Element oder Attribut
declare @x xml
--Einlesen des XML Dokuments mit root für valid
set @x =
		(select customerid as [@CustomerID],
		CompanyName,
		ContactName,
		ContactTitle,
		[Address],
		City
		from customers
		for xml path ('Customer'), root)


--ausgabe eines Wertes..den 2ten Customer
select @x.value('(/root/Customer/@CustomerID)[2]', 'char(100)')

--natürlcih kann man auch künstlich XML erzeugen
DECLARE @myDoc xml
DECLARE @ProdID int

--aber wer will das schon.. ;-)
SET @myDoc = '<Root>
<ProductDescription ProductID="1" ProductName="Road Bike">
<Features>
  <Warranty>1 year parts and labor</Warranty>
  <Maintenance>3 year parts and labor extended maintenance is available</Maintenance>
</Features>
</ProductDescription>
</Root>'

SET @ProdID =  @myDoc.value('(/Root/ProductDescription/@ProductID)[1]', 'int' )
SELECT @ProdID


-- .query
declare @x xml

set @x =
(select customerid as [@CustomerID],
CompanyName as [CusInfo/Companyname],
ContactName as [CusInfo/ContactName],
ContactTitle as [CusInfo/ContactTitle],
[Address],
City
from customers
for xml path ('Customer'), root)

select @x.query('root/Customer/CusInfo')


declare @myDoc xml
set @myDoc = '<Root>
<ProductDescription ProductID="1" ProductName="Road Bike">
<Features>
  <Warranty>1 year parts and labor</Warranty>
  <Maintenance>3 year parts and labor extended maintenance is available</Maintenance>
</Features>
</ProductDescription>
</Root>'
SELECT @myDoc.query('/Root/ProductDescription/Features')












