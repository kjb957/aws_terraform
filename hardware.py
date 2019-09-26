from flask import Flask, request, jsonify
import mysql.connector as sql
import time
import random
#import functools
application = Flask(__name__)

# Use in Python 3
#@functools.lru_cache(maxsize=128)

# Use the following in Python 2.7
def memoize(func):
    cache = dict()

    def memoized_func(*args):
        if args in cache:
            return cache[args]
        result = func(*args)
        cache[args] = result
        return result

    return memoized_func

@memoize
def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])


@application.route('/hardware/')
def hardware():
    
    #return jsonify([{'provider': 'NA', 'name': 'NA', 'availability': 'NA'}])
    #return jsonify([{"availability":"MEDIUM","name":"c5","provider":"Amazing"},{"availability":"LOW","name":"H16mr","provider":"Azure"}])
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
