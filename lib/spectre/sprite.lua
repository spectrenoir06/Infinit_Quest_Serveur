

local sprite = {}
sprite.__index = sprite

function sprite_new(fichier,LX,LY)
    a = {}
    a.img=love.graphics.newImage(fichier)
    a.frame={}
    a.imgX=a.img:getWidth()
    a.imgY=a.img:getHeight()
    
    for y=0,(a.imgY/LY)-1 do
            for x=0,(a.imgX/LX)-1 do
                a.frame[x+(y*(a.imgX/LX))] = love.graphics.newQuad(x*LX,y*LY,LX,LY ,a.imgX, a.imgY)
            end
    end
    a.LX=LX
    a.LY=LY
    a.anim={}
    a.delay=0.25
    
    a.animation=1
    a.speed = 1
	a.timer = 0
	a.position = 1
    a.playing = true
    a.mode=1
    
    return setmetatable(a, sprite)
    
end

function sprite:draw(x,y)
    love.graphics.draw(self.img,self.frame[self.anim[self.animation][self.position]],x,y)
end

function sprite:drawframe(x,y,frame)
    love.graphics.draw(self.img,self.frame[frame],x,y)
end

function sprite:addAnimation(Tframe)
    table.insert(self.anim, Tframe)
end

function sprite:update(dt)
    if self.playing then
        self.timer = self.timer + dt * self.speed
        if self.timer > self.delay then
            self.timer = self.timer - self.delay
            self.position = self.position + 1
            if self.position > table.getn(self.anim[self.animation]) then
                if self.mode == 1 then
                    self.position = 1
                elseif self.mode == 2 then
                    self.position = self.position - 1
                    self:stop()
                end
            end
        end
    end
end

function sprite:setAnim(nb,frame)
	self.animation = nb
    --self.timer = 0
     if frame then
         self.position = frame
    -- else
        -- self.position = 1
     end
    
end

function sprite:play()
	self.playing = true
end

function sprite:stop()
	self.playing = false
    self:set(1)
end

function sprite:reset()
	self:set(1)
end

function sprite:set(frame)
	self.position = frame
	self.timer = 0
end

function sprite:getCurrentFrame()
	return self.position
end

function sprite:setMode(mode)
	if mode == "loop" then
		self.mode = 1
	elseif mode == "once" then
		self.mode = 2
	end
end
