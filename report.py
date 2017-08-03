#!/usr/bin/python3

"""Log Analysis Report from News DB"""

import psycopg2
import datetime
import sys

DBNAME = 'news'
FILENAME = 'Log_Report_{}.txt'.format(datetime.date.today())
SPACER = '\n\n'


def connect_to_db():
    """Establishes connection to SQL DB and returns connection
       and cursor objects."""

    try:
        conn = psycopg2.connect(database=DBNAME)
        cur = conn.cursor()
        return conn, cur
    except psycopg2.Error as e:
        print("Can't connect to {}", DBNAME)
        sys.exit(1)


def get_results(sql_query):
    """Executes SQL Query provided as a parameter and returns
       a result object."""

    try:
        conn, cur = connect_to_db()
        cur.execute(sql_query)
        results = cur.fetchall()
        conn.close()
        return results
    except:
        print("Failed to get results from query - {}".format(sql_query))
        sys.exit(1)


def write_to_file(stringOut, mode):
    """Placeholder"""
    try:
        with open(FILENAME, mode) as report_file:
            report_file.write(stringOut)
    except:
        print("Error writing to text file.")


def report_header():
    header = "Log Analysis report - {}.\n\n".format(datetime.date.today())
    print(header)
    write_to_file(header, 'w')


def articles_most_popular():
    """Placeholder"""
    section_header = "The most popular three articles of all time:\n"
    print(section_header)
    write_to_file(section_header, 'a')
    items = get_results('select * from articles_most_popular')
    for item in items:
        line_out = '"{}" - {:,d} views\n'.format(item[0], item[1])
        print(line_out)
        write_to_file(line_out, 'a')
    print(SPACER)
    write_to_file(SPACER, 'a')


def authors_most_popular():
    """Placeholder"""
    section_header = "The most popular article authors of all time:\n"
    print(section_header)
    write_to_file(section_header, 'a')
    items = get_results('select * from authors_most_popular')
    for item in items:
        line_out = '{} - {:,d} views\n'.format(item[0], item[1])
        print(line_out)
        write_to_file(line_out, 'a')
    print(SPACER)
    write_to_file(SPACER, 'a')


def request_high_percent_errors():
    """Placeholder"""
    section_header = "The day with >1% request errors:\n"
    print(section_header)
    write_to_file(section_header, 'a')
    items = get_results('select * from request_high_percent_errors')
    for item in items:
        line_out = '{} - {:01.2f}% errors\n'.format(item[0], item[1])
        print(line_out)
        write_to_file(line_out, 'a')
    print(SPACER)
    write_to_file(SPACER, 'a')


def build_report():
    report_header()

    articles_most_popular()

    authors_most_popular()

    request_high_percent_errors()


if __name__ == '__main__':
    build_report()
