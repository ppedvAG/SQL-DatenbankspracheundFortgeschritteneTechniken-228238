USE AdventureWorks 
GO

-- Schema Collection anlegen
CREATE XML SCHEMA COLLECTION ItemsSchemaCollection
AS
N'<?xml version="1.0"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            targetNamespace="urn:Items"
            elementFormDefault="qualified">
  <xsd:element name="Items">
    <xsd:complexType>
      <xsd:choice maxOccurs="unbounded">
        <xsd:element name="Item">
          <xsd:complexType>
            <xsd:attribute name="ProductID" form="unqualified" type="xsd:string" />
            <xsd:attribute name="Quantity" form="unqualified" type="xsd:string" />
          </xsd:complexType>
        </xsd:element>
      </xsd:choice>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>'
GO

-- Tabelle anlegen
CREATE TABLE Orders
(
	OrderID int,
	OrderItems xml (ItemsSchemaCollection)
)
GO

-- Datensatz einfügen
INSERT INTO Orders 
VALUES 
(
	1, 
	'<?xml version="1.0" ?>
	<Items xmlns="urn:Items">
		<Item ProductID="1" Quantity="10"/>
	</Items>'
)
GO

-- Datensatz ausgeben
SELECT	* FROM Orders
GO

-- Tabelle enfernen
DROP TABLE Orders
GO

-- Schema Collection enfernen
DROP XML SCHEMA COLLECTION ItemsSchemaCollection
GO
