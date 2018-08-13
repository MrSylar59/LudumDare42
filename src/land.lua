local Land = {}
Land.TILESIZE = 32

Land.textures = {}
Land.textures.tex = love.graphics.newImage("res/img/land/terrains.png")
Land.textures.texW = Land.textures.tex:getWidth()
Land.textures.texH = Land.textures.tex:getHeight()

Land.waterFrame = 1

Land.textures.earth = {}
Land.textures.earth[1] = love.graphics.newQuad(0, 0, 32, 32, Land.textures.texW, Land.textures.texH)
Land.textures.earth[2] = love.graphics.newQuad(32*4, 0, 32, 32, Land.textures.texW, Land.textures.texH)
Land.textures.earth[3] = {
    love.graphics.newQuad(32, 0, 32, 32, Land.textures.texW, Land.textures.texH),
    love.graphics.newQuad(32*2, 0, 32, 32, Land.textures.texW, Land.textures.texH)
}
Land.textures.earth[4] = love.graphics.newQuad(32*3, 0, 32, 32, Land.textures.texW, Land.textures.texH)

Land.textures.desert = {}
Land.textures.desert[1] = love.graphics.newQuad(0, 32, 32, 32, Land.textures.texW, Land.textures.texH)
Land.textures.desert[2] = Land.textures.earth[2]
Land.textures.desert[3] = {
    love.graphics.newQuad(32, 32, 32, 32, Land.textures.texW, Land.textures.texH),
    love.graphics.newQuad(32*2, 32, 32, 32, Land.textures.texW, Land.textures.texH)
}
Land.textures.desert[4] = love.graphics.newQuad(32*3, 32, 32, 32, Land.textures.texW, Land.textures.texH)

Land.textures.lava = {}
Land.textures.lava[1] = love.graphics.newQuad(0, 32*2, 32, 32, Land.textures.texW, Land.textures.texH)
Land.textures.lava[2] = Land.textures.earth[2]
Land.textures.lava[3] = {
    love.graphics.newQuad(32, 32*2, 32, 32, Land.textures.texW, Land.textures.texH),
    love.graphics.newQuad(32*2, 32*2, 32, 32, Land.textures.texW, Land.textures.texH)
}
Land.textures.lava[4] = love.graphics.newQuad(32*3, 32*2, 32, 32, Land.textures.texW, Land.textures.texH)

Land.textures.ice = {}
Land.textures.ice[1] = love.graphics.newQuad(0, 32*3, 32, 32, Land.textures.texW, Land.textures.texH)
Land.textures.ice[2] = Land.textures.earth[2]
Land.textures.ice[3] = {
    love.graphics.newQuad(32, 32*3, 32, 32, Land.textures.texW, Land.textures.texH),
    love.graphics.newQuad(32*2, 32*3, 32, 32, Land.textures.texW, Land.textures.texH)
}
Land.textures.ice[4] = love.graphics.newQuad(32*3, 32*3, 32, 32, Land.textures.texW, Land.textures.texH)

Land.textures.objs = love.graphics.newImage("res/img/land/objects.png")
Land.textures.objsW = Land.textures.objs:getWidth()
Land.textures.objsH = Land.textures.objs:getHeight()
Land.textures.obj = {
    love.graphics.newQuad(0, 0, 32, 32, Land.textures.objsW, Land.textures.objsH),
    love.graphics.newQuad(32, 0, 32, 32, Land.textures.objsW, Land.textures.objsH)
}

Land.map = {}
Land.map.terrain = {}
Land.map.objects = {}

Land.ship = {}
Land.ship.img = love.graphics.newImage("res/img/land/ship.png")
Land.ship.x = 1
Land.ship.y = 1

function isWalkable(id)
    if id == 2 or id == 3 then return false
    else return true end
end

function Land.generate(pSize, pType)
    Land.type = pType

    if pSize == "small" then 
        Land.map.w = math.floor(math.prandom(8, 12))
        Land.map.h = math.floor(math.prandom(8, 12))
    elseif pSize == "medium" then
        Land.map.w = math.floor(math.prandom(12, 15))
        Land.map.h = math.floor(math.prandom(12, 15))
    else
        Land.map.w = math.floor(math.prandom(15, 25))
        Land.map.h = math.floor(math.prandom(15, 18))
    end

    for x=1,Land.map.w do 
        Land.map.terrain[x] = {}
        Land.map.objects[x] = {}
        for y=1,Land.map.h do 
            -- Map generation
            local p = love.math.noise(x+math.random(1,5), y+math.random(1,5))
            if p < 0.9 then
                local rnd = love.math.noise(x*y+math.random(1,5), y+x+math.random(1,5))
                if rnd < 0.2 then
                    Land.map.terrain[x][y] = 4
                else
                    Land.map.terrain[x][y] = 1
                end
            else
                Land.map.terrain[x][y] = 3
            end

            -- Objects generation
            if Land.map.terrain[x][y] ~= 3 then
                local r = math.prandom(0, 1)
                if r > 0.9 then 
                    local r2 = math.random(1, 2)
                    if r2 == 1 then
                        Land.map.objects[x][y] = 1
                    else
                        Land.map.objects[x][y] = 2
                    end
                else
                    Land.map.objects[x][y] = 0
                end
            else
                Land.map.objects[x][y] = 0
            end
        end
    end
end

function Land.setShipPos(pX, pY) 
    Land.ship.x = pX
    Land.ship.y = pY

    Land.map.objects[pX][pY] = 0
end

function Land.getShipPos()
    return Land.ship.x, Land.ship.y
end

function Land.update(dt)
    Land.waterFrame = Land.waterFrame + 1.5 * dt
    if Land.waterFrame >= 3 then 
        Land.waterFrame = 1
    end
end

function Land.draw(w, h)
    for x=1,Land.map.w do 
        for y=1,Land.map.h do 
            local id = Land.map.terrain[x][y]
            local tex
            if id ~= 3 then
                tex = Land.textures[Land.type][id]
            else
                tex = Land.textures[Land.type][3][math.floor(Land.waterFrame)]
            end
            love.graphics.draw(Land.textures.tex, tex, (x-1)*Land.TILESIZE, (y-1)*Land.TILESIZE)

            id = Land.map.objects[x][y]
            local tex = Land.textures.obj[id]
            if id ~= 0 then
                love.graphics.draw(Land.textures.objs, tex, (x-1)*Land.TILESIZE, (y-1)*Land.TILESIZE)
            end
        end
    end

    love.graphics.draw(Land.ship.img, (Land.ship.x-1.4)*Land.TILESIZE, (Land.ship.y-1.4)*Land.TILESIZE, 0, 1/3+0.2, 1/3+0.2)
end

return Land 