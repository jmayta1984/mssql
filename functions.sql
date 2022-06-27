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
