
local socket = require "socket"
--enet = require "enet"

local Server = {}
Server.__index = Server

function Server.new(ip,port,sync_dt)
	
	local a = {}
	setmetatable(a, Server)
	
	a.serverUdp = assert(socket.udp())
	a.serverUdp:settimeout(0)
	a.serverUdp:setsockname('*', 12345)
	print(a.serverUdp:getsockname())

	--if not a.host then print("host == nill server already running ??") error("enet.host_create("..ip..":"..port..")",a.host) end


	a.save 	= {}  		--
	a.peer 	= {}       	-- table avec les clients
	a.perso	= {}   		-- table avec les perso des clients

	for i=1,10 do
		a.peer[i]	= {}   	-- creation des salons peer
		a.perso[i]	= {}  	-- creation des salons perso
	end
	return a

end

function Server:update()

	self.sync = socket.gettime() -- temp du debut de la frame
	local data, msg_or_ip, port_or_nil = self.serverUdp:receivefrom()

	if data then
		print(data, msg_or_ip, port_or_nil)
		self:receive(data,msg_or_ip..':'..port_or_nil)
	end
	

	-- if self.compteur > self.sync_dt then
		-- self:send_update()
		-- self.compteur = 0
	-- end

	-- self.dt = socket.gettime() - self.sync 	-- temp de la frame
	-- self.compteur = self.compteur + self.dt -- addition du temp de la frame

end

function Server:receive(data,peer)
    --print(data,peer)
    --print("receive : port="..port.." ; cmd="..json.decode(data).cmd)
    
    --local tab = json.decode(data)
    
	if pcall(function() local tab = json.decode(data) end) then
		--print("json conforme")
		if tab.cmd == "login" then
			self:login(tab.data,peer)
		elseif tab.cmd == "pos_update" then
			self:pos_update(tab.data,peer)
		elseif tab.cmd == "change_map" then
			self:change_map(tab.data,peer)
		else
			print("cmd inconnu : "..tab.cmd,peer)
		end
    else
      print("Error pas de json ", data)
	end
	

end

function Server:login(data,peer)
    print("add player",data.name,peer)
    local newplayer = player_new(data) -- creation du nouveau joueur coter Server
    self:join_map(1,newplayer,peer)
end

function Server:exit_map(map,nb)
    print("player "..self.perso[map][nb].name.." exit map "..map)
    table.remove(self.perso[map],nb)
    table.remove(self.peer[map],nb)
    self:broadcast_all_map("player_exit_map",{nb = nb},map)

    --print(#self.peer[map].." joueur(s) restant")
end

function Server:join_map(map,player,peer)
    --print(json.encode(player))
    print("player "..player.name.." join map "..map)
    
    table.insert(self.perso[map],player)  -- ajout du nouveau perso du nouveau joueur a la liste
    
    local tab = { players = self.perso[map], }
    --print(peer)
    self:send("join_map",tab,peer)
    self:broadcast_all_map("player_join_map",player:getinfo(),map) -- envoi a tout le monde les info sur le nouveau joueur
    
    table.insert(self.peer[map],peer)             --  ajout du nouveau peer du nouveau joueur a la liste
end

function Server:change_map(data,peer)

  local old_map,old_nb = self:getMapNb(peer) -- recupertation ancienne map et nb
  --print(json.encode(data))
  self:pos_update(data,peer)
  
  --local map,nb = self:getMapNb(peer) -- recuperation nouvelle map et nb
  
  print(data.name.." change map from "..old_map.." to "..data.map)
  
  table.insert(self.perso[data.map],self.perso[old_map][old_nb]) -- copie du perso dans nouvelle map
  
  --print(json.encode(self.perso[data.map]))
  self:send("join_map",{players=self.perso[data.map]},peer) -- envoit les players de la map d'arriver au client
  self:broadcast_all_map("player_join_map",self.perso[data.map][#self.perso[data.map]]:getinfo(),data.map) -- previent tout les client de la nouvelle map de l'arriver du nouveau
  
  table.insert(self.peer[data.map],peer) -- rajout du peer du nouveau dans la map d'arriver
  table.remove(self.perso[old_map],old_nb) -- supression du perso de l'anciene map
  table.remove(self.peer[old_map],old_nb)  -- supression du peer de l'ancienne map
  self:broadcast_all_map("player_exit_map",{nb = old_nb},old_map) -- informe les clients du depart de leur pote  
  
  for i=1,3 do
    print("players map "..i.." = "..#self.perso[i])
  end
end

function Server:disconnect(peer)
  local map,nb = self:getMapNb(peer)
  print(peer,"disconnect map "..map.." joueur number "..nb)
  self:exit_map(map,nb)
end

function Server:send(cmd,data,peer)
    peer:send(json.encode({cmd = cmd , data = data}))
end

function Server:broadcast_all_map(cmd,data,map)
    for k,v in ipairs(self.peer[map]) do
        self:send(cmd,data,v)
    end
end

function Server:send_update()
  for k,v in ipairs(self.perso) do
    self:broadcast_all_map("update_players_pos",v,k)
  end
end

function Server:getNb(peer,map)
  for k,v in ipairs(self.peer[map]) do
    if peer==v then
      return k
    end 
  end
  return false
end

function Server:getMapNb(peer)
  for k,v in ipairs(self.peer) do
    local n = self:getNb(peer,k)
    if n then
      return k,n -- k==map , n==index
    end 
  end
  return false
end

function Server:pos_update(data,peer)
  local map , nb = self:getMapNb(peer)
  self.perso[map][nb]:setinfo(data)  
end
------------------------------------------------------------------------------------

player = {}
player.__index = player

function player_new(data)
    local a = {}
    setmetatable(a, player)
    
      a.name=data.name or "no name"
      a.skin=math.random(0, 7)
      a.posX=data.posX or 640
      a.posY=data.posY or 640
      a.dir = data.dir or 1
      a.map=data.map or 1
    
    return a
end

function player:getinfo()
    return {
        name = self.name,
        skin = self.skin,
        map = self.map,
        posX = self.posX,
        posY = self.posY,
        dir = self.dir
        }
end

function player:setinfo(data)
    self.posX = data.posX
    self.posY = data.posY
    self.dir = data.dir
    self.map = data.map
end

return Server
