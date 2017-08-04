# FSND Log Analysis Project

## Introduction

The purpose of this project is generate a report of a blog's web server activity data analysis using python to query a Postgres DB and save the resulting output to a text file.

## Setup

The FSND Linux VM should be used to ensure compatibility with this project.  Otherwise, you can run this on a Linux system that has Python >=3.5 and Postgres >= 9.5.

The data used for this project can be found in the corresponding FSND materials.

The following SQL Views have been provided in the sql_views.sql:

1.  Top 3 most popular articles.
    CREATE view articles_most_popular
    AS
        SELECT a.title,
             Count(\*) AS total_reads
        FROM   articles AS a
        JOIN (SELECT path,
           REPLACE(path, '/article/', '') AS slug
           FROM   log) AS l
        ON a.slug = l.slug
        GROUP  BY a.title
        ORDER  BY total_reads DESC
        LIMIT  3;

2.  Most popular authors (by article views).
    CREATE VIEW authors_most_popular
    AS
        SELECT au.name,
               Count(\*) AS total_reads
        FROM   authors AS au
        JOIN articles AS a
        ON au.id = a.author
        JOIN (SELECT path,
                    Replace(path, '/article/', '') AS slug
              FROM   log) AS l
        ON a.slug = l.slug
        GROUP  BY au.name
        ORDER  BY total_reads DESC;

3.  Date with the highest percentage of failed requests.
    CREATE VIEW request_high_percent_errors
    AS
        SELECT log_date, ((Cast(total_failures AS FLOAT) / Cast(total_reqs AS FLOAT)) _ 100) AS error_percentage
        FROM   (
                SELECT   Cast(TIME AS DATE) AS log_date,
                         Count(_) AS total_reqs,
                         Count(_) filter (WHERE status = '404 NOT FOUND') AS total_failures
                FROM     log
                GROUP BY log_date) AS log_info
        WHERE  ((cast(total_failures AS FLOAT) / cast(total_reqs AS FLOAT)) _ 100) > 1;
