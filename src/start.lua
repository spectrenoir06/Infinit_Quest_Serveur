
------------- LIB ----------------
require "/lib/json/json"
require "/fonction/data"
require "/fonction/Serveur"
print("serveur start")
server = serveur_new("*",12345,0.05)

while 1 do
    server:update()
end