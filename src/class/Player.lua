local Player = {}
Player.__index = Player

function Player.new(data)
	
	local a = {}
	setmetatable(a, Player)
    
      a.name	= data.name or "no name"
      a.skin	= data.skin or math.random(0, 7)
      a.posX	= data.posX or 640
      a.posY	= data.posY or 640
      a.dir		= data.dir or 1
      a.map		= data.map or 1
    
    return a
end

function Player:getinfo()
	return {
		name	= self.name,
		skin	= self.skin,
		map 	= self.map,
		posX 	= self.posX,
		posY 	= self.posY,
		dir 	= self.dir
		}
end

function Player:setinfo(data)
	self.posX	= data.posX or self.posX
	self.posY	= data.posY or self.posY
	self.dir	= data.dir 	or self.dir
	self.map	= data.map 	or self.map
end

return Player