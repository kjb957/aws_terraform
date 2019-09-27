from flask import Flask, request, jsonify
import mysql.connector as sql
import time
import random
#import functools
application = Flask(__name__)

# Use in Python 3
#@functools.lru_cache(maxsize=128)

# Use the following in Python 2.7
def cache_ttl(ttl=0):
    def memoize_ttl_decorator(func):
        cache = dict()
        def memoized_func(*args):
            dt_now = datetime.now()
            if args in cache and cache[args][1] > dt_now:
                return cache[args][0]
            result = func(*args)
            cache[args] = [result, dt_now + timedelta(seconds=ttl)]
            return result
        return memoized_func
    return memoize_ttl_decorator

@cache_ttl(30)
def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])


@application.route('/hardware/')
def hardware():

    con = sql.connect(host="terraform-20190923125030142600000001.cyjqkacibnoo.us-east-1.rds.amazonaws.com", 
        user="admin", passwd="My_db_Password",
        database="hardwareavailability")

    c = con.cursor()
    c.execute('SELECT * from hardware')

    statuses = [
        {
            'provider': row[1],
            'name': row[2],
            'availability': slow_process_to_calculate_availability(
                row[1],
                row[2]
            ),
        }
        for row in c.fetchall()
    ]
    con.close()
    return jsonify(statuses)

if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5001)
