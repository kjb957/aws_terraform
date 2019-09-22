from flask import Flask, request, jsonify
import mysql.connector as sql
import time
import random
application = Flask(__name__)


def slow_process_to_calculate_availability(provider, name):
    time.sleep(0.1)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])


@application.route('/hardware/')
def hardware():
    
    #return jsonify([{'provider': 'NA', 'name': 'NA', 'availability': 'NA'}])
    return jsonify([{"availability":"MEDIUM","name":"c5","provider":"Amazing"},{"availability":"LOW","name":"H16mr","provider":"Azure"}])
    con = sql.connect(host="localhost", 
        user="mysql-user", passwd="sc00t5r",
        database="hardwaredb")

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
