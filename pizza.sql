select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- total order place
select count(order_id) as total_no_of_odr from orders;

-- total revenue
select 
sum(order_details.quantity*pizzas.price) as Total_Sale
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id;

--Identify the highest-priced pizza.
select pizzas.price as highest_price,pizza_types.name 
from pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price desc;

--Identify the most common pizza size ordered.
select pizzas.size,count(order_details.quantity)as odr_cnt
from pizzas join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size 
order by odr_cnt;

--List the top 5 most ordered pizza types along with their quantities.
select sum(order_details.quantity)as ttlQty,pizza_types.name
from pizzas join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by ttlQty desc;

--Join the necessary tables to find the total quantity of each pizza category ordered.
select sum(order_details.quantity) as  qty,pizza_types.category
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by qty;

--Determine the distribution of orders by hour of the day.
select HOUR(time),count(order_id) as qty  
from orders 
group by HOUR(time)


--Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name)as pizzas from pizza_types
group by category;

--Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(orderPerDay) from
(select orders.date as Per_Day,sum(order_details.quantity)as orderPerDay
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.date
) as avg_qty;

--Determine the top 3 most ordered pizza types based on revenue.
select sum(order_details.quantity*pizzas.price) as reveanue,pizza_types.name 
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by reveanue desc;

--Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,(sum(pizzas.price*order_details.quantity)/ (select 
sum(order_details.quantity*pizzas.price)
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id)*100) as reveanue 
from order_details join  pizzas 
on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by reveanue desc;

--Analyze the cumulative revenue generated over time.
select order_date, sum(reveanue) over(order by order_date) as cum_rev from 
(select orders.date as order_date ,sum(order_details.quantity*pizzas.price) as reveanue
from order_details join orders 
on order_details.order_id = orders.order_id
join pizzas 
on order_details.pizza_id = pizzas.pizza_id
group by orders.date) as sales;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue
from
(select category,name,revenue, 
rank()over(partition by category order by revenue desc) as rn 
from 
(select pizza_types.category as category ,pizza_types.name,
sum(pizzas.price*order_details.quantity) as revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn <=3;