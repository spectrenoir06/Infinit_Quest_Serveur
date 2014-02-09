
------------- LIB ----------------
require "/lib/json/json"
require "/fonction/data"
require "/fonction/Serveur"
print("     +----------------+\n     |  Start Server  |\n     +----------------+")

if arg[1] then
  local sync = arg[1]
else
  local sync = 0.05
end

server = serveur_new("*",4432,0.25)

while 1 do
    server:update()
end