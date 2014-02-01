
socket = require "socket"
enet = require "enet"

serveur = {}
serveur.__index = serveur

function serveur_new(ip,port,sync_dt)
    local a = {}
    setmetatable(a, serveur)

    a.host = enet.host_create(ip..":"..port)
    if not a.host then print("host == nill server already running ??") error("enet.host_create("..ip..":"..port..")",a.host) end
    a.sync_dt = sync_dt -- frequence de sync
    a.compteur = 0 -- initialisation du compteur
    a.dt=0 -- init de dt

    a.peer = {}         -- table avec les clients
    a.peer_perso = {}   -- table avec les perso des clients

    a.peer[1]={}        -- creation salon 1  
    a.peer_perso[1]={}  -- creation salon 1

    a.id = 1 -- init id blalala
    return a
end

function serveur:update()
    self.sync = socket.gettime() -- temp du debut de la frame
    --print("self.host",self.host)
    local event = self.host:service()

    if event then
      if event.type=="receive" then
        self:receive(event.data,event.peer)
      elseif event.type=="disconnect" then
        self:disconnect(event.peer)
      else
        print("cmd inconnu",event.type,event.peer)
      end
    end

    if self.compteur > self.sync_dt then
        --print("self:send_update()")
        self:send_update(1)
        self.compteur = 0
    end

    self.dt = socket.gettime() - self.sync -- temp de la frame
    self.compteur = self.compteur + self.dt -- addition du temp de la frame

    if self.dt > self.sync_dt then
    --print(string.format("(dt = %f) > (sync_dt = %f) ",self.dt,self.sync_dt))
    end
end

function serveur:add_client(data,peer)

    local newplayer = player_new(data.name,self.id) -- creation du nouveau joueur coter serveur
    table.insert(self.peer_perso[1],newplayer)  -- ajout du nouveau perso du nouveau joueur a la liste
    
    local tab = {id = self.id,
                 players = self.peer_perso[1], }
    
    self:send("welcome",tab,peer)
    self:broadcast_map("new_player",newplayer:getinfo(),1) -- envoi a tout le monde les info sur le nouveau joueur
    
    
    table.insert(self.peer[1],peer)             --  ajout du nouveau peer du nouveau joueur a la liste

    print("add player",data.name,peer,"id="..self.id)
    self.id = self.id +1
end

function serveur:disconnect(peer)
  for k,v in ipairs(self.peer[1]) do
    print(k,v,peer)
    if v==peer then 
      table.remove(self.peer_perso[1],k)
      table.remove(self.peer[1],k)
      self:broadcast_map("player_disconnect",{nb = k},1)
      print("delete player",k)
      return k 
    end
  end
  return false
end

function serveur:send(cmd,data,peer)
    peer:send(json.encode({cmd = cmd , data = data}))
end

function serveur:broadcast_map(cmd,data,map)
    for k,v in ipairs(self.peer[map]) do
        self:send(cmd,data,v)
    end
end

function serveur:receive(data,peer)
    --print(data,peer)
    --print("receive : port="..port.." ; cmd="..json.decode(data).cmd)
    
    local tab = json.decode(data)
    
    if tab.cmd == "connect" then
        self:add_client(tab.data,peer)
    elseif tab.cmd == "pos_update" then
        --print(json.encode(tab.data))
        self.peer_perso[tab.data.map][tab.data.nb]:setinfo(tab.data)
    else
      print("cmd inconnu : "..tab.cmd,peer)
    end
end


function serveur:get_nb()
    return table.getn(self.client)
end

function serveur:send_update(map)
    if map then
        self:broadcast_map("update_players_pos",self.peer_perso[map],map)
    else
    -- for k,zone in ipairs(self.peer) do
    -- for nb,client in ipairs(zone) do
    -- self:broadcast("update",self.perso[zone])
    -- end
    -- end
    end
end

-- function serveur:getlist()
-- local tab = {}
-- for k,zone in ipairs(self.client) do
-- for nb,client in ipairs(zone) do
-- print(json.encode(client))
-- table.insert(tab,{ 	name = self.perso[][].name,
-- ip = client.ip,
-- port = client.port,
-- map = k ,
-- id = client.perso.id,
-- posX=client.perso.posX,
-- posY=client.perso.posY
-- } )
-- end
-- end
-- return tab
-- end

function serveur:getperso(map)
    local tab = {}
    if map then
        for nb,client in ipairs(self.player_map[map]) do
            table.insert(tab,client.perso:getinfo())
        end
    else
        error("no map")
    end
    return tab
end

-----

function new_client(peer,name,id)

    local a = {}
    a.player = player_new(name,id)
    a.peer = peer

    return a
end

-----

player = {}
player.__index = player

function player_new(name,id)
    local a = {}
    setmetatable(a, player)

    a.id = id
    a.name=name
    a.skin=math.random(0, 7)
    a.posX=10*64
    a.posY=10*64
    a.dir = 1
    a.map=1

    return a
end

function player:getinfo()
    return {
        id = self.id,
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
end
