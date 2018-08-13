require("src.math")

love.graphics.setDefaultFilter("nearest")

local gs = require("src.gamestates")
local gui = require("src.gui")
local mm = require("src.musicManager")
local planets = require("src.planets")
local explosions = require("src.explosions")
local asteroids = require("src.asteroids")
local land = require("src.land")

local player = require("src.player")
local playerLand = require("src.playerLand")
local camera = require("src.camera")

local asteroidTimer

local reason = "startmenu"
local gameoverScreens = {}
gameoverScreens["crashed"] = love.graphics.newImage("res/img/RanOutOfSpaceBetweenUAndThePlanet.png")
gameoverScreens["destroyed"] = love.graphics.newImage("res/img/RanOutOfSpaceBtwUAndTheAsteroid.png")
gameoverScreens["fuel"] = love.graphics.newImage("res/img/RanOutOfFuel.png")
gameoverScreens["food"] = love.graphics.newImage("res/img/RanOutOfFood.png")
gameoverScreens["pop"] = love.graphics.newImage("res/img/RanOutOfSpace.png")
gameoverScreens["0pop"] = love.graphics.newImage("res/img/RanOutOfPpl.png")
gameoverScreens["trapped"] = love.graphics.newImage("res/img/RanOutOfGround.png")

gameoverScreens["victory"] = love.graphics.newImage("res/img/VICTORY.png")
gameoverScreens["startmenu"] = love.graphics.newImage("res/img/startmenu.png")

local scores = {}

local bgImg = love.graphics.newImage("res/img/space/bg_star.png")

local a = 0
local fadein = true

function fadeOut(time, dt, cb)
    if a < 1 then
        a = a+(1/time*dt)
    else
        a = 1
        if cb then
            cb()
        end
    end
end

function fadeIn(time, dt, cb)
    if fadein then
        if a > 0 then
            a = a-(1/time*dt)
        else
            a = 0
            if cb then
                cb()
            end
        end
    end
end

function love.load()
    love.graphics.setBackgroundColor(22/255, 36/255, 48/255)

    mm.addMusic(love.audio.newSource("res/music/main.mp3", "stream"))
    mm.addMusic(love.audio.newSource("res/music/mainMenu.mp3", "stream"))
    mm.addMusic(love.audio.newSource("res/music/earth.mp3", "stream"))
    mm.addMusic(love.audio.newSource("res/music/desert.mp3", "stream"))
    mm.addMusic(love.audio.newSource("res/music/lava.mp3", "stream"))
    mm.addMusic(love.audio.newSource("res/music/ice.mp3", "stream"))
    mm.addMusic(love.audio.newSource("res/music/gameover.mp3", "stream"))
    mm.addMusic(love.audio.newSource("res/music/victory.mp3", "stream"))

    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    initGameState("GameOver")
    mm.playMusic(2)
end

function initGameState(pGs) 
    if pGs == "SpaceFlight" then 
        gs.set("SpaceFlight")

        scores.fuel = 100
        scores.food = 500
        scores.pop = 1000
        scores.plan = 10

        mm.playMusic(1)

        asteroidTimer = math.floor(math.prandom(2,5))

        planets.init()

        player.init(w/2, h-450/3, "res/img/space/ship.png")
        camera.init(player.x-w/2, player.y-h/2, 0.5)
        planets.add("colonized", w/2, h+2*planets.rads["medium"]/3, "medium", false)

        for i=1,35 do 
            local rnd = math.floor(math.prandom(1, 5))
            local size = math.floor(math.prandom(1, 4))
            if rnd == 1 then rnd = "lava"
            elseif rnd == 2 then rnd = "ice"
            elseif rnd == 3 then rnd = "desert"
            else rnd = "earth" end

            if size == 1 then size = "large"
            elseif size == 2 then size = "medium"
            else size = "small" end
            planets.add(rnd, math.prandom(-2*w, 4*w), math.prandom(-65000, -800), size)
        end
    elseif pGs == "OnLand" then
        gs.set("OnLand")
        land.generate(player.refPlanet.size, player.refPlanet.type)

        if player.refPlanet.type == "earth" then 
            mm.playMusic(3)
        elseif player.refPlanet.type == "desert" then 
            mm.playMusic(4)
        elseif player.refPlanet.type == "lava" then
            mm.playMusic(5)
        elseif player.refPlanet.type == "ice" then
            mm.playMusic(6)
        end

        player.landed = false
        player.refPlanet.landable = false
        player.refPlanet.type = "colonized"
        local x,y
        repeat
            x,y = math.floor(math.prandom(2, land.map.w-1)), math.floor(math.prandom(2, land.map.h-1))
        until land.map.terrain[x][y] ~= 3 
        and (land.map.terrain[x+1][y] ~= 3
        or land.map.terrain[x-1][y] ~= 3
        or land.map.terrain[x][y-1] ~= 3
        or land.map.terrain[x][y+1] ~= 3)
        land.setShipPos(x, y)

        local ok = false
        while not ok do
            local rndPos = math.floor(math.prandom(1, 5))
            if rndPos == 1 and land.map.terrain[x][y-1] ~= 3 then 
                playerLand.init(x, y-1, "res/img/land/francis.png")
                ok = true
            elseif rndPos == 2 and land.map.terrain[x][y+1] ~= 3 then
                playerLand.init(x, y+1, "res/img/land/francis.png")
                ok = true
            elseif rndPos == 3 and land.map.terrain[x+1][y] ~= 3 then
                playerLand.init(x+1, y, "res/img/land/francis.png")
                ok = true
            elseif rndPos == 4 and land.map.terrain[x-1][y] ~= 3 then
                playerLand.init(x-1, y, "res/img/land/francis.png")
                ok = true
            end
        end

        land.map.objects[playerLand.x][playerLand.y] = 0
    elseif pGs == "GameOver" then
        gs.set("GameOver") 
    end
end

function love.update(dt)
    mm.update()

    if gs.get() == "SpaceFlight" then
        -- Update the space part
        fadeIn(3, dt)

        player.update(dt, planets, scores, asteroids, explosions)
        gui.update(dt, player)
        asteroids.update(player, planets, explosions, dt)
        explosions.update(dt)
        updateBullets(dt, asteroids)
        camera.moveTo(player.x, player.y)
        camera.zoomTo(player.getSpeed()/150)

        asteroidTimer = asteroidTimer - dt

        if asteroidTimer <= 0 then 
            asteroidTimer = math.floor(math.prandom(0.5,2))
            local x,y = math.prandom(player.x-w, player.x+w), player.y-h
            asteroids.add(x, y, math.floor(math.prandom(80, 70)))
        end

        if player.landed then 
            fadein = false
            fadeOut(1.5, dt, function() 
                initGameState("OnLand")
                fadein = true
            end)
        end

        if player.crashed then 
            fadein = false
            fadeOut(3, dt, function() 
                reason = "crashed"
                initGameState("GameOver")
                mm.playMusic(7)
                fadein = true
            end)
        end

        if player.destroyed then 
            fadein = false
            fadeOut(3, dt, function() 
                reason = "destroyed"
                initGameState("GameOver")
                mm.playMusic(7)
                fadein = true
            end)
        end

        if scores.fuel <= 0 then 
            fadein = false
            fadeOut(3, dt, function()
                reason = "fuel"
                initGameState("GameOver")
                mm.playMusic(7)
                fadein = true
            end)
        end

        if scores.pop >= 5000 then 
            fadein = false
            fadeOut(3, dt, function()
                reason = "pop"
                initGameState("GameOver")
                mm.playMusic(7)
                fadein = true
            end)
        end

        if scores.plan <= 0 then 
            fadein = false
            fadeOut(3, dt, function()
                reason = "victory"
                initGameState("GameOver")
                mm.playMusic(8)
                fadein = true
            end)
        end
    elseif gs.get() == "OnLand" then
        -- Update the land part
        fadeIn(3, dt)

        playerLand.update(land.map, land.ship.x, land.ship.y, scores, dt)
        land.update(dt)
        if playerLand.takeOff then 
            fadein = false
            fadeOut(1.5, dt, function()
                gs.set("SpaceFlight")
                mm.playMusic(1)
                scores.plan = scores.plan - 1
                fadein = true
            end)
        end

        if scores.food <= 0 then 
            fadein = false
            fadeOut(3, dt, function()
                reason = "food"
                initGameState("GameOver")
                mm.playMusic(7)
                fadein = true
            end)
        end

        if scores.pop <= 0 then 
            fadein = false
            fadeOut(3, dt, function()
                reason = "0pop"
                initGameState("GameOver")
                mm.playMusic(7)
                fadein = true
            end)
        end

        if playerLand.trapped then
            fadein = false
            fadeOut(3, dt, function()
                reason = "trapped"
                initGameState("GameOver")
                mm.playMusic(7)
                fadein = true
            end) 
        end
    elseif gs.get() == "GameOver" then
        fadeIn(3, dt)
    end
end

function love.draw()
    for x=1,math.ceil(w/128) do 
        for y=1,math.ceil(h/128) do 
            love.graphics.draw(bgImg, (x-1)*128, (y-1)*128, 0, 2, 2)
        end
    end

    if gs.get() == "SpaceFlight" then
        camera.set()
        -- Draw the space part

        for i=1,#planets do 
            local planet = planets[i]
            local dist = math.dist(player.x, player.y, planet.x, planet.y)
            local angle = math.angle(player.x, player.y, planet.x, planet.y)

            if dist > planet.r+50 and dist < 7000 then
                love.graphics.setColor(0,1,0, math.normalize(dist, 7000, planet.r+50))
                love.graphics.circle("fill", player.x + math.cos(angle) * 75, player.y + math.sin(angle) * 75, 10*math.normalize(dist, 7000, planet.r+50))
                love.graphics.setColor(1,1,1,1)
            end
        end

        planets.draw()
        drawBullets()
        asteroids.draw()
        explosions.draw()
        player.draw()
        planets.drawAtmos()
        camera.unset()
    elseif gs.get() == "OnLand" then
        love.graphics.push()
        love.graphics.translate(w/2-land.map.w/2*land.TILESIZE, h/2-land.map.h/2*land.TILESIZE)
        land.draw()
        playerLand.draw(land.TILESIZE)
        love.graphics.pop()

    elseif gs.get() == "GameOver" then
        love.graphics.draw(gameoverScreens[reason], 0, 0)

        if reason ~= "startmenu" then
            love.graphics.setColor(25/255, 25/255, 25/255)
            love.graphics.rectangle("fill", w/2-180, 21, 320, 30)
            love.graphics.setColor(1,1,1,1)
            love.graphics.print("Press <space> to restart", w/2-170, 20, 0, 2, 2) 
        end
    end

    if gs.get() == "SpaceFlight" or gs.get() == "OnLand" then 
        gui.draw(scores, w, h)
    end

    love.graphics.setColor(0,0,0,a)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.setColor(1,1,1,1)
end

function love.keypressed(key)
    if gs.get() == "SpaceFlight" then 
        player.keypressed(key)
    elseif gs.get() == "OnLand" then
        playerLand.keypressed(key)
    elseif gs.get() == "GameOver" and key == "space" then
        initGameState("SpaceFlight")
    end
end