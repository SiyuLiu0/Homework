import mysql.connector

def update(time, lat, lng):
	mydb = connect_to_dbs()
	mycursor = mydb.cursor()
	num = getNum()
	sql = "INSERT INTO locations (locationId, time, lat, lng) VALUES (%s,%s,%s,%s)"
	val = (num+1, time, lat, lng)
	mycursor.execute(sql, val)
	mydb.commit()

	mydb.close()

def connect_to_dbs():
	mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="1442387087",
    database= "map"
    )
	return mydb

def getNum():
	mydb = connect_to_dbs()
	mycursor = mydb.cursor()
	mycursor.execute("SELECT * FROM locations")
	num = len(mycursor.fetchall())
	mydb.close()
	return num


