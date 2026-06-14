use case_margin;
select * from ventas;

#average discount rate per units sold
select cantidad as units_sold, avg(Tasa_descuento) as avg_discount_rate
from ventas
group by units_sold;

#average discount rate per clients payments
select ID_cliente as Clients, avg(Tasa_descuento) as avg_discount_rate, sum(Precio_total_sin_descuento) as client_payment
from ventas
group by Clients
order by client_payment desc;

#clients payments sections and avg discount rate 25, 4624, 9224
with cte_1 as (
select ID_cliente, sum(Precio_total_con_descuento) as revenue, avg(Tasa_descuento) as avg_discount_rate
from ventas
group by ID_cliente
order by revenue),

cte_2 as (
select ID_cliente, revenue, avg_discount_rate,
case when revenue <= (select max(revenue)/ 5 from cte_1) then "section 1"
when revenue <= (select max(revenue)/ 5 *2 from cte_1) then "section 2"
when revenue <= (select max(revenue)/ 5 *3 from cte_1) then "section 3"
when revenue <= (select max(revenue)/ 5 *4 from cte_1) then "section 4"
else "section 5"
end as revenue_sections
from cte_1)

select revenue_sections, avg(avg_discount_rate) as avg_discount_section
from cte_2
group by revenue_sections
order by revenue_sections;

#leakage rate over clients revenue
select c.ID_cliente as clients, sum(Precio_total_sin_descuento) as revenue, 
round(((RebateAcum/sum(Precio_total_sin_descuento))*100), 2) as leakage_percentage_rev
from clientes as c inner join ventas as v
	on c.ID_cliente = v.ID_cliente
group by clients;

#average discount rate per comercial
select c.ID_comercial as comercial, avg(Tasa_descuento) as avg_discount_rate
from ventas as v inner join comerciales as c
on v.ID_comercial = c.ID_comercial
group by comercial;

#average discount rate per average profit margin category
select Nombre_categoria, avg(Tasa_descuento) as avg_discount_rate, avg(Margen) as avg_margin
from productos as p inner join ventas as v
on p.ID_producto = v.ID_producto
group by Nombre_categoria;

#average discount rate per month and year
select date_format(Fecha_pedido, '%Y-%M') as year_and_month, avg(Tasa_descuento) as avg_discount_rate
from ventas
group by date_format(Fecha_pedido, '%Y-%M')
order by  year_and_month;

#comission percentage over revenue of comercials vs average discount rate on 2022
with CTE1 as (
select ID_comercial, avg(Tasa_descuento) as avg_discount, 
sum(Precio_total_sin_descuento) as total_rev
from ventas
where year(Fecha_pedido) = 2022
group by ID_comercial)

select c.ID_comercial, (ComisionAcum/total_rev)*100 as avg_comission_rate, avg_discount
from CTE1 as ct inner join comerciales as c
	on ct.ID_comercial = c.ID_comercial
order by avg_comission_rate;
