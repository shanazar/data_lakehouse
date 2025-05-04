{{
	config(
	    schema='dwh',
		materialized='table',
        enabled=true
	)
}}

/*TODO Is holiday, holiday name */

with dates as (
   SELECT date_col
   FROM UNNEST(sequence(date '1900-01-01', date '1910-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1911-01-01', date '1920-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1921-01-01', date '1930-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1931-01-01', date '1940-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1941-01-01', date '1950-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1951-01-01', date '1960-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1961-01-01', date '1970-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1971-01-01', date '1980-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1981-01-01', date '1990-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '1991-01-01', date '2000-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '2001-01-01', date '2010-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '2011-01-01', date '2020-12-31', INTERVAL '1' DAY)) t (date_col)
   union all
   SELECT date_col
   FROM UNNEST(sequence(date '2021-01-01', date '2030-12-31', INTERVAL '1' DAY)) t (date_col)
)

SELECT date_col AS d_date,
       year(date_col) AS d_year,
       month(date_col) AS d_month,
       quarter(date_col) AS d_quarter,
       day(date_col) AS d_day,
       day_of_week(date_col) AS d_weekday,
       date_format(date_col, '%Y-%m') AS d_year_month,
       date_format(date_col, '%Y-%m-%d') AS d_date_string
FROM dates