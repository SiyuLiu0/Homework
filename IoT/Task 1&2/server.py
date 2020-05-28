import socket
import dbs

UDP_IP_ADDRESS = "127.0.0.1"
UDP_PORT_NO = 6789
# declare our serverSocket upon which
# we will be listening for UDP messages
serverSock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# we will bind our declared IP address
# and port number to our newly declared serverSock
serverSock.bind((UDP_IP_ADDRESS, UDP_PORT_NO))


print "Waiting for incoming connections..."

while True:

    data, addr = serverSock.recvfrom(1024)
    print "Message: ", data
    dbs.update(data)
    dbs.showDatabase()