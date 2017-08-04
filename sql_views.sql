create view articles_most_popular
as
SELECT a.title, l.views
FROM articles AS a JOIN
 (SELECT path, count(path) AS views
  FROM log
  GROUP BY log.path) AS l
ON '/article/' || a.slug = l.path
ORDER BY views DESC
LIMIT 3;

create view authors_most_popular
as
select au.name, sum(l.views) as total_reads
from authors as au join articles as a
on au.id = a.author join (
    select path, count(path) as views
    from log
    GROUP BY log.path) as l
on '/article/' || a.slug = l.path
group by au.name
order by total_reads desc;

create view request_high_percent_errors as select log_date, ((cast(total_failures as float) / cast(total_reqs as float)) * 100) as error_percentage from (select cast(time as date) as log_date, count(*) as total_reqs, count(*) FILTER (WHERE status = '404 NOT FOUND') as total_failures from log group by log_date) as log_info where ((cast(total_failures as float) / cast(total_reqs as float)) * 100) > 1;

select * from articles_most_popular;

select * from authors_most_popular;

select * from request_high_percent_errors;
