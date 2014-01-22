mob = {}
mob.__index = mob

function new_mob(x,y)

    local a={}
	
	a.X = x*64
	a.Y = y*64
	
	a.LX = 64
    a.LY = 64
	
	a.X1 = a.X - a.LX/2
	a.Y1 = a.Y - a.LY/2
	a.X2 = a.X + a.LX/2
	a.Y2 = a.Y + a.LY/2
	
    a.texture = "/textures/64/mob.png"
    a.sprite = sprite_new("/textures/64/mob.png",a.LX,a.LY)
    a.vie = 100
	a.speed = 3 * resolution
	
	a.sprite:addAnimation({9,10,11})
    a.sprite:addAnimation({0,1,2})
    a.sprite:addAnimation({3,4,5})
    a.sprite:addAnimation({6,7,8})

    a.direction = 2
	a.sprite:stop()
	--a.sprite:setAnim(2,2)
	
    a.dx = 0
    a.dy =0
	a.path = steve:getmap().pathfinder:getPath(math.floor(a.X/64), math.floor(a.Y/64), math.floor(steve:getX()/64), math.floor(steve:getY()/64))
	a.nodes = {}
	for node, count in a.path:nodes() do
		a.nodes[count]=node
	end
	--a.path

    return setmetatable(a, mob)
    
end

function mob:update(dt)
	self.sprite:update(dt)
	--print(dist(steve.posX,steve.posY,monster.X,monster.Y)/64)
	if (dist(steve.posX,steve.posY,self.X,self.Y)/64 < 20) and (dist(steve.posX,steve.posY,self.X,self.Y)/64 >0) then --and finde	then

		--print(self.nodes[2]:getX())
		if ((self.X1 ~= self.nodes[1]:getX()*64) or (self.Y1 ~= self.nodes[1]:getY()*64))  then
			self.sprite:play()
			if self.X1 < self.nodes[1]:getX()*64 then
				if self.X1+dt*self.speed > self.nodes[1]:getX()*64 then
					self:setX1(  self.nodes[1]:getX()*64)
					
				else
					self:setdirection(4)
					self:setX1( self.X1 +(dt*self.speed) )
				end
			elseif self.X1 > self.nodes[1]:getX()*64 then
				if self.X1-dt*self.speed < self.nodes[1]:getX()*64 then
					self:setX1(  self.nodes[1]:getX()*64)
				else
					self:setdirection(3)
					self:setX1( self.X1 -(dt*self.speed) )
				end
			elseif self.Y1 < self.nodes[1]:getY()*64 then
				if self.Y1+dt*self.speed > self.nodes[1]:getY()*64 then
					self:setY1(  self.nodes[1]:getY()*64 )
				else
					self:setdirection(2)
					self:setY1( self.Y1 +(dt*self.speed) )
				end
			elseif self.Y1 > self.nodes[1]:getY()*64 then
				if self.Y1-dt*self.speed < self.nodes[1]:getY()*64 then
					self:setY1(  self.nodes[1]:getY()*64  )
				else
					self:setdirection(1)
					self:setY1( self.Y1 -(dt*self.speed) )
				end
			end
		else -- si mob sur la premier case du path
			--print("node 1")
			self.path = nil
			self.path = steve:getmap().pathfinder:getPath(self.nodes[1]:getX(), self.nodes[1]:getY(), math.floor(steve:getX()/64), math.floor(steve:getY()/64))
			self.nodes = {}
			for node, count in self.path:nodes() do
				self.nodes[count]=node
			end
			if self.path:getLength() >= 1 then
				self.path = nil
				self.path = steve:getmap().pathfinder:getPath(self.nodes[2]:getX(), self.nodes[2]:getY(), math.floor(steve:getX()/64), math.floor(steve:getY()/64))
				self.nodes = {}
				for node, count in self.path:nodes() do
					self.nodes[count]=node
				end
			end
		end
	end

	self:updatePos()
	self.dy = 0
	self.dx = 0
	
end

function mob:draw()
    self.sprite:draw(math.floor(self.X1),math.floor(self.Y1)) 
end

function mob:updatePos()
	self.X2 = self.X1 + self.LY
	self.X = self.X1 + (self.LX/2)
	self.Y2 = self.Y1 + self.LY
	self.Y = self.Y1 + (self.LY/2)
end

function mob:getPos()
	return self.X,self.Y,self.X1,self.Y1,self.X2,self.Y2
end

function dist(xa,ya,xb,yb)
	return math.sqrt(math.pow(xb-xa,2)+math.pow(yb-ya,2))
end


function mob:GoUp()
	self:setdirection(1)
    self.dy = -1
    self.dx = 0
end

function mob:GoDown()
	self:setdirection(2)
    self.dy = 1
    self.dx = 0
end

function mob:GoLeft()
	self:setdirection(3)
    self.dy = 0
    self.dx = -1
end

function mob:GoRight()
	self:setdirection(4)
    self.dy = 0
    self.dx = 1
end

function mob:setdirection(d)
    self.direction=d
    self.sprite:setAnim(d)
end

function mob:Goto(x,y)
	if self.X < x*64 then
		self:GoRight()
	elseif self.X > x*64 then
		self:GoLeft()
	elseif self.Y < y*64 then
		self:GoDown()
	elseif self.Y > y*64 then
		self:GoUp()
	end
end

function mob:setPosX(x)
	self.posX = x
	self.X1 = self.posX -self.LX/2
	self:updatePos()
end

function mob:setX1(x)
	self.X1 = x
	self:updatePos()
end

function mob:setPosY(y)
	self.posY = y
	self.Y1 = self.posY -self.LY/2
	self:updatePos()
end

function mob:setY1(y)
	self.Y1 = y
	self:updatePos()
end
