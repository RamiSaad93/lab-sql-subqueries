USE sakila;

# 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
# 2. List all films whose length is longer than the average length of all the films in the Sakila database.
# 3. Use a subquery to display all actors who appear in the film "Alone Trip".

# 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT COUNT(film_id)
FROM inventory 
WHERE film_id IN (SELECT film_id FROM film WHERE title = "Hunchback Impossible");

# 2. List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT title , length
FROM film
WHERE length > ( SELECT AVG(length) from film)
ORDER BY length ASC;

# 3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT CONCAT(first_name," ",last_name)
FROM actor 
WHERE actor_id IN (SELECT actor_id
					FROM film_actor
                    WHERE film_id IN (SELECT film_id 
									  FROM film
                                      WHERE title = "Alone Trip"));

# 4. Sales have been lagging among young families, and you want to target family movies for a promotion.
	# Identify all movies categorized as family films.
# 5. Retrieve the name and email of customers from Canada using both subqueries and joins.
	# To use joins, you will need to identify the relevant tables and their primary and foreign keys.
# 6. Determine which films were starred by the most prolific actor in the Sakila database. 
	# A prolific actor is defined as the actor who has acted in the most number of films.
    # First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
# 7. Find the films rented by the most profitable customer in the Sakila database. 
	# You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
# 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
	# You can use subqueries to accomplish this.

# 4. Sales have been lagging among young families, and you want to target family movies for a promotion.
	# Identify all movies categorized as family films.
    
SELECT DISTINCT title, rating 
FROM film
WHERE rating = "G";

# 5. Retrieve the name and email of customers from Canada using both subqueries and joins.
	# To use joins, you will need to identify the relevant tables and their primary and foreign keys.
    
SELECT CONCAT(c.first_name, " ", c.last_name) AS name, co.country
FROM customer AS c
INNER JOIN address AS a
USING(address_id)
INNER JOIN city 
USING(city_id)
INNER JOIN country AS co
USING(country_id)
WHERE co.country = "Canada";


SELECT CONCAT(c.first_name, " ", c.last_name) AS name
FROM customer AS c
WHERE c.address_id IN (SELECT address_id
						FROM address 
                        WHERE city_id IN (SELECT city_id 
										  FROM city
                                          WHERE city.country_id IN (SELECT country.country_id
                                                              FROM country
                                                              WHERE country = "canada")));
														
# 6. Determine which films were starred by the most prolific actor in the Sakila database. 
	# A prolific actor is defined as the actor who has acted in the most number of films.
    # First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
    
SELECT title 
FROM film 
WHERE film_id IN (SELECT film_id 
				  FROM film_actor 
                  WHERE actor_id = (SELECT actor_id
									 FROM film_actor 
                                     GROUP BY actor_id 
                                     ORDER BY count(film_id) desc 
                                     LIMIT 1));
 
# 7. Find the films rented by the most profitable customer in the Sakila database. 
	# You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
    
SELECT film.title FROM film WHERE film_id IN (
SELECT film_id FROM inventory WHERE inventory_id IN (
SELECT inventory_id FROM rental WHERE customer_id IN (
SELECT customer_id FROM customer WHERE customer_id = ( 
SELECT customer_id FROM payment GROUP BY customer_id ORDER BY SUM(amount) DESC LIMIT 1))));

# How to use joins for the same task
SELECT film.title
FROM film 
INNER JOIN inventory
USING(film_id)
INNER JOIN rental
USING(inventory_id)
INNER JOIN customer
USING(customer_id)
INNER JOIN payment
USING(customer_id)
WHERE payment.customer_id = (SELECT customer_id from payment  
GROUP BY payment.customer_id
ORDER BY SUM(payment.amount) DESC 
LIMIT 1);

# 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than 
	# the average of the total_amount spent by each client. 
	# You can use subqueries to accomplish this.

SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING sum(amount) > (SELECT AVG(total_spent.total)
					  FROM payment 
					  INNER JOIN (SELECT customer_id, SUM(amount) AS total 
								  FROM payment 
                                  GROUP BY customer_id) AS total_spent
					              USING(customer_id));
                               

SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id 
ORDER BY SUM(amount) DESC;
									

SELECT AVG(total_spent.total)
FROM payment 
INNER JOIN (SELECT customer_id, SUM(amount) AS total FROM payment GROUP BY customer_id) AS total_spent
USING(customer_id);






