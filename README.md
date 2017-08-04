# FSND Log Analysis Project

## Introduction

The purpose of this project is generate a report of a blog's web server activity data analysis using python to query a Postgres DB and save the resulting output to a text file.  The data analysis will report the answer to the following business critical questions:

1.  What are the most popular three articles of all time?
2.  Who are the most popular article authors of all time?
3.  On which days did more than 1% of requests lead to errors?

## Setup

### Server Environment

There are several methods of preparing a server environment to run this analysis. The quickest, simplest method and one that will ensure compatibility is to use Udacity's Linux virtual machine.  The instructions for installation and creation of the VM can be found here:
[Linux VM Setup](https://classroom.udacity.com/nanodegrees/nd004/parts/8d3e23e1-9ab6-47eb-b4f3-d5dc7ef27bf0/modules/bc51d967-cb21-46f4-90ea-caf73439dc59/lessons/5475ecd6-cfdb-4418-85a2-f2583074c08d/concepts/14c72fe3-e3fe-4959-9c4b-467cf5b7c3a0)

### Database setup

The data used for this project can be downloaded here: [newsdata.sql](https://d17h27t6h515a5.cloudfront.net/topher/2016/August/57b5f748_newsdata/newsdata.zip)
Copy this data into the "/vagrant/news" directory and then run the following command inside of the terminal command line:

        psql -d news -f newsdata.sql

\*\*\* Note: ensure that your working directory contains the newsdata.sql file or add the full path to the psql command.

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
\*\*\* Note: ensure that your working directory contains the newsdata.sql file or add the full path to the psql command.

2.  From the terminal, run


        python report.py

3.  Open the output file named with the format "Log_Report\_[current date]".

The majority of the data processing is handled by the Postgres DBMS whereas "report.py" only contains the python code to retrieve data from the SQL Views and format the results into the output report file.
