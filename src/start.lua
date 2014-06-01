
------------- LIB ----------------
require "/lib/json/json"
require "/class/data"
Server = require "/class/Serveur"
require "lib.copas"
require "lib.json.json"

local ServerIp = "*"
local ServerTcpPort = 4434
local ServerUdpPort = ServerTcpPort

if arg[1] then
	sync = tonumber(arg[1])
else
	sync = 1
end

local udpSocket = assert(socket.udp())
	  udpSocket:settimeout(0)
	  udpSocket:setsockname(ServerIp, ServerUdpPort)

server = Server.new(udpSocket)

local tcpSocket = assert(socket.bind(ServerIp, ServerTcpPort))

i		= 0
nb		= 0
cl		= 0
tick 	= 0
dt 		= 0

Clients = {}

function handler(skt)
	
	skt = copas.wrap(skt)
	
	local tcpIp, tcpPort 	= skt.socket:getpeername() 				-- recuperation ip et port socket tcp
	local udpClient 		= skt:receive()	
	local udpIp, udpPort 	= string.match(udpClient, '(.*):(%d*)')	-- recuperation ip et port socket udp
	
	local udpIp=tcpIp
	
	Clients["tcp:"..tcpIp..":"..tcpPort] = {ip = tcpIp, udpPort = udpPort, tcpPort = tcpPort, skt = skt}		-- 
	Clients["udp:"..udpIp..":"..udpPort] = Clients["tcp:"..tcpIp..":"..tcpPort]						-- Clients[udp:ip:udpPort] pointe vers Clients[udp:ip:tcpPort]
	
	local me = Clients["tcp:"..tcpIp..":"..tcpPort]
	
	print("client nb "..cl..", TPC = "..tcpIp..':'..tcpPort.." ,  UDP = "..udpClient)
		
	cl = cl +1
	while true do
		nb=nb+1
		local data, status, partial = skt:receive()
		--print(data)
			
		if data then
			local tab = json.decode(data)
				
			if tab.cmd == "login" then
				server:login(tab.data,me)
			elseif tab.cmd == "change_map" then
				--self:change_map(tab.data,skt)
			else
				print("cmd inconnu : "..tab.cmd)--,peer)
			end
		elseif status=="closed" then
			print(status.." "..tcpIp..":"..tcpPort)
			cl=cl-1
			local ip, port = skt.socket:getpeername()
			server:disconnect(me)
			Clients["tcp:"..tcpIp..':'..tcpPort] = nil
			break
		end
	end
end

copas.addserver(tcpSocket, handler)


while 1 do
    local startTime = socket.gettime()
	tick = tick + dt
	copas.step(0) -- rajoute client
	if (sync<= tick ) then
		os.execute( "clear" )
		print("\nboucle : "..i..", client : "..cl..", handler : "..nb)
		for k,v in pairs(Clients) do
			if string.sub(k,1,3) == "tcp" then
				print("tcp : "..v.ip..":"..v.tcpPort..", udp : "..v.ip..":"..v.udpPort) end
			end
		print()
		server:send_update()
		i=i+1
		tick = 0
	end
	server:update()
	dt = socket.gettime() - startTime
	if cl == 0 then socket.sleep(0.2) end
end


