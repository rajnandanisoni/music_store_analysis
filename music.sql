--who is the senior most employee based on job title
select * from employee
order by levels desc
limit 1


--which country has the most invoices
select 
count(distinct invoice_id) as number_of_invoices,
billing_country
from invoice
group by billing_country
order by number_of_invoices desc

--what are the top 3 value of total invoices

select total 
from invoice
order by total desc
limit 3

-- which city has the bset customer? we would like to throw a promotional music festival in the city we made the most money write a query that returns one city that has the highest sum of invoice totalreturn both the city name and sum of all invoices
select sum(total)as invoice_total,
billing_city
from invoice
group by billing_city
order by invoice_total desc

--who is the best customer? the customer who spent the most money will declared the best customer. write a query that returns the person who has spent the most money.
select c.first_name, c.last_name, sum(i.total)as most_spent
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.first_name, c.last_name
order by most_spent desc
limit 1



--write a query to return first name , last name , email, genre of all rock music listeners. return your list orderd by email
select c.first_name, c.last_name, c.email,g.genre_id
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il. track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
order by email asc


select distinct email, first_name, last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where track_id in (
select t.track_id
from track t
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
)
order by email asc

--lets invite the artist who have written the most rock music in our dataset. Write a query that return the artist name and total track count of the top 10 rock band

 select 
 count(a.artist_id) as number_of_song,
 a.name 
 from artist a 
 join album al on a.artist_id = al.artist_id
 join track t on al.album_id = t.album_id
 join genre g on t.genre_id = g.genre_id
 where g.name like 'Rock'
 group by a.name
 order by number_of_song desc
 limit 10
 
 
 --return all the track that have a song length longer than the averge song length. Retuen the name and milliseconds for the each track. Order by the song length with the longest songs listed first.

select 
name , milliseconds
from track
where milliseconds >(
select avg(milliseconds) as track_length
		   from track)
order by milliseconds desc


--find how much amount spent by each customer on artist? write a query to return customer name, artist name and total spent

with best_selling_artist as (
    select a.artist_id as artist_id,a.name as artist_name,
    sum(il.unit_price * il.quantity) as total_sales
    from invoice_line il
    join track t on t.track_id = il.track_id
    join album al on al.album_id = t.album_id
    join artist a on a.artist_id = al.artist_id
    group by 1
    order by 3 desc
    limit 1
)
select c.customer_id, c.first_name,c.last_name, bsa.artist_name,
sum(il.unit_price * il.quantity)as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join best_Selling_artist bsa on al.artist_id = bsa.artist_id
group by 1,2,3,4
order by 5 desc;


-- we want to find out the most popular music genre for each country.we determine the most popular genre as the genre with the highest amount of purchases. write query that return each country along with the top genre. for countries where the maximum number of purchases is shared return all genres.

with popular_genre as 
(
     select count (il.quantity) as purchases, c.country, g.name, g.genre_id,
     row_number()over(partition by c.country order by count (il.quantity)desc)as rowNo
     from invoice_line il
     join invoice i on il.invoice_id = i.invoice_id
	 join customer c on i.customer_id = c.customer_id
     join track t on t.track_id = il.track_id
     join genre g on t.genre_id = g.genre_id
     group by 2,3,4
     order by 2 asc, 1 desc
)
select * from popular_genre where rowNo <= 1

--write a query that determines the customer that has spent the most on music for each country. write a query that return the country along with top customer and how much they have spent. for countries where the top amount spent is shared, provide all customers who spent this amount.

	with customer_with_country as (
			 select c.customer_id, first_name,last_name,billing_country, sum(total) as total_spending,
			 row_number() over(partition by billing_country order by sum(total)desc) as rowno
			 from invoice i
			 join customer c on c.customer_id = i.customer_id
			 group by 1,2,3,4
			 order by 4 asc ,5 desc)

select *from customer_with_country where rowno <=1
	
	  
		  