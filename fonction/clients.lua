clients = {}
clients.__index = clients

function clients_new()
	local a = {}
	setmetatable(a, clients)
	a.tab_perso = {}
	a.id=nil
	a.sync = 0
	a.sync_dt=0.05
	return a
end

function clients:add(data)
	local new = perso_new("/textures/64/skin"..data.skin..".png",data.posX,data.posY)
	table.insert(self.tab_perso,new)
end

function clients:set_main_client(id)
	self.id = id
end

function clients:receive(data)
	--
	local tab = json.decode(data)
	if tab.cmd == "new_player" then
		print("receive : cmd="..json.decode(data).cmd)
		local nb = table.getn(tab.data)
		print(json.encode(tab.data[nb]))
		self:add(tab.data[nb])
	elseif tab.cmd == "update" then
		--print(data,msg)
		self:perso_set_info(tab)
	elseif tab.cmd then
		print(data)
	end

end

function clients:draw()
	for k,v in pairs(self.tab_perso) do
			--print(json.encode(v.sprite))
			v:draw() 				-- afficher perso
	end
end

function clients:update(dt)
	if self.sync > self.sync_dt and multi then
		local send = {	cmd = "pos_update",
						data = { id = self.id,
								 posX=self:main().posX,
								 posY=self:main().posY,
								 dir=self:main().direction,
								 map = self:main():getmapnb(),
							   }
					 }
		udp_client:send(json.encode(send))
		self.sync = 0
	end
	for k,v in pairs(self.tab_perso) do
		--print(v.posX)
		v:update(dt) -- update perso
	end
	self.sync = self.sync +dt
end

function clients:main()
	return self.tab_perso[self.id]
end

function clients:perso_set_info(tab)
	for k,v in ipairs(tab.data[1]) do
		--print(json.encode(v))
		if v.id~=self.id then
			self.tab_perso[k]:setPosX(v.posX)
			self.tab_perso[k]:setPosY(v.posY)
			self.tab_perso[k]:setdirection(v.dir)
		end
	end
end