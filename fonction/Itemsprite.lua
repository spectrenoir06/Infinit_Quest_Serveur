local invsprite = {}
invsprite.__index = invsprite

function invsprite_new(fichier,LX,LY)
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
    
    return setmetatable(a, invsprite)
    
end

function invsprite:draw(x,y,frame)
    love.graphics.drawq(self.img,self.frame[frame],x,y)
end
