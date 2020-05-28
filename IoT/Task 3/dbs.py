import mysql.connector

def connect_to_dbs():
	mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="1442387087",
    database= "users"
    )
	return mydb

def checkUser(user):
	mydb = connect_to_dbs()
	mycursor = mydb.cursor()
	mycursor.execute("SELECT * FROM info")
	flag = False
	for x in mycursor.fetchall():
		if str(x[0]) == user:
			flag = True
			break
	mydb.close()
	return flag

def checkPassword(user,psw):
	mydb = connect_to_dbs()
	mycursor = mydb.cursor()
	sql = "SELECT password FROM info WHERE username=%s"
	val = (user, )
	mycursor.execute(sql,val)
	password = mycursor.fetchone()
	mydb.close()
	if password[0] == psw:
		return True
	else:
		return False
    




