
import psycopg2
import datetime
import sys

DBNAME = 'news'

def connect_to_db():
    """Establishes connection to SQL DB and returns connection and cursor objects."""

    try:
        conn = psycopg2.connect(database = DBNAME)
        cur = conn.cursor()
        return conn, cur
    except psycopg2.Error as e:
        print("Can't connect to {}", DBNAME)
        sys.exit(1)

def get_results(sql_query):
    """Executes SQL Query provided as a parameter and returns a result object."""
    
    try:
        conn, cur = connect()
        cur.execute(sql_query)
        results = cur.fetchall()
        conn.close()
        return results
    except:
        print("Failed to get results from query - {}", sql_query)
        sys.exit(1)

def articles_most_popular():


def authors_most_popular():


def request_high_percent_errors():


def build_report():
    print("Log Analysis report - {}.", datetime.date.today())

    print("\n\nThe top three articles are:\n")
    articles_most_popular()

    print("\n\nThe top authors are:\n")
    authors_most_popular()

    print("\n\nDays with more than 1 Percent errors:\n")
    request_high_percent_errors()

    print("\n\n")


if __name__ == '__main__':
    build_report()
