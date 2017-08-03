create view articles_most_popular as select title, count(*) as total_reads from (select a.title, a.slug, l.path, l.slug from articles as a join (select path, replace(path,'/article/','') as slug from log) as l on a.slug = l.slug) as article_reads group by title order by total_reads desc limit 3;

create view authors_most_popular as select name, count(*) as total_reads from (select au.name,au.id,a.author, a.title, a.slug, l.path, l.slug from authors as au join articles as a on au.id = a.author join (select path, replace(path,'/article/','') as slug from log) as l on a.slug = l.slug) as author_reads group by name order by total_reads desc;

create view request_high_percent_errors as
select log_date, percent_errors from (select treads.log_date as log_date, total_reads, total_failures, (cast(total_failures as float)/cast(total_reads as float) * 100) as percent_errors from (select to_char(time,'YYYY MM DD') as log_date, count(*) as total_reads from log where status = '200 OK'group by log_date) as treads
join (select to_char(time,'YYYY MM DD') as log_date, count(*) as total_failures from log where status = '404 NOT FOUND' group by log_date) as tfails on treads.log_date = tfails.log_date) as report where percent_errors > 1;

select * from articles_most_popular;

select * from authors_most_popular;

select * from request_high_percent_errors;
