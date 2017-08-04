# FSND Log Analysis Project

## Introduction

The purpose of this project is generate a report of a blog's web server activity data analysis using python to query a Postgres DB and save the resulting output to a text file.  The data analysis will report the answer to the following business critical questions:

1.  What are the most popular three articles of all time?
2.  Who are the most popular article authors of all time?
3.  On which days did more than 1% of requests lead to errors?

## Setup

### Server Environment

There are several methods of preparing a server environment to run this analysis. The quickest, simplest method and one that will ensure compatibility is to use Udacity's Linux virtual machine.  The instructions for installation and creation of the VM can be found here:
[Udacity's Linux VM Setup](https://classroom.udacity.com/nanodegrees/nd004/parts/8d3e23e1-9ab6-47eb-b4f3-d5dc7ef27bf0/modules/bc51d967-cb21-46f4-90ea-caf73439dc59/lessons/5475ecd6-cfdb-4418-85a2-f2583074c08d/concepts/14c72fe3-e3fe-4959-9c4b-467cf5b7c3a0)

After using the instructions from the link above, you will have a Linux server VM that runs in [VirtualBox](https://www.virtualbox.org/wiki/Downloads) using [Vagrant](https://www.vagrantup.com/downloads.html) to control the configuration and startup with  Udacity's ["vagrantfile"](https://github.com/udacity/fullstack-nanodegree-vm).

### Python Environment

This project requires Python 3 and psycopg2 which is a Python interface library for Postgres.  This last library can be installed (after Python has been installed) using:

        "pip install psycopg2"

If this library is not installed then the Python script will not be able to connect to the "news" DB and the process will fail, providing an error stating "Can't connect to DB" or "Failed to get results from query"

### Database setup

The data used for this project can be downloaded here: [newsdata.sql](https://d17h27t6h515a5.cloudfront.net/topher/2016/August/57b5f748_newsdata/newsdata.zip)  Using this file you will be able to create the "news" database, tables and insert the data automatically.

If you are using the Udacity Linux VM, copy newsdata.sql into the mounted directory "/vagrant/news" (create dir if it doesn't exist)  and then run the following command inside of the terminal:

        psql -d news -f newsdata.sql

\* Note: ensure that your working directory contains the newsdata.sql file or add the full path to the psql command.

**_Custom SQL Views_** have been provided in the file  [sql_views.sql](https://github.com/rlugojr/FSND-Log-Analysis-Project/blob/master/sql_views.sql)\
To use this file to create the SQL Views from the terminal, run psql with "sql_views.sql" to create the necessary iews inside of the "news" DB using the command:

        psql -d news -f "sql_views.sql"

\* Note: ensure that your working directory contains the newsdata.sql file or add the full path to the psql command.

When the SQL script finishes creating the views, select statements will run to test each view.

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

1.  Open "report.py" in your favorite python editor and check that the values for the constants "DB" and the output "FILENAME".  Default value for the DB is "news".  Save the file of you change either parameter.

2.  From the terminal, switch your working directory to the one that contains "report.py" and then run the command:


        python report.py

2.  Open the output file named with the format "Log_Report\_[current date]".


        cat Log_Report_[current date]

The majority of the data processing is handled by the Postgres DBMS whereas "report.py" only contains the python code to retrieve data from the SQL Views and format the results into the output report file.
