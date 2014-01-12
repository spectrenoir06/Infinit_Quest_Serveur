require "/lib/spectre/sprite"

perso = {}
perso.__index = perso

function perso_new(fichier,x,y,map)


    local a={}
	if map then
		a.globalPosX= (data.map[map].X + x) *64
		a.globalPosY= (data.map[map].Y + x) *64
	else
		a.globalPosX= 110 * resolution
		a.globalPosY= 10 * resolution
    end
	a.LX = 64
    a.LY = 64
	
	for k,v in ipairs(data.map) do
		if (v.X<(a.globalPosX/resolution)) and (v.Y<(a.globalPosX/resolution)) then -- 
			if ((a.globalPosX-v.X*resolution) < v.map.LX*resolution) and ((a.globalPosY-v.Y*resolution) < v.map.LY*resolution) then
				a.map = data.map[k]
				a.posX = a.globalPosX - v.X * resolution
				a.posY = a.globalPosY - v.Y * resolution
				a.mapnb = k
				break
			end
		end
	end
	
    a.texture = fichier
    a.sprite = sprite_new(fichier,a.LX,a.LY)
    a.vie = 100
	
	a.sprite:addAnimation({9,10,11})
    a.sprite:addAnimation({0,1,2})
    a.sprite:addAnimation({3,4,5})
    a.sprite:addAnimation({6,7,8})

    a.speed = 4 * resolution
    a.direction = 1
    a.dx = 0
    a.dy =0
	--print("posX",a.posX)
	--print("posY",a.posY)
	a.X1 = a.posX - a.LX/2
	a.Y1 = a.posY - a.LY/2
	a.X2 = a.posX + a.LX/2
	a.Y2 = a.posY + a.LY/2
    
    
    a.inv={}
    for i=1,9 do
        a.inv["slot"..i]={}
        a.inv["slot"..i]["id"]=0
        a.inv["slot"..i]["nb"]=1
    end
    a["slot"]=1

    return setmetatable(a, perso)
    
end

function perso:getmap()
    return self.map.map
end

function perso:getmapnb()
    return self.mapnb
end

function perso:setmap(map)
    self.map = data.map[map]
	self.mapnb = map
end


function perso:update(dt)
	self:updatePos()
    self.sprite:update(dt)
	
	--self:isOn()

	-- if key_a == 1 then
		-- self:use()
	-- end
	
	local grid = resolution/2

	-- if old ~= (self.X1 % grid /grid) then
		--print(self.X1 % grid /grid)
	-- end
	--old = self.X1 % grid /grid
	
	
	
	if self.dx~=0 or self.dy ~=0 then -- si mouvement
		self.sprite:play()
		if self.dx~=0 and (self.Y1 % (grid))~=0 then --si mouvement sur X mais Y pas sur le grid
			--print(self.posY % grid /grid)
			if ((self.Y1 % (grid)/grid)<=0.5) then -- realignement en -y
				if (((self.Y1 - dt*self.speed)%grid)/grid)>0.5 then
					self:setY1(math.floor(self.Y1/grid)*grid)
				else
					self:setY1(self.Y1 -(dt*self.speed))
				end
			else
				if (((self.Y1 +(dt*self.speed))%grid)<0.5) then --realignement en +y
					self:setY1(math.ceil(self.Y1/grid)*grid)
				else
					self:setY1(self.Y1 +(dt*self.speed))
				end
			end
		elseif self.dy~=0 and (self.X1 % (grid))~=0 then --si mouvement sur Y mais X pas sur le grid
			--print(self.X1 % grid /grid)
			if ((self.X1 % (grid)/grid)<=0.5) then
				if (((self.X1 - dt*self.speed)%grid)/grid)>0.5 then -- realignement en -x
					self:setX1(math.floor(self.X1/grid)*grid)
				else
					self:setX1(self.X1 -(dt*self.speed))
				end
			else
				if (((self.X1 +(dt*self.speed))%grid)<0.5) then -- realignement en +y
					self:setX1(math.ceil(self.X1/grid)*grid)
				else
					self:setX1(self.X1 +(dt*self.speed))
				end
			end
		elseif not self:colision(dt) then -- si aligner sur l'axe perpendiculaire au mouvement ( si +x alors y%grid = 0 ) et pas de colision
			self:setX1( self.X1 +(dt*self.dx*self.speed) ) -- mouvement sur X
			self:setY1( self.Y1 +(dt*self.dy*self.speed) ) -- mouvement sur Y
			--self.sprite:play()
		else
			if self.dx<0 then
				self:setX1(math.ceil((self.X1 +(dt*self.dx*self.speed))/resolution)*resolution) -- si colision en -x position arrondie au tile a gauche
			elseif self.dx>0 then
				self:setX1(math.floor((self.X1 +(dt*self.dx*self.speed))/resolution)*resolution) -- si colision en + position arrondie au tile e droite 
			end
			if self.dy<0 then
				self:setY1(math.ceil((self.Y1 +(dt*self.dy*self.speed))/resolution)*resolution) -- si colision en -y position arrondie au tile au dessus
				-- print(math.ceil(self.posY +(dt*self.dy*self.speed)/64))
			elseif self.dy>0 then
				self:setY1(math.floor((self.Y1 +(dt*self.dy*self.speed))/resolution)*resolution) -- si colision en +y position arrondie au tile au dessous
			end
			--print("stop")
		end
	else
		self.sprite:stop()
    end
	self:updatePos()
	self.dy = 0
	self.dx = 0
	
	if (self.posX < 0) or (self.posX>self.map.map.LX*resolution) then -- si perso sort de la map local
		print("------------------")
		print("globalPosX"..self.globalPosX)
		print("globalPosY"..self.globalPosY)
		print(""                )
		print("scan map:")
		for k,v in ipairs(data.map) do
			print("map "..k)
			print(" X = "..v.X)
			print(" Y = "..v.Y)
			print(" LX = "..v.map.LX)
			print(" LY = "..v.map.LY)
			if (v.X<(self.globalPosX/resolution)) and (v.Y<(self.globalPosX/resolution)) then
				if ((self.globalPosX-v.X*resolution) < v.map.LX*resolution) and ((self.globalPosY-v.Y*resolution) < v.map.LY*resolution) then
					print("------------------")
					print("= goto map "..k)
					print("------------------")
					self.map = data.map[k]
					self:setPosX(self.globalPosX - v.X * resolution)
					self:setPosY(self.globalPosY - v.Y * resolution)
					self.mapnb = k
					--udp:send(json.encode( { cmd = "map_update" ,id = id , x1=self.X1 , y1=self.Y1 ,dir=self.direction , map = k } ))
					break
				end
			end
		end
	end
	self:updatePos()
	
end

-------------------------------------------------------------------------------------------------------------------------------
function perso:draw()
    self.sprite:draw(math.floor(self:getX()-32),math.floor(self:getY()-32)) 
end

function perso:setPos(tilex,tiley,dir,map)
    self:setX(tilex*resolution+(resolution/2))
    self:setY(tiley*resolution+(resolution/2))
    if dir then
        self:setdirection(dir)
    end
    --if map then
       -- self:setmap(map)
        --love.audio.stop()
        --love.audio.play(self.map.music)
   -- end
end

function perso:getX()
    return self.posX
end

function perso:getY()
    return self.posY
end

function perso:getPos()
	self:updatePos()
    return self.posX , self.posY , self.X1 ,  self.Y1 , self.X2 , self.Y2
end


function perso:setPosX(x)
	self.posX = x
	self.X1 = self.posX - self.LX/2
	self:updatePos()
end

function perso:setX1(x)
	self.X1 = x
	self:updatePos()
end

function perso:setPosY(y)
	self.posY = y
	self.Y1 = self.posY -self.LY/2
	self:updatePos()
end

function perso:setY1(y)
	self.Y1 = y
	self:updatePos()
end

function perso:updatePos()
	self.X2 = self.X1 + self.LY
	self.Y2 = self.Y1 + self.LY
	self.posX = self.X1 + (self.LX/2)
	self.posY = self.Y1 + (self.LY/2)
	self.globalPosX = self.map.X*resolution + self.posX
	self.globalPosY = self.map.Y*resolution + self.posY
end


function perso:getvie()
    return self.vie
end

function perso:changevie(dx)
    self.vie=self.vie+dx
end

function perso:setvie(x)
    self.vie=x
end

function perso:colision(dt) -- return true si perso en colision au coordoner
	return self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution))
		or self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution))
		or self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution))
		or self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution))
				
				
		-- if self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution)) then
			-- print("x1,y1=true")
			-- return true
		-- end
		-- if self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor((self.Y1+dt*self.dy*self.speed)/resolution)) then
			-- print("x2,y1=true")
			-- return true
			
		-- end
		-- if self:scancol(math.floor((self.X1+dt*self.dx*self.speed)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution)) then
			-- print("x1,y2=true")
			-- return true
		-- end
		-- if self:scancol(math.floor(((self.X2+dt*self.dx*self.speed)-1)/resolution),math.floor(((self.Y2+dt*self.dy*self.speed)-1)/resolution)) then
			-- print("x2,y2=true")
			-- print("X2="..self.X2/64 .."   Y2="..self.Y2/64)
			-- print(math.floor((self.X2+dt*self.dx*self.speed)/resolution),math.floor((self.Y2+dt*self.dy*self.speed)/resolution))
			-- return true
		-- end
end

function perso:scancol(tilex,tiley) -- return true si colision
	local block = self:getblock(tilex,tiley)
		--print(idsol,idblock)
	local blockDataSol = data.tab[block.idsol]
	local blockDataBlock = data.tab[block.idblock]
	if block.idblock==nil or block.idsol==nil then
		return false
	else
		return not blockDataSol.pass or not blockDataBlock.pass or block.pnj
	end
end

function perso:setdirection(direction)
    self.direction=direction
    self.sprite:setAnim(direction)
end

function perso:getdirection()
    return self.direction
end


function perso:getblock(tilex,tiley)

        local idsol, idblock, iddeco = self.map.map:gettile(tilex,tiley)
        local pnj = self.map.map:getPnj(tilex,tiley)
        local obj = self.map.map:getObj(tilex,tiley)
		local tab =
		{pnj=pnj,
		 idsol = idsol,
		 idblock = idblock,
		 iddeco = iddeco,
		 obj = obj,
		 pnj = pnj,
		 tilex=tilex,
		 tiley=tiley,
		}
        return tab
end
-------------------------------------------------
function perso:use()
	local posX , posY , X1 , Y1 , X2 ,Y2 = self:getPos()
	local x,y = 0,0
	
	if self:getdirection()==1 then
		x,y = math.floor(X1/resolution) , math.floor(Y1/resolution)-1
    elseif	self:getdirection()==2 then
		x,y = math.floor(X1/resolution),math.floor(Y1/resolution)+1
	elseif self:getdirection()==3 then
		x,y = math.floor(X1/resolution)-1,math.floor(Y1/resolution)
	elseif self:getdirection()==4 then
		x,y = math.floor(X1/resolution)+1,math.floor(Y1/resolution)
	end
	
	local block = self:getblock(x,y)
	
    if data.tab[block.idblock].use then
		data.tab[block.idblock].use(block.tileX,block.tiley)
	elseif data.tab[block.idsol].use then
		data.tab[block.idsol].use(block.tileX,block.tiley)
    elseif block.pnj then
		if block.pnj.data.talk then
			block.pnj.data.talk()
		end
	end
	
	--if blockdata.use then
                -- blockdata.use(x,y)
            -- elseif pnj then
                -- if pnj.data.talk then
                    -- pnj.data.talk()
                -- end
	
    -- local main = data.tab[self:getslot()]
    -- if main.type == "block" then
        -- if idblock==0 and not pnj then
            --self:place()
        -- else
            -- if blockdata.use then
                -- blockdata.use(x,y)
            -- elseif pnj then
                -- if pnj.data.talk then
                    -- pnj.data.talk()
                -- end
            -- end
        -- end
    -- elseif main.type == "item" then
        -- if blockdata.use then
                -- blockdata.use(x,y)
        -- elseif main.use then
            -- main.use(x,y)
        -- end
    -- end 
end

function perso:isOn()
    local block = self:getblock(math.floor(self:getX()/resolution),math.floor(self:getY()/resolution))
    if block.idblock  == nil then
        error("Id non valide")
    else
        blockdata = data.tab[idblock]
        if data.tab[block.idsol].isOn then
            data.tab[block.idsol].isOn(block.tilex,block.tiley)
        elseif block.obj then
            if block.obj.data.isOn then
                block.obj.data.isOn()
            end
        end
    end
end

-----------------------------------

function perso:setslot(nb)
    self.slot=nb
end

function perso:getnbslot()
    return self.slot
end


function perso:getslot(slot)
    if slot== nil then
        return self.inv["slot"..self.slot]["id"] , self.inv["slot"..self.slot]["nb"]
    else
        return self.inv["slot"..slot]["id"] , self.inv["slot"..slot]["nb"]
    end
end

function perso:getslotid(slot)
    return self.inv["slot"..slot]["id"]
end

function perso:getslotnb(slot)
    return self.inv["slot"..slot]["nb"]
end

function perso:additem(id,nb)
    fini=false
    for i=1,9 do
        Sid , Snb = self:getslot(i)
        if Sid == id then
            self.inv["slot"..i]["nb"]=Snb+nb
            fini=true
            break
        end
    end
    if fini==false then
       for i=1,9 do
            Sid , Snb = self:getslot(i)
            if Sid==0 then
                self.inv["slot"..i]["id"]=id
                self.inv["slot"..i]["nb"]=nb
                break
            end
        end
    end
end

function perso:removeitem(slot,nb)
    self.inv["slot"..slot]["nb"]=self.inv["slot"..slot]["nb"]-nb
    if self.inv["slot"..slot]["nb"]<=0 then
        self.inv["slot"..slot]["id"]=0
        self.inv["slot"..slot]["nb"]=1
    end
end

--[[function perso:drawinv(x,y,img)
    love.graphics.print("V",x+(self.slot-1)*32+15,y-15)
    love.graphics.draw(img, x-4, y-4)
    for i=0,8 do
        if self:getslotid(i+1)~= 0 then
            inventaire:draw(x+i*32,y,self:getslotid(i+1))
            love.graphics.print(self:getslotnb(i+1),x+i*32,y+15)
        end
        --love.graphics.rectangle("line", x+i*32,y,32,32)
    end
end]]

function perso:dig()
    idsol,idblock,x,y = self:getblock()
    if idblock then
        blockData = data.tab[idblock]
        if blockData.dig then
            blockData.dig(x,y)
        end
    end
end

function perso:place()
    idsol,idblock,x,y = self:getblock()
    if idblock == 0 then
        if self:getslot()~=0 then
            self.map:settile(x,y,self:getslot(),2)
            self:removeitem(self.slot,1)
            return true
        else
            return false
        end
    end
end

function perso:scanMap()
	

end

function perso:GoUp()
	self:setdirection(1)
    self.dy = -1
    self.dx = 0
end

function perso:GoDown()
	self:setdirection(2)
    self.dy = 1
    self.dx = 0
end

function perso:GoLeft()
	self:setdirection(3)
    self.dy = 0
    self.dx = -1
end

function perso:GoRight()
	self:setdirection(4)
    self.dy = 0
    self.dx = 1
end