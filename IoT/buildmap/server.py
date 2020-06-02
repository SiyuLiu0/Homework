from flask import Flask, render_template, request
import datetime
import dbs


app = Flask(__name__)

@app.route('/')
def index():
	return render_template('home.html')

@app.route('/map')
def gotoMap():
    return render_template('map.html')


@app.route('/get_data', methods=['POST'])
def get_data():
    time = datetime.datetime.now()
    location = request.form["location"]
    coordinates = location.split(" ")
    lat = coordinates[0]
    lng = coordinates[1]
    # print time
    # print lat
    # print lng
    dbs.update(time, lat, lng)
    return "lat : " + location
    # data = request.form.get('lat')
    # print data


if __name__ == '__main__':
	app.run(debug=True)