function loadmaps()
    for k,v in pairs(data.map) do
        v.map = map_new(v.fichier,v.texture,v.music)
		v.map:createMapCol()
    end
end

require "/lib/spectre/sprite"

local map = {}
map.__index = map


function map_read(tab,nb)
    local carte={}
    for i=1,tab.width do
        carte[i]={}
    end
    for y=1, tab.height do
        for x=1, tab.width do
            carte[x][y] = tab.layers[nb].data[((y-1)*tab.width)+(x)]-1
        end
    end
    return carte
    
    
end
    
function map_new(fichier,texture,music) --créer une map
    local a={}
    a["fichier"] = fichier
	print(fichier)
    a["json"] = json.decode(love.filesystem.read( fichier, nil ))
    a["map_sol"]=map_read(a.json,1)
    a["map_block"]=map_read(a.json,2)
	a["map_deco"]=map_read(a.json,3)
    a["LX"]=a.json.width
    a["LY"]=a.json.height
    a["tileLX"]=resolution
    a["tileLY"]=resolution
    a["tileset"]=love.graphics.newImage("/textures/"..resolution.."/"..texture)
    a["tilesetLX"]=a.tileset:getWidth()
    a["tilesetLY"]=a.tileset:getHeight()
    a["music"]=music
    a.tile={}
    for y=0,(a.tilesetLY/a.tileLY)-1 do
        for x=0,(a.tilesetLX/a.tileLX)-1 do
            a.tile[x+(y*a.tilesetLX/a.tileLX)] = love.graphics.newQuad(x*a.tileLX,y*a.tileLY, a.tileLX, a.tileLY ,a.tilesetLX, a.tilesetLY)
        end
    end
    a["spriteBatch_sol"] = love.graphics.newSpriteBatch( a.tileset, a.LX*a.LY )
    a.spriteBatch_sol:clear()
    a["spriteBatch_block"] = love.graphics.newSpriteBatch( a.tileset, a.LX*a.LY )
    a.spriteBatch_block:clear()
	a["spriteBatch_deco"] = love.graphics.newSpriteBatch( a.tileset, a.LX*a.LY )
    a.spriteBatch_deco:clear()
    
    for x=0,(a.LX)-1 do
        for y=0,(a.LY)-1 do
            local id = a.map_sol[x+1][y+1]
            a.spriteBatch_sol:add(a.tile[id], x*a.tileLX, y*a.tileLY)
        end
    end
    for x=0,(a.LX)-1 do
        for y=0,(a.LY)-1 do
            local id = a.map_block[x+1][y+1]
            if id<0 then
                error("ID inferieur a 0 : "..fichier.." ; x="..(x).." ; y="..(y).." ; id = "..id)
            end
            a.spriteBatch_block:add(a.tile[id], x*a.tileLX, y*a.tileLY)
        end
    end
	for x=0,(a.LX)-1 do
        for y=0,(a.LY)-1 do
            local id = a.map_deco[x+1][y+1]
            if id<0 then
                error("ID inferieur a 0 : "..fichier.." ; x="..(x).." ; y="..(y).." ; id = "..id)
            end
            a.spriteBatch_deco:add(a.tile[id], x*a.tileLX, y*a.tileLY)
        end
    end
	
   -- for k,v in pairs(a.tab.layers[4]) do
	--	print(k,v)
	--end
	
    a.data = a.json.layers[4].objects
    a["pnj"] = {}
    a["obj"] = {}
    
    for k,v in ipairs(a.data) do
        if v.type=="pnj" then
            table.insert(a.pnj,{ data = data.pnj[tonumber(v.properties.id)] , x=v.x/64 , y=v.y/64 } )
        elseif v.type=="obj" then
            table.insert(a.obj,{ data = data.obj[tonumber(v.properties.id)] , x=v.x/64 , y=v.y/64 } )
        end
    end
    
    for k,v in ipairs(a.pnj) do
        v.sprite = sprite_new("textures/"..resolution.."/"..v.data.skin,resolution,resolution)
    end

    return setmetatable(a, map)
end
    
    
    
function map:update(nb)
    if nb then
        if nb==1 then
            self.spriteBatch_sol:clear()
            for x=0,(self.LX)-1 do
                for y=0,(self.LY)-1 do
                    local id = self.map_sol[x+1][y+1]
                    self.spriteBatch_sol:addq(self.tile[id], x*self.tileLX, y*self.tileLY)
                end
            end
        elseif nb==2 then
            self.spriteBatch_block:clear()
            for x=0,(self.LX)-1 do
                for y=0,(self.LY)-1 do
                    local id = self.map_block[x+1][y+1]
                    self.spriteBatch_block:addq(self.tile[id], x*self.tileLX, y*self.tileLY)
                end
            end
        end
    else
        self.spriteBatch_sol:clear()
        self.spriteBatch_block:clear()
        
        for x=0,(self.LX)-1 do
            for y=0,(self.LY)-1 do
                local id = self.map_sol[x+1][y+1]
                self.spriteBatch_sol:addq(self.tile[id], x*self.tileLX, y*self.tileLY)
            end
        end
        for x=0,(self.LX)-1 do
            for y=0,(self.LY)-1 do
                local id = self.map_block[x+1][y+1]
                self.spriteBatch_block:addq(self.tile[id], x*self.tileLX, y*self.tileLY)
            end
        end
    end
end

function map:draw(x,y)
    love.graphics.draw(self.spriteBatch_sol,math.floor(x),math.floor(y))
    love.graphics.draw(self.spriteBatch_block,math.floor(x),math.floor(y))
    
    for k,v in ipairs(self.pnj) do
        v.sprite:drawframe((v.x*resolution),(v.y*resolution),1)
    end
	
	-- for x=1,self.LX do
		-- for y=1,self.LY do
			-- --print(self.map_col[x][y])
			-- love.graphics.print(self.map_col[y][x],(x-1)*64+32,(y-1)*64+32)
			-- --love.graphics.rectangle( "line", (x)*64, (y)*64, 64, 64 )
		-- end
	-- end
	
end

function map:drawdeco(x,y)
    love.graphics.draw(self.spriteBatch_deco,math.floor(x),math.floor(y))
end

function map:gettile(x,y)
    if x<0 or y<0 or x>=self.LX or y>=self.LY then
        return nil
    else
        return self.map_sol[x+1][y+1],self.map_block[x+1][y+1]
    end
end

function map:settile(x,y,id,map)
    if map then
        if map==1 then
            self.map_sol[x+1][y+1]=id
            self:update(1)
        elseif map==2 then
            self.map_block[x+1][y+1]=id
            self:update(2)
        end
    else
        self.map_block[x+1][y+1]=id
        self:update(2)
    end
end

function map:reload()
    self.map_sol=nil
    self.map_block=nil
    self.map_sol=map_read(map_sol.file)
    self.map_block=map_read(map.file)
    self:update() 
end

------------------

function map:getLX()
    return self.LX
end

function map:getLY()
    return self.LY
end

function map:setmap(nb)
    map = data.map[nb]["map"]
end

function map:getmap()
    return map.nb
end


------PNJ------

function map:getPnj(tileX,tileY)
    if tileX<0 or tileY<0 or tileX>=self.LX or tileY>=self.LY then
        return nil
    else
        for k,v in ipairs(self.pnj) do
            if v.x==tileX and v.y==tileY then
                return v
            end
        end
    end
end

-----Obj-----

function map:getObj(tileX,tileY)
    if tileX<0 or tileY<0 or tileX>=self.LX or tileY>=self.LY then
        return false
    else
        for k,v in ipairs(self.obj) do
            if v.x==tileX and v.y==tileY then
                return v
            end
        end
    end
end

function map:scancol(tilex,tiley) -- return true si colision
	local block = self:getblock(tilex,tiley)
	local blockDataSol = data.tab[block.idsol]
	local blockDataBlock = data.tab[block.idblock]
	if block.idblock==nil or block.idsol==nil then
		return false
	else
		return not blockDataSol.pass or not blockDataBlock.pass or block.pnj
	end
end

function map:getblock(tilex,tiley)

        local idsol, idblock, iddeco = self:gettile(tilex,tiley)
        local pnj = self:getPnj(tilex,tiley)
        local obj = self:getObj(tilex,tiley)
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

function map:createMapCol()

	self.map_col = {}
	for y=0,self.LY-1 do
		self.map_col[y] = {}
		for x=0,self.LX-1 do
			if self:scancol(x,y) then
				self.map_col[y][x] = 1 
			else
				self.map_col[y][x] = 0
			end
		end
	end
	
	self.grid = Grid(self.map_col)
	self.pathfinder = Pathfinder(self.grid, 'JPS',0)
	self.pathfinder:setMode('ORTHOGONAL')
	self.pathfinder:setHeuristic('CARDINTCARD')
	
end


