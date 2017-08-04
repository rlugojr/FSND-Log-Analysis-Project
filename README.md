# FSND Log Analysis Project

## Introduction

The purpose of this project is generate a report of a blog's web server activity data analysis using python to query a Postgres DB and save the resulting output to a text file.

## Setup

The FSND Linux VM should be used to ensure compatibility with this project.  Otherwise, you can run this on a Linux system that has Python >=3.5 and Postgres >= 9.5.

The data used for this project can be found in the corresponding FSND materials.

The following SQL Views have been provided in the sql_views.sql:

-   Top 3 most popular articles.


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

-   Most popular authors (by article views).


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

-   Date with the highest percentage of failed requests.


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

## Usage

To run the program and generate the report text file:

1.  From the terminal, run psql with sql_views.sql to create Views inside of the "news" DB using the command


        psql -d news -f "sql_views.sql"

When the SQL script finishes creating the views, select statements will run to test each view.

2.  From the terminal, run


        python report.py

3.  Open the output file named with the format "Log_Report\_[current date]".

The majority of the data processing is handled by the Postgres DBMS whereas "report.py" only contains the python code to retrieve data from the SQL Views and format the results into the output report file.
