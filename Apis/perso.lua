 perso_new(fichier,LX,LY,map) -- créeation du perso

 perso:update(dt) -- mise a jour du perso

 perso:draw()	-- affichage a jour du perso

 perso:getmap()
 perso:getmapnb()
 perso:getX()
 perso:getY()
 perso:getvie()
 perso:colision(x,y) -- return true si perso en colision au coordoner
 perso:scancol(x,y) -- return true si colision
 perso:getdirection()

 perso:setmap(map)
 perso:move(dx,dy)
 perso:setPos(tilex,tiley,map,dir)
 perso:setX(x)
 perso:setY(y)
 perso:changevie(dx)
 perso:setvie(x)
 perso:setdirection(direction)
 perso:getblock(x,y)

 perso:use()
 perso:isOn()