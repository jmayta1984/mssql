/*
   Script de base de datos:
   https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/northwind-pubs/instnwnd%20(Azure%20SQL%20Database).sql
   Previamente debe crear la base de datos con los siguientes comandos:
   create database northwind
   use nortwind
*/

use Northwind;

/* Ejercicio 1
   Crear una función que retorne el país de procedencia del cliente con la menor cantidad de pedidos atendidos
   para un determinado año.
 */

create function f_orders_by_country(@Year int)
    returns table
        as
        return select year(OrderDate) as Year, Country, count(OrderId) as Quantity
               from customers c
                        join orders O on c.CustomerID = O.CustomerID
               where year(OrderDate) = @Year
               group by year(OrderDate), Country;
go;

create function f_min_orders_country_year(@Year int)
    returns table
        as
        return select Country
               from dbo.f_orders_by_country(@Year)
               where Quantity = (select min(Quantity) from dbo.f_orders_by_country(@Year))
go;

select *
from dbo.f_min_orders_country_year(2018)

go;
/* Ejercicio 2
   Crear una función que retorne el nombre de la categoría con la mayor cantidad de ítems de productos vendidos
   para un determinado año.
 */

create function f_items_per_category(@Year int)
    returns table
        as return select CategoryName, sum(quantity) as Total
                  from Categories C
                           join Products P on C.CategoryID = P.CategoryID
                           join [Order Details] OD on P.ProductID = OD.ProductID
                           join Orders O on OD.OrderID = O.OrderID
                  where YEAR(OrderDate) = @Year
                  group by CategoryName;
go;

create function f_max_items_year(@Year int)
    returns table
        as return
        select CategoryName
        from dbo.f_items_per_category(@Year)
        where Total = (select max(Total) from dbo.f_items_per_category(@Year));
go;

select *
from dbo.f_max_items_year(2016);
go;

/* Ejercicio 3
   Crear una función que retorne la cantidad de órdenes atendidas para un determinado año.
 */
create function f_orders_by_year(@Year int) returns int
as
begin
    declare @Total int
    select @Total = count(OrderID) from Orders where year(OrderDate) = @Year
    return @Total
end;
go;
print dbo.f_orders_by_year(2016);

/* Ejercicio 4
   Crear una función que retorne el nombre de la compañía con más órdenes realizadas para
   un determinado año.
 */

create function f_orders_per_company(@Year int)
    returns table
        as
        return
        select CompanyName, count(OrderId) as Quantity
        from Customers C
                 join Orders O on C.CustomerID = O.CustomerID
        where year(OrderDate) = @Year
        group by CompanyName;

go;

create function f_best_company_by_year(@Year int)
    returns table
        as
        return
        select CompanyName
        from dbo.f_orders_per_company(@Year)
        where Quantity = (
            select max(Quantity)
            from dbo.f_orders_per_company(@Year));

select * from dbo.f_best_company_by_year (2018)
go;

/* Ejercicio 05:
   Crear una función que retorne el nombre del shipper con mayor cantidad de pedidos atendidos
   para un determinado año.
 */

create function f_orders_by_shipper(@Year int)
    returns table
        as
        return
        select year(OrderDate) as Year, CompanyName, count(OrderId) as Quantity
        from Shippers S
                 join Orders O on S.ShipperID = O.ShipVia
        where year(OrderDate) = @Year
        group by year(OrderDate), CompanyName;
go;

create function f_best_shipper_by_year(@Year int)
    returns table
        as
        return
            (
                select CompanyName
                from dbo.f_orders_by_shipper(@Year)
                where Quantity = (
                    select max(Quantity)
                    from dbo.f_orders_by_shipper(@Year))
            );
go;
select *
from dbo.f_best_shipper_by_year(2018)
go;
/*
    Ejercicio 06:
    Crear una función que retorne el nombre de la compañía proveedora con mayor cantidad de pedidos
    atendidos para un determinado año.
 */

create function f_orders_by_supplier(@Year int)
    returns table
        as
        return
            (
                select CompanyName, count(O.OrderId) as Quantity
                from Suppliers S
                         join Products P on S.SupplierID = P.SupplierID
                         join [Order Details] [O D] on P.ProductID = [O D].ProductID
                         join Orders O on [O D].OrderID = O.OrderID
                group by CompanyName
            );
go;

create function f_best_supplier_by_year(@Year int)
    returns table
        as return
            (
                select CompanyName
                from dbo.f_orders_by_supplier(@Year)
                where Quantity = (select max(Quantity) from dbo.f_orders_by_supplier(@Year))
            );

select *
from dbo.f_best_supplier_by_year(2017)


/*  Ejercicio 07:
    Crear una función que retorne el nombre del cliente con mayor cantidad de pedidos realizados para un
    determinado año y de un determinado origen país.
 */


create function f_orders_by_customer_year_country(@Year int, @Country nvarchar(40))
    returns table
        as return
            (
                select CompanyName, count(OrderId) as Quantity
                from Customers C
                         join Orders O on C.CustomerID = O.CustomerID
                where year(OrderDate) = @year
                  and Country = @Country
                group by CompanyName
            );

create function f_best_customer_year_country(@Year int, @Country nvarchar(40))
    returns table
        as return
            (
                select CompanyName
                from dbo.f_orders_by_customer_year_country(@Year, @Country)
                where Quantity = (select max(Quantity) from dbo.f_orders_by_customer_year_country(@Year, @Country))
            );

select *
from dbo.f_best_customer_year_country(2018, 'Italy')

/*  Ejercicio 08:
    Crear un procedimiento o función que liste la relación de productos para una determinada categoría.
 */

create procedure sp_products_by_category @CategoryName nvarchar(15)
as
begin
    select ProductName
    from Products P
             join Categories C on C.CategoryID = P.CategoryID
    where CategoryName = @CategoryName
end;
go;
execute sp_products_by_category 'Beverages';

/* Ejercicio 09:
   Crear un procedimiente o función que muestre los productos que comercializa un determinado proveedor.
 */

create procedure sp_products_by_supplier @CompanyName nvarchar(40) as
begin
    select ProductName
    from Products P
             join Suppliers S on P.SupplierID = S.SupplierID
    where CompanyName = @CompanyName
end;

execute sp_products_by_supplier 'Leka Trading'

/*  Ejercicio 10:
    Crear una función o procedimiento almacenado que retorne el proveedor con la mayor cantidad de productos
    comercializados de acuerdo a un determinado país de origen.
 */

create function f_products_by_supplier_per_country(@Country nvarchar(15))
    returns table
        as
        return
            (
                select CompanyName, count(ProductId) as Quantity
                from Suppliers s
                         join Products P on s.SupplierID = P.SupplierID
                where Country = @Country
                group by CompanyName
            )
go;

create function f_best_supplier_per_country(@Country nvarchar(15))
    returns table
        as
        return
            (
                select CompanyName
                from dbo.f_products_by_supplier_per_country(@Country)
                where Quantity = (
                    select max(Quantity)
                    from dbo.f_products_by_supplier_per_country(@Country)
                )
            )

select *
from dbo.f_best_supplier_per_country('France');


/*  Ejercicio 11:

    Crear un procedimiento almacenado o una función que retorne la categoría de producto con la mayor de
    ordenes realizadas de acuerdo al país de destino.
 */

create function f_orders_by_category_per_country(@Country nvarchar(15))
    returns table
        as
        return
            (
                select CategoryName, count(O.OrderID) as Quantity
                from Orders O
                         join [Order Details] [O D] on O.OrderID = [O D].OrderID
                         join Products P on [O D].ProductID = P.ProductID
                         join Categories C on P.CategoryID = C.CategoryID
                where ShipCountry = @Country
                group by CategoryName
            )

create function f_best_category_per_country(@Country nvarchar(15)) returns nvarchar(15)
as
begin
    declare @CategoryName nvarchar(15)

    select @CategoryName = CategoryName
    from dbo.f_orders_by_category_per_country(@Country)
    where Quantity = (select max(quantity) from dbo.f_orders_by_category_per_country(@Country))

    return @CategoryName
end

print dbo.f_best_category_per_country('France')


/*  Ejercicio 12:
    Crear un procedimiento almacenado que muestre la categoría en la que se tuvo el mayor monto de venta
    acumulado.
 */

create function f_sales_by_category()
    returns table
        as return
            (
                select CategoryName, sum(OD.unitprice * quantity - discount) as Total
                from Categories C
                         join Products P on C.CategoryID = P.CategoryID
                         join [Order Details] OD on P.ProductID = OD.ProductID
                group by CategoryName
            )

create function f_best_category() returns nvarchar(15)
as
begin
    declare @CategoryName nvarchar(15)

    select @CategoryName = CategoryName
    from dbo.f_sales_by_category()
    where total = (select max(Total) from dbo.f_sales_by_category())

    return @CategoryName
end;
go;

print dbo.f_best_category()

/* Ejercicio 13:
   Mostrar en un procedimiento almacenado, el país donde se ha vendido más órdenes durante un año ingresado
   como parámetro.
 */

create function f_orders_by_country_per_year(@Year int)
    returns table
        as return
            (
                select ShipCountry, count(OrderID) as Total
                from orders
                where year(OrderDate) = @Year
                group by ShipCountry
            )

create function f_best_country_per_year(@Year int) returns nvarchar(15)
as
begin
    declare @ShipCountry nvarchar(15)

    select @ShipCountry = ShipCountry
    from dbo.f_orders_by_country_per_year(@Year)
    where Total = (select max(Total) from dbo.f_orders_by_country_per_year(@Year))
    return @ShipCountry
end

print dbo.f_best_country_per_year (2017)

/*  Ejercicio 14:
    Mostrar en un procedimiento almacenado o función el proveedor que tuvo la menor cantidad de cantidad de productos
    vendidos en un año ingresado como parámetro.
 */

-- Mediante funciones

create function f_products_by_company_per_year(@Year int)
    returns table
        as
        return
        select CompanyName, sum(Quantity) as Total
        from Suppliers S
                 join Products P on S.SupplierID = P.SupplierID
                 join [Order Details] OD on P.ProductID = OD.ProductID
                 join Orders O on OD.OrderID = O.OrderID
        where year(OrderDate) = @Year
        group by CompanyName;


create function f_worst_supplier_per_year(@Year int)
    returns nvarchar(40)
as
begin
    declare @CompanyName nvarchar(40)
    select @CompanyName = CompanyName
    from dbo.f_products_by_company_per_year(@Year)
    where total = (select min(Total) from dbo.f_products_by_company_per_year(@Year))
    return @CompanyName
end;
go;

print dbo.f_worst_supplier_per_year(1997)


-- Mediante vistas

create view v_product_by_company_by_year as
select Year(OrderDate) as Year, CompanyName, sum(Quantity) as Total
from Suppliers S
         join Products P on S.SupplierID = P.SupplierID
         join [Order Details] OD on P.ProductID = OD.ProductID
         join Orders O on OD.OrderID = O.OrderID
group by YEAR(OrderDate), CompanyName;

select *
from v_product_by_company_by_year


create function f_worst_supplier_per_year(@Year int) returns nvarchar(40)
as
begin
    declare @CompanyName nvarchar(40)

    select @CompanyName = CompanyName
    from v_product_by_company_by_year
    where total = (select min(Total) from v_product_by_company_by_year where Year = @Year)
      and Year = @Year

    return @CompanyName
end

/*  Ejercicio 15:
    Crear una función o procedimiento almacenado que retorne la
    cantidad de órdenes para un determinado año, el cual es
    ingresado como parámetro.
*/
create function f_orders_per_year(@Year int) returns int
as
begin
    declare @Quantity int

    select @Quantity = count(OrderID)
    from Orders
    where year(OrderDate) = @Year

    return @Quantity
end;
go;

/*  Ejercicio 16:
    Crear una función o procedimiento almacenado que retorne la
    categoría con la menor cantidad de órdenes realizadas durante
    un determinado año, el cual es ingresado como parámetro.
*/

select min(Quantity)
from (select CategoryName, count(O.OrderID) as Quantity
      from Categories C
               join Products P on C.CategoryID = P.CategoryID
               join [Order Details] [O D] on P.ProductID = [O D].ProductID
               join Orders O on [O D].OrderID = O.OrderID
      where year(orderDate) = 2017
      group by CategoryName) as Result;
/*
CategoryName    Quantity
Beverages       100
Condiments      50
Clothes         20
*/
--select CategoryName from Result where Quantity = 20


create function f_orders_by_category_per_year(@Year int)
    returns table
        as
        return
        select CategoryName, count(O.OrderID) as Quantity
        from Categories C
                 join Products P on C.CategoryID = P.CategoryID
                 join [Order Details] [O D] on P.ProductID = [O D].ProductID
                 join Orders O on [O D].OrderID = O.OrderID
        where year(orderDate) = @Year
        group by CategoryName

create function f_bestCategory_per_year(@Year int) returns nvarchar(15)
as
begin
    declare @CategoryName nvarchar(15)

    select @CategoryName = CategoryName
    from dbo.f_orders_by_category_per_year(@Year)
    where Quantity = (select min(Quantity) from dbo.f_orders_by_category_per_year(@Year))

    return @CategoryName
end;

/*  Ejercicio 17:
    Crear una función o procedimiento almacenado que retorne la
    cantidad de órdenes atendidas por cada embarcador (shipper)
    durante un determinado año, el cual es ingresado como parámetro.
*/

create procedure sp_orders_by_shipper_per_year @Year int
as
begin
    select CompanyName, count(OrderId)
    from Shippers S
             join Orders O on S.ShipperID = O.ShipVia
    where year(OrderDate) = @Year
    group by CompanyName
end

/*  Ejercicio 18:
    Crear una función o procedimiento almacenado que retorne el
    nombre del cliente con la mayor cantidad de órdenes solicitadas
    para un determinado país de destino y un determinado año, los cuales son
    ingresados como parámetros.
*/

create function f_orders_per_company_per_year(@Country nvarchar(15), @year int)
    returns table
        as
        return
        select CompanyName, count(OrderId) as Total
        from Customers C
                 join Orders O on C.CustomerID = O.CustomerID
        where ShipCountry = @Country
          and year(OrderDate) = @year
        group by CompanyName


create function f_best_customer_per_country_per_year(@Country nvarchar(15), @Year int)
    returns table
        as
        return
        select CompanyName
        from dbo.f_orders_per_company_per_year(@Country, @Year)
        where Total = (select max(Total) from dbo.f_orders_per_company_per_year(@Country, @Year))

select *
from dbo.f_best_customer_per_country_per_year('France', 1997)


create procedure sp_best_customer_per_country_per_year(@Country nvarchar(15), @Year int) as
begin
    select CompanyName
    from dbo.f_orders_per_company_per_year(@Country, @Year)
    where Total = (select max(Total) from dbo.f_orders_per_company_per_year(@Country, @Year))
end;
go;

execute sp_best_customer_per_country_per_year 'USA', 1997

/*  Ejercicio 19:
    Crear un procedimiento almacenado o función que retorne la cantidad de
    empleados de acuerdo a un determinado país, el cual es ingresado como parámetro.
 */

create function f_employees_per_country(@Country nvarchar(15)) returns int
as
begin
    declare @Quantity int

    select @Quantity = count(EmployeeID)
    from Employees
    where Country = @Country

    return @Quantity
end;
go;

print dbo.f_employees_per_country('USA');


/*  Ejercicio 20:
    Crear un procedimiento almacenado o función que permita mostrar la cantidad
    de órdenes realizadas por país de destino de acuerdo a un determinado año,
    el cual es ingresado como parámetro.
 */

create function f_orders_by_country_per_year(@Year int)
    returns table
        as
        return
        select ShipCountry, count(OrderId) as Quantity
        from Orders
        where year(OrderDate) = @Year
        group by ShipCountry;

select *
from dbo.f_orders_by_country_per_year(1997);


/*  Ejercicio 21:
    Crear un procedimiento almacenado o función que retorne el cliente con la mayor cantidad de órdenes realizadas
    de acuerdo a un determiando país de destino, el cual es ingresado como parámetro.
 */

create function f_orders_by_company_per_country(@Country nvarchar(15))
    returns table
        as
        return
        select CompanyName, count(OrderId) as Quantity
        from Customers C
                 join Orders O on C.CustomerID = O.CustomerID
        where ShipCountry = @Country
        group by CompanyName;

select *
from dbo.f_orders_by_company_per_country('Argentina')

create function f_best_company_per_country(@Country nvarchar(15)) returns nvarchar(40)
as
begin
    declare @CompanyName nvarchar(40)

    select @CompanyName = CompanyName
    from dbo.f_orders_by_company_per_country(@Country)
    where Quantity = (select max(Quantity) from dbo.f_orders_by_company_per_country(@Country))

    return @CompanyName
end;
go;

print dbo.f_best_company_per_country('Argentina');
go;

/*  Ejercicio: 22
    Crear un procedimiento almacenado o función que retorne el nombre del embarcador con mayor cantidad
    de pedidos atentidos para un determinado país de destino, el cual es ingresado como parámetro.

 */

create function f_orders_by_shipper_per_country(@Country nvarchar(15))
    returns table
        as
        return
        select CompanyName, count(OrderId) as Quantity
        from Shippers S
                 join Orders O on S.ShipperID = O.ShipVia
        where ShipCountry = @Country
        group by CompanyName;

create function f_best_shipper_per_country(@Country nvarchar(15)) returns nvarchar(40)
as
begin
    declare @CompanyName nvarchar(40)

    select @CompanyName = CompanyName
    from dbo.f_orders_by_shipper_per_country(@Country)
    where Quantity = (select max(Quantity) from dbo.f_orders_by_shipper_per_country(@Country))

    return @CompanyName
end;
