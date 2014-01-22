local button = {}
button.__index = button

function button_new(x,y,image)

    local a={}
    a["image"]=love.graphics.newImage(image)
    a["x"]=x
    a["y"]=y
    a["LX"]=a.image:getWidth()
    a["LY"]=a.image:getHeight()
    a["x2"]=x+a.image:getWidth()
    a["y2"]=y+a.image:getHeight()
    return setmetatable(a, button)
    
end

local keypad = {}
keypad.__index = keypad

function keypad_new(x,y,image)

    local a={}
    a["image"]=love.graphics.newImage(image)
    a["x"]=x
    a["y"]=y
    a.reso = a.image:getWidth()/3
    a["LX"]=a.image:getWidth()
    a["LY"]=a.image:getHeight()
    a["x2"]=x+a.image:getWidth()
    a["y2"]=y+a.image:getHeight()
    return setmetatable(a, keypad)
    
end

local inv = {}
inv.__index = inv

function inv_new(x,y,image)

    local a={}
    a["image"]=love.graphics.newImage(image)
    a["x"]=x
    a["y"]=y
    a["LX"]=a.image:getWidth()
    a["LY"]=a.image:getHeight()
    a["x2"]=x+a.image:getWidth()
    a["y2"]=y+a.image:getHeight()
    return setmetatable(a, inv)
    
end

function keypad:draw()
    love.graphics.draw( self.image, self.x, self.y)
end

function button:draw()
    love.graphics.draw( self.image, self.x, self.y)
end

function button:update()
    self.x2=self.x+self.image:getWidth()
    self.y2=self.y+self.image:getHeight()
end

function inv:draw(perso)
    love.graphics.print("V",self.x+(perso.slot-1)*resolution+15,self.y-20)
    love.graphics.draw(self.image, self.x-resolution/8, self.y-resolution/8)
    for i=0,8 do
        if perso:getslotid(i+1)~= 0 then
            inventaire:draw(self.x+i*resolution,self.y,perso:getslotid(i+1))
            love.graphics.print(perso:getslotnb(i+1),self.x+i*resolution,self.y+15)
        end
        --love.graphics.rectangle("line", x+i*32,y,32,32)
    end
end

function button:isPress(cursorX,cursorY,button)

    if cursorX > self.x and cursorX < self.x2 and cursorY > self.y and cursorY < self.y2 and button then
        return true
    else
        return false
    end
    
end

function keypad:get(x,y,button)

    if x > self.x+self.reso and x < self.x+self.reso*2 and y > self.y and y < self.y+self.reso and button then
        return 1
    elseif x > self.x+self.reso and x < self.x+self.reso*2 and y > self.y+self.reso and y < self.y+self.reso*2 and button then
        return 2
    elseif x > self.x and x < self.x+self.reso and y > self.y+self.reso and y < self.y+self.reso*2 and button then
        return 3
    elseif x > self.x+self.reso*2 and x < self.x+self.reso*3 and y > self.y+self.reso and y < self.y+self.reso*2 and button then
        return 4
    else
        return 0
    end
    
end
    
    
function inv:get(x,y,button)
    for i=0,8 do
        if x > self.x+(i*resolution) and x < self.x+(i*resolution)+resolution and y > self.y and y < self.y+resolution and button then
            return i+1
        end
    end
end