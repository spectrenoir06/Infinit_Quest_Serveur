
------------- LIB ----------------
require "/lib/json/json"
require "/fonction/data"
Server = require "/fonction/Serveur"
require "copas"
require "json"
print("     +----------------+\n     |  Start Server  |\n     +----------------+")

if arg[1] then
  local sync = arg[1]
else
  local sync = 0.05
end

udpTest = Server.new("*",12345,0.25)

local server = assert(socket.bind("*", 100))

i	= 0
nb	= 0
cl 	= 0
function handler(skt)
	print(skt)
	skt = copas.wrap(skt)
	cl = cl +1
	while true do
		nb=nb+1
		local data = skt:receive()
		print(data)
		if data == "time" then
			print"Zboob"
			skt:send("Zboob\n")
		elseif data then
			local tab = json.decode(data)
			--print(tab.cmd)
			if tab.cmd == "login" then
				--self:login(tab.data,skt)
			elseif tab.cmd == "change_map" then
				--self:change_map(tab.data,skt)
			else
				--print("cmd inconnu : "..tab.cmd)--,peer)
			end
		else
			cl=cl-1
			break
		end
	end
  
end

copas.addserver(server, handler)


while 1 do
    --server:update()
	copas.step(0) -- rajoute client
	print("boucle : "..i..", client : "..cl..", handler : "..nb)
	udpTest:update()
	socket.sleep(0.5)
	i=i+1
end


