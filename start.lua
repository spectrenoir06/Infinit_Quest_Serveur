   
	------------- LIB ----------------
	require "/lib/json/json"
	require "/fonction/data" 
	require "/fonction/Serveur"
	socket = require "socket"
	require "enet"
	
	server = serveur_new("*",12345,0.05)

while 1 do
	server:update()
end