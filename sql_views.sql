create view articles_most_popular as select a.title, count(*) as total_reads from articles as a join (select path, replace(path,'/article/','') as slug from log) as l
on a.slug = l.slug group by a.title order by total_reads desc limit 3;

create view authors_most_popular as select au.name,count(*) as total_reads from authors as au join articles as a on au.id = a.author join (select path, replace(path,'/article/','') as slug from log) as l on a.slug = l.slug group by au.name order by total_reads desc;

create view request_high_percent_errors as select log_date, ((cast(total_failures as float) / cast(total_reqs as float)) * 100) as error_percentage from (select cast(time as date) as log_date, count(*) as total_reqs, count(*) FILTER (WHERE status = '404 NOT FOUND') as total_failures from log group by log_date) as log_info where ((cast(total_failures as float) / cast(total_reqs as float)) * 100) > 1;

select * from articles_most_popular;

select * from authors_most_popular;

select * from request_high_percent_errors;

