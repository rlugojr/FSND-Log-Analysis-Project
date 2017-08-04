CREATE VIEW articles_most_popular
AS
SELECT a.title, l.views
FROM articles AS a JOIN
 (SELECT path, count(path) AS views
  FROM log
  GROUP BY log.path) AS l
ON '/article/' || a.slug = l.path
ORDER BY views DESC
LIMIT 3;

CREATE VIEW authors_most_popular
AS
SELECT au.name, sum(l.views) AS total_reads
FROM authors AS au JOIN articles AS a
ON au.id = a.author JOIN (
    SELECT path, count(path) AS views
    FROM log
    GROUP BY log.path) AS l
ON '/article/' || a.slug = l.path
GROUP BY au.name
ORDER BY total_reads DESC;

CREATE VIEW request_high_percent_errors
AS
SELECT log_date,
       ((cast(total_failures AS float) / cast(total_reqs AS float))  * 100) AS error_percentage
FROM (SELECT cast(time AS date) AS log_date,
      count(*) AS total_reqs,
      count(*) FILTER (WHERE status = '404 NOT FOUND') AS total_failures
      FROM log
      GROUP BY log_date) AS log_info
WHERE ((cast(total_failures AS float) / cast(total_reqs AS float)) * 100) > 1;

select * from articles_most_popular;

select * from authors_most_popular;

select * from request_high_percent_errors;
