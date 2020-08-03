CREATE OR REPLACE FUNCTION get_week_report(input_date DATE)
  RETURNS TABLE (office_id int, Mon int, Tue int, Wed int, Thu int, Fri int, Sat int, Sun int, Total int) AS
$BODY$
BEGIN
    RETURN QUERY
    SELECT * 
    FROM crosstab(
        $$WITH cte AS(
            SELECT mcio.office_id, 
                   EXTRACT(isodow FROM rmcs.rented_at) AS week_day, 
                   COUNT(*) AS rented_movies 
            FROM movie_copy_in_office AS mcio 
                 INNER JOIN rented_movie_copy_status AS rmcs 
                 ON mcio.id = rmcs.id_movie_copy_in_office 
                   AND rmcs.rented_at::DATE 
                     BETWEEN DATE_TRUNC('week', $$ || QUOTE_LITERAL(input_date) || $$)::DATE AND 
                             DATE_TRUNC('week', $$ || QUOTE_LITERAL(input_date) || $$)::DATE + INTERVAL '6 days' 
            GROUP BY 1, 2
            )
          TABLE cte
          UNION ALL
          SELECT office_id, 999 AS week_day, SUM(rented_movies) AS rented_movies
          FROM cte
          GROUP BY 1
          ORDER BY 1$$,
        $$VALUES (1), (2), (3), (4), (5), (6), (7), (999)$$
    ) AS (office_id int, 
          "Mon" int, 
          "Tue" int, 
          "Wed" int, 
          "Thu" int, 
          "Fri" int, 
          "Sat" int, 
          "Sun" int, 
          "Total" int);
END
$BODY$ 
LANGUAGE plpgsql;
