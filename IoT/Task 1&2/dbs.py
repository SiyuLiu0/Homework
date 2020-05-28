import mysql.connector

def update(msg):
	mydb = connect_to_dbs()
	mycursor = mydb.cursor()
	num = getNum()
	sql = "INSERT INTO comments (commentid, comment) VALUES (%s,%s)"
	val = (num+1, msg)
	mycursor.execute(sql, val)
	mydb.commit()

	mydb.close()

def connect_to_dbs():
	mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="1442387087",
    database= "message"
    )
	return mydb

def getNum():
	mydb = connect_to_dbs()
	mycursor = mydb.cursor()
	mycursor.execute("SELECT * FROM comments")
	num = len(mycursor.fetchall())
	mydb.close()
	return num

def showDatabase():
	mydb = connect_to_dbs()
	mycursor = mydb.cursor()
	mycursor.execute("SELECT * FROM comments")
	for x in mycursor.fetchall():
		print str(x[0]) + "  " + str(x[1])
	mydb.close()



