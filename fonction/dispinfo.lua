function dispinfo(x,y)
    if x == nil then 
      x=0
    end
    if y == nil then
      y=0
    end
    love.graphics.draw(cache, x+0, 0)
    love.graphics.print("Fps = "..love.timer.getFPS(), x+10, y+10)
    love.graphics.print("map = "..local_clients:main():getmap().fichier, x+300, y+10)
    love.graphics.print("Perso X1 = "..local_clients:main().X1,x+10,y+30)
    love.graphics.print("Perso Y1 = "..local_clients:main().Y1,x+10,y+50)
    love.graphics.print("Perso tileX = "..local_clients:main().X1/resolution,x+300,y+30)
    love.graphics.print("Perso tileY = "..local_clients:main().Y1/resolution,x+300,y+50)
    
    love.graphics.print("Curseur x = "..cursor_x,x+10,y+70)
    love.graphics.print("Curseur y = "..cursor_y,x+10,y+90)
    love.graphics.print("Curseur x = "..math.floor(cursor_x/resolution),x+300,y+70)
    love.graphics.print("Curseur y = "..math.floor(cursor_y/resolution),x+300,y+90)
	
	love.graphics.print("global x = "..(local_clients:main().globalPosX/resolution),x+300,y+110)
    love.graphics.print("global y = "..(local_clients:main().globalPosY/resolution),x+300,y+125)
	
    
    love.graphics.print("dx = "..local_clients:main().dx,x+10,y+110)
    love.graphics.print("dy = "..local_clients:main().dy,x+10,y+120)
	
	love.graphics.print("rot = "..cam.rot.." rad",x+10,y+150)
	love.graphics.print("rot = "..(cam.rot/math.pi) * 180  .." °",x+10,y+165)
	
	--love.graphics.print("dist = "..dist(local_clients:main().posX,local_clients:main().posY,monster.X,monster.Y)/resolution,x+10,y+180)
	
    -- love.graphics.print("up = "..up,x+10,y+140)
    -- love.graphics.print("down = "..down,x+10,y+155)
    -- love.graphics.print("left = "..left,x+10,y+170)
    -- love.graphics.print("right = "..right,x+10,y+185)
    -- love.graphics.print("key_a = "..key_a,x+10,y+200)

    --if  local_clients:main():getblock() then
       -- love.graphics.print("Id Sol devant = "..local_clients:main():getblock(),x+10,y+230)
   -- end
    --if  local_clients:main():getblock(0) then
     --   love.graphics.print("Id sol au pied = "..local_clients:main():getblock(0),x+10,y+250)
   -- end
   -- if  local_clients:main():getblock() then
       -- local idsol , idblock = local_clients:main():getblock()
       -- love.graphics.print("Id block devant = "..idblock,x+150,y+230)
   -- end
    --if  local_clients:main():getblock(0) then
    --    local idsol , idblock = local_clients:main():getblock(0)
    --    love.graphics.print("Id block au pied = "..idblock,x+150,y+250)
--end 
    
    
    
    
    love.graphics.print("slot de l'inventaire = "..local_clients:main():getnbslot(),x+10,y+270)
    
    love.graphics.print("x1 = "..local_clients:main().X1,x+300,y+270)
    love.graphics.print("y1 = "..local_clients:main().Y1,x+300,y+280)
	love.graphics.print("x2 = "..local_clients:main().X2,x+300,y+295)
    love.graphics.print("y2 = "..local_clients:main().Y2,x+300,y+305)
	
    
    love.graphics.print("camera.x = "..cam.x,x+10,y+290)
    love.graphics.print("camera.y = "..cam.y,x+10,y+310)
    
end