local Planets = {}

Planets.textures = {}
Planets.textures["earth"] = love.graphics.newImage("res/img/space/earth.png")
Planets.textures["desert"] = love.graphics.newImage("res/img/space/desert.png")
Planets.textures["ice"] = love.graphics.newImage("res/img/space/ice.png")
Planets.textures["lava"] = love.graphics.newImage("res/img/space/lava.png")
Planets.textures["colonized"] = love.graphics.newImage("res/img/space/colonized.png")

Planets.rads = {
    small = 192,
    medium = 384,
    large = 576
}

local function getColor(planet) 
    if planet.type == "colonized" then 
        return 150/255, 150/255, 150/255, 25/255
    elseif planet.type == "lava" then
        return 255/255, 109/255, 109/255, 25/255
    elseif planet.type == "desert" then
        return 209/255, 226/255, 255/255, 25/255
    elseif planet.type == "ice" then
        return 188/255, 183/255, 255/255, 25/255
    else
        return 183/255, 255/255, 188/255, 25/255
    end
end

function Planets.init()
    for i=#Planets,1,-1 do 
        local planet = Planets[i]
        table.remove(Planets, i)
    end
end

function Planets.add(pType, pX, pY, pSize, pLand)
    local _planet = {}
    
    _planet.x = pX
    _planet.y = pY
    _planet.type = pType
    _planet.size = pSize
    _planet.r = Planets.rads[_planet.size]
    _planet.landable = pLand ~= false
    _planet.scale = _planet.r / Planets.rads["small"]

    table.insert(Planets, _planet)
end

function Planets.draw()
    for i=1,#Planets do 
        local planet = Planets[i]
        love.graphics.draw(Planets.textures[planet.type], planet.x-Planets.textures[planet.type]:getWidth()/2*planet.scale, planet.y-Planets.textures[planet.type]:getHeight()/2*planet.scale, 0, planet.scale, planet.scale)
    end
end

function Planets.drawAtmos() 
    for i=1,#Planets do 
        local planet = Planets[i]
        love.graphics.setColor(getColor(planet))
        love.graphics.circle("fill", planet.x, planet.y, planet.r+150)
        love.graphics.circle("fill", planet.x, planet.y, planet.r+100)
        love.graphics.circle("fill", planet.x, planet.y, planet.r+50)
        love.graphics.setColor(1,1,1,1)
    end
end

return Planets