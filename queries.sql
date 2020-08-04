-- show offices which have more than 3 "Horror" movies.



SELECT office.id AS office_id
FROM office 
  INNER JOIN movie_copy_in_office 
  ON office.id = movie_copy_in_office.office_id 
  INNER JOIN movie_genre_m2m 
  ON movie_copy_in_office.movie_id = movie_genre_m2m.movie_id 
WHERE movie_genre_m2m.genre_id = (SELECT id FROM genre WHERE name = 'Horror')
GROUP BY office.id
HAVING COUNT(*) > 3;



-- show offices with Oscar movies amount for each one.



SELECT office_id, COUNT(*) AS oscar_movies_amount
FROM (SELECT DISTINCT office.id AS office_id,
             movie_copy_in_office.movie_id AS movie_id
      FROM office 
        INNER JOIN movie_copy_in_office 
        ON office.id = movie_copy_in_office.office_id 
        INNER JOIN movie_actor_m2m 
        ON movie_copy_in_office.movie_id = movie_actor_m2m.movie_id
        INNER JOIN actor
        ON movie_actor_m2m.actor_id = actor.id
      WHERE actor.has_oscar) AS oscar_movies_in_offices
GROUP BY oscar_movies_in_offices.office_id;



-- show movies that are in at least two(2) offices



SELECT movie.name AS movie_name, 
       count(*) AS offices_amount
FROM movie_copy_in_office
  INNER JOIN movie
  ON movie_copy_in_office.movie_id = movie.id
GROUP BY movie.name
HAVING COUNT(*) >= 2;



-- the most rated movie of each office



WITH avg_movie_rating_in_office AS (SELECT office_id, 
                                           movie_id, 
                                           AVG(value) AS avg_movie_rating
                                    FROM movie_rating_in_office
                                    GROUP BY office_id, movie_id)
SELECT office_and_movie_id.office_id,
       movie.name AS most_rated_movie_name
FROM movie
  INNER JOIN (SELECT max_movie_rating_in_office.office_id,
                     avg_movie_rating_in_office.movie_id
              FROM (SELECT office_id,
                           MAX(avg_movie_rating) AS max_movie_rating
                    FROM avg_movie_rating_in_office
                    GROUP BY office_id) AS max_movie_rating_in_office
                      INNER JOIN avg_movie_rating_in_office
                      ON max_movie_rating_in_office.office_id = avg_movie_rating_in_office.office_id
                         AND max_movie_rating_in_office.max_movie_rating = avg_movie_rating_in_office.avg_movie_rating) AS office_and_movie_id
  ON office_and_movie_id.movie_id = movie.id;



-- 10% salary bonus of the salary if a salesperson has made 5 orders from the last month



SELECT employee.name,
       employee.surname,
       employee.patronym,
       (SELECT name FROM rank WHERE id = employee.rank_id) AS rank_name,
       employee.office_id,
       employee.department_id,
       employee.salary,
       employee.salary * .1 AS salary_bonus
FROM (SELECT employee_id, COUNT(*) AS orders_amount FROM rented_movie_copy_status
      WHERE EXTRACT(YEAR FROM rented_at) = EXTRACT('YEAR' FROM NOW() - INTERVAL '1 month')
      AND EXTRACT(MONTH FROM rented_at) = EXTRACT('MONTH' FROM NOW() - INTERVAL '1 month')
      GROUP BY employee_id) AS employee_orders_amount
  INNER JOIN employee
  ON employee_orders_amount.employee_id = employee.id;



-- A fine for managers in the office who has unreturned movie copies from the last month.



SELECT name, 
       employee.surname, 
       employee.patronym, 
       employee.office_id,
       employee.salary,
       not_returned_movies_of_office.not_returned_movies_amount,
       not_returned_movies_of_office.not_returned_movies_amount * 5 AS fine,
       employee.salary - (not_returned_movies_of_office.not_returned_movies_amount * 5) AS difference
FROM employee
  INNER JOIN (SELECT (SELECT office_id 
                      FROM movie_copy_in_office 
                      WHERE movie_copy_in_office.id = rented_movie_copy_status.id_movie_copy_in_office),
                      COUNT(*) AS not_returned_movies_amount
              FROM rented_movie_copy_status
              WHERE EXTRACT(YEAR FROM rented_at) = EXTRACT('YEAR' FROM NOW() - INTERVAL '1 month')
                AND EXTRACT(MONTH FROM rented_at) = EXTRACT('MONTH' FROM NOW() - INTERVAL '1 month')
                AND returned_at IS NULL
              GROUP BY office_id) AS not_returned_movies_of_office
    ON employee.office_id = not_returned_movies_of_office.office_id
       AND employee.rank_id = (SELECT id FROM RANK WHERE name = 'manager');
