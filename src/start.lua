
------------- LIB ----------------
require "/lib/json/json"
require "/fonction/data"
require "/fonction/Serveur"
print("     +----------------+\n     |  Start Server  |\n     +----------------+")
server = serveur_new("*",4432,0.05)

while 1 do
    server:update()
end