use NORTHWND1;

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
