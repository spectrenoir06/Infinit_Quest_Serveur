
local socket = require "socket"
local Player = require "class.Player"
--enet = require "enet"

local Server = {}
Server.__index = Server

function Server.new(udpSocket)
	
	local a = {}
	setmetatable(a, Server)
	
	a.serverUdp = udpSocket
	
	a.clients 	= {}       												-- table avec les clients == ip
	a.players	= {}   													-- table avec les players des clients == posX ...

	for i=1,10 do
		a.clients[i]	= {}   											-- creation des salons client
		a.players[i]	= {}  											-- creation des salons players
	end
	return a

end

function Server:update()

	
	self:receive()

end

function Server:receive()
    
	local data, ip, port = self.serverUdp:receivefrom() 				-- reception Udp
	
    if data then
		local tab = json.decode(data)
		if tab.cmd == "pos_update" then
			self:pos_update(tab.data,Clients["udp:"..ip..":"..port])
		else
			print("cmd inconnu : "..tab.cmd,client)
		end
	end
	

end

function Server:login(data,client)
    print("Login",data.name,"tcp:"..client.ip..":"..client.tcpPort)
    client.player = Player.new(data)								-- creation du nouveau joueur coter Server
	self:join_map(1,client)
end

function Server:exit_map(client)
    print("player "..client.player.name.." exit map "..client.player.map)
	local nb
	for k,v in ipairs(self.clients[client.player.map]) do
		if v.player == client.player then

			table.remove(self.players[client.player.map],k)
			table.remove(self.clients[client.player.map],k)
			nb = k
			break
		end
	end
    self:tcp_broadcast_all_map("player_exit_map",{nb = nb},client.player.map)

    --print(#self.peer[map].." joueur(s) restant")
end

function Server:join_map(map,client)
	--print(json.encode(player))
	print("player "..client.player.name.." join map "..map)
    
	table.insert(self.players[map],client.player) 								-- ajout du nouveau perso du nouveau joueur a la liste
    
	local tab = { players = self.players[map], }						-- preparation paquet avec tout les player maps
	
	self:tcpSend("join_map",tab,client)									-- envoit paquet au new client
    self:tcp_broadcast_all_map("player_join_map",client.player:getinfo(),map)-- envoi a tout le monde les info sur le nouveau joueur
	
	table.insert(self.clients[map],client)								-- ajout du nouveau peer du nouveau joueur a la liste
	
end

function Server:change_map(data,client)

	local old_map,old_nb = self:getMapNb(client)						-- recupertation ancienne map et nb
	--print(json.encode(data))
	self:pos_update(data,client)
  
	--local map,nb = self:getMapNb(peer) 								-- recuperation nouvelle map et nb
  
	print(data.name.." change map from "..old_map.." to "..data.map)
  
	table.insert(self.players[data.map],self.players[old_map][old_nb])	-- copie du perso dans nouvelle map
  
	--print(json.encode(self.perso[data.map]))
	self:send("join_map",{players=self.players[data.map]},client)		-- envoit les players de la map d'arriver au client
	self:broadcast_all_map("player_join_map",self.players[data.map][#self.players[data.map]]:getinfo(),data.map) -- previent tout les client de la nouvelle map de l'arriver du nouveau
  
	table.insert(self.clients[data.map],client)							-- rajout du peer du nouveau dans la map d'arriver
	table.remove(self.players[old_map],old_nb) 							-- supression du perso de l'anciene map
	table.remove(self.clients[old_map],old_nb)  						-- supression du peer de l'ancienne map
	self:broadcast_all_map("player_exit_map",{nb = old_nb},old_map) 	-- informe les clients du depart de leur pote  
  
	for i=1,3 do
		print("players map "..i.." = "..#self.players[i])
	end
end

function Server:disconnect(client)
  print(client.player.name,"disconnect")
  self:exit_map(client)
end


function Server:tcpSend(cmd,data,client)
	print(cmd,"tcp:"..client.ip..":"..client.tcpPort)
    client.skt:send(json.encode({cmd = cmd , data = data}).."\n")
end

function Server:udpSend(cmd,data,client)
	--print(cmd,"udp:"..client.ip..":"..client.udpPort)
    self.serverUdp:sendto(json.encode({cmd = cmd , data = data}),client.ip,client.udpPort)
end

function Server:tcp_broadcast_all_map(cmd,data,map)
    for k,v in ipairs(self.clients[map]) do
		self:tcpSend(cmd,data,v)
    end
end

function Server:udp_broadcast_all_map(cmd,data,map)
    for k,v in ipairs(self.clients[map]) do
        self:udpSend(cmd,data,v)
    end
end

function Server:send_update()
  for k,v in ipairs(self.players) do
    self:udp_broadcast_all_map("update_players_pos",v,k)
  end
end

function Server:getNb(client,map)
  for k,v in ipairs(self.clients[map]) do
    if (client.ip == v.ip) and (client.port == v.port) then
      return k
    end 
  end
  return false
end

function Server:getMapNb(client)
  for k,v in ipairs(self.clients) do
    local n = self:getNb(client,k)
    if n then
      return k,n -- k==map , n==index
    end 
  end
  return false
end

function Server:pos_update(data,client)
  client.player:setinfo(data)  
end

return Server
