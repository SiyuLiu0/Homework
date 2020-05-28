from flask import Flask, render_template, request
import dbs

app = Flask(__name__)

@app.route('/')
def index():
	return render_template('home.html')

@app.route('/handle_data', methods=['POST'])
def handle_data():
    user = request.form['user']
    psw = request.form['psw']
    if dbs.checkUser(user):
    	if dbs.checkPassword(user, psw):
    		return "LOGIN SUCCESS!"
    	else:
    		return "Wrong password!"
    else:
    	return "User not found!"


    


if __name__ == '__main__':
	app.run(debug=True)