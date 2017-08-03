# FSND Log Analysis Project

The purpose of this project is to create a report that provides analysis of data from DB tables and from a web server activity log.

    CREATE view articles_most_popular
    AS
      SELECT title,
             Count(\*) AS total_reads
      FROM   (SELECT a.title,
                     a.slug,
                     l.path,
                     l.slug
              FROM   articles AS a
              JOIN (SELECT path,
                          REPLACE(path, '/article/', '') AS slug
                    FROM   log) AS l
              ON a.slug = l.slug) AS article_reads
      GROUP  BY title
      ORDER  BY total_reads DESC
      LIMIT  3;

    CREATE VIEW authors_most_popular
    AS
      SELECT name,
             Count(\*) AS total_reads
      FROM   (SELECT au.name,
                     au.id,
                     a.author,
                     a.title,
                     a.slug,
                     l.path,
                     l.slug
              FROM   authors AS au
                     join articles AS a
                       ON au.id = a.author
                     join (SELECT path,
                                  Replace(path, '/article/', '') AS slug
                           FROM   log) AS l
              ON a.slug = l.slug) AS author_reads
      GROUP  BY name
      ORDER  BY total_reads DESC;

    CREATE VIEW request_high_percent_errors
    AS
      SELECT To_char(log_date, 'YYYY-MM-DD') AS log_date,
             percent_errors
      FROM   (SELECT treads.log_date AS log_date,
                     total_reads,
                     total_failures,
                     ( Cast(total_failures AS FLOAT) / Cast(total_reads AS FLOAT) _ 100 ) AS percent_errors
              FROM   (SELECT Cast(TIME AS DATE) AS log_date,
                             Count(_)           AS total_reads
                      FROM   log
                      WHERE  status = '200 OK'
                      GROUP  BY log_date) AS treads
              JOIN (SELECT Cast(TIME AS DATE) AS log_date,
                          Count(\*)           AS total_failures
                   FROM   log
                   WHERE  status = '404 NOT FOUND'
                   GROUP  BY log_date) AS tfails
              ON treads.log_date = tfails.log_date) AS report
      WHERE  percent_errors > 1;
