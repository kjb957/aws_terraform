from flask import Flask, request
import requests
import socket
application = Flask(__name__)

version = 'v 1.1 '

@application.route('/')
def dashboard():

    result = requests.get('http://192.168.21.20:5001/hardware/').json()
    hardware = [
        '{} - {}: {}'.format(r['provider'], r['name'], r['availability'])
        for r in result
    ]

    return version + socket.gethostname() + '<br>' + '<br>'.join(hardware)

@application.route('/test/')
def test():
	return version + 'OK  from ' + socket.gethostname()

if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5000)