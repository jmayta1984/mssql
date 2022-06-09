use NORTHWND1;

-- CREATE PROCURE <sp_name>
-- @param <data_type>
-- AS
-- BEGIN
--      Query
-- END

SELECT DISTINCT City FROM Customers;
-- Equivalente en MongoDB: db.customers.distinct("City");


SELECT CompanyName FROM Customers WHERE City = 'Paris';

-- Crear un procedimiento almacenado que permita buscar los nombres de las compañías por su ciudad de origen

CREATE PROCEDURE sp_company_by_city
    @city VARCHAR(30)
AS
BEGIN
    SELECT CompanyName FROM Customers WHERE City = @city;
END;

EXECUTE sp_company_by_city 'London';

-- Crear un procedimiento almacenado que permita indicar la cantidad de órdenes realizadas por el  nombre de
-- la compañía

SELECT DISTINCT CompanyName FROM Customers;

CREATE PROCEDURE sp_orders_by_companyName
    @companyName VARCHAR(50)
AS
BEGIN
    SELECT COUNT(*)
    FROM Orders O
        JOIN Customers C on O.CustomerID = C.CustomerID
    WHERE CompanyName = @companyName;
END;

EXECUTE sp_orders_by_companyName 'Around the Horn';

-- Crear un procedimiento almacenado que permita listar los nombres de losproductos de acuerdo
-- al nombre de su categoría

SELECT DISTINCT CategoryName FROM Categories;

CREATE PROCEDURE sp_products_by_categoryName
    @categoryName VARCHAR(50)
AS
BEGIN
    SELECT ProductName
    FROM Products P
        JOIN Categories C ON P.CategoryID = C.CategoryID
    WHERE CategoryName = @categoryName;
END;

EXECUTE sp_products_by_categoryName 'Seafood';

-- Crear un procedimiento almacenado que permita listar lo nombres de los proveedores de acuerdo a un
-- determinado país
CREATE PROCEDURE sp_supplier_by_country @Country NVARCHAR(15)
AS
BEGIN
    SELECT CompanyName FROM Suppliers WHERE Country = @Country
END;

GO;

EXECUTE sp_supplier_by_country 'FRANCE';

-- Crear un procedimiento almacenado que permita mostrar la cantidad de pedidos atendidos de acuerdo a un
-- determiano embarcador

ALTER PROCEDURE sp_orders_by_shipper @CompanyName NVARCHAR(40),
                                     @Quantity INT OUTPUT
AS
BEGIN
    SELECT @Quantity = COUNT(OrderID)
    FROM Orders O
             JOIN Shippers S on S.ShipperID = O.ShipVia
    WHERE CompanyName = @CompanyName
END;
GO;

SELECT DISTINCT CompanyName
FROM Shippers;

DECLARE @Total INT
EXEC sp_orders_by_shipper 'Federal Shipping', @Total OUTPUT;
PRINT @Total;

GO;

-- Crear un procedimiento almacenado para imprimir el nombre y la cantidad en stock de cada producto

CREATE PROCEDURE sp_products
AS
BEGIN
    DECLARE @ProductName NVARCHAR(40), @UnitInStock SMALLINT

    DECLARE cursor_products CURSOR FOR SELECT ProductName, UnitsInStock FROM Products

    OPEN cursor_products;
    FETCH NEXT FROM cursor_products INTO @ProductName, @UnitInStock

    WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT 'Product: ' +@ProductName + ' - Stock: ' + LTRIM(STR(@UnitInStock))
            FETCH NEXT FROM cursor_products INTO @ProductName, @UnitInStock
        END
    CLOSE cursor_products
    DEALLOCATE cursor_products
END;

EXEC sp_products

-- Crear un procedimiento almacenado que permita ingresar un nueva categoría indicando
-- el nombre de la categoría

CREATE PROCEDURE sp_insert_category
    @CategoryName NVARCHAR(15)
AS
BEGIN
    INSERT INTO Categories (CategoryName) VALUES(@CategoryName)
END;

-- Crear un procedimiento almacenado que permita borrar un categoría indicando id

CREATE PROCEDURE sp_delete_category @CategoryID INT
AS
BEGIN
   DELETE FROM Categories WHERE CategoryID = @CategoryID
END;
GO;

EXECUTE sp_insert_category 'Sneakers'

SELECT * FROM Categories

EXEC sp_delete_category 9

SELECT * FROM Categories


-- Crear un procedimiento almacenado que calcule la cantidad de clientes de un
-- país determinado

CREATE PROCEDURE sp_customers_by_country @Country NVARCHAR(15)
AS
BEGIN
    SELECT COUNT(CustomerID)
    FROM Customers
    WHERE Country = @Country
END;
GO;

EXECUTE sp_customers_by_country 'USA'

-- Crear un procedimiento almacenado que retorne la cantidad de clientes de un
-- país determinado

CREATE PROCEDURE sp_totalCustomers_by_country @Country NVARCHAR(15),
                                         @Quantity INT OUTPUT
AS
BEGIN
    SELECT @Quantity = COUNT(CustomerID)
    FROM Customers
    WHERE Country = @Country
END;
GO;

DECLARE @Total INT
EXEC sp_totalCustomers_by_country 'USA', @Total OUTPUT
PRINT @Total

-- Crear un procedimiento almacenado que permita imprimir el inventario por cada producto
-- e imprimir el inventario en total

CREATE PROCEDURE sp_stock_per_product
AS
BEGIN

    DECLARE @ProductName NVARCHAR(40), @UnitsInStock SMALLINT, @Total INT = 0

    -- Declarar el cursor
    DECLARE products_cursor CURSOR FOR SELECT ProductName, UnitsInStock
                                       FROM Products

    -- Abrir el cursor
    OPEN products_cursor

    -- Moverme al siguiente registro
    FETCH products_cursor INTO @ProductName, @UnitsInStock

    -- Validar si la operación fetch fue exitosa
    WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT @ProductName + ' stock: ' + LTRIM(STR(@UnitsInStock))
            SET @Total += @UnitsInStock
            FETCH products_cursor INTO @ProductName, @UnitsInStock
        END
    PRINT 'Inventary total: '+ LTRIM(STR(@Total))
    -- Cerrar el cursor
    CLOSE products_cursor

    -- Liberar
    DEALLOCATE products_cursor
END;
GO;

EXEC sp_stock_per_product;
