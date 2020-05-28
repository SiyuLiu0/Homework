import socket

UDP_IP_ADDRESS = "127.0.0.1"
UDP_PORT_NO = 6789

#create a socket object and connect to the server
clientSock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

print ""
message = raw_input("Enter the message you want to send to the server : ") 
#send message to the server
clientSock.sendto(message, (UDP_IP_ADDRESS, UDP_PORT_NO))
