from flask import Flask, render_template, request, url_for

app = Flask(__name__)

@app.route('/')
def index():
	return render_template('home.html')

@app.route('/map', methods=['GET','POST'])
def gotoMap():
    return render_template('map.html')

if __name__ == '__main__':
	app.run(debug=True)