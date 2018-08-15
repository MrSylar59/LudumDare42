local Player = {}

function Player.init(pX, pY, pImg)
    Player.x = pX
    Player.y = pY

    Player.oX = pX
    Player.oY = pY

    Player.drawX = pX
    Player.drawY = pY

    Player.lX = pX
    Player.lY = pY

    Player.sfxMv = love.audio.newSource("res/sfx/move.wav", "static")
    Player.sfxFu = love.audio.newSource("res/sfx/fuel.wav", "static")
    Player.sfxFo = love.audio.newSource("res/sfx/nomnom.wav", "static")

    Player.timer = 0

    Player.tex = love.graphics.newImage(pImg)
    Player.w = Player.tex:getWidth()
    Player.h = Player.tex:getHeight()

    Player.img = {
        love.graphics.newQuad(0, 0, 32, 32, Player.w, Player.h),
        love.graphics.newQuad(32, 0, 32, 32, Player.w, Player.h)
    }

    Player.frame = 1

    Player.keyPressed = false
    Player.canTakeOff = false
    Player.takeOff = false
    Player.trapped = false
end

function Player.isTrapped(map, shipX, shipY)
    local up, left, right, down = true, true, true, true

    if not isWalkable(map.terrain[shipX][shipY]) then 
        return true
    end

    if Player.x == 1 then left = false end
    if Player.x == map.w then right = false end
    if Player.y == 1 then up = false end
    if Player.y == map.h then down = false end

    if left and not isWalkable(map.terrain[Player.x-1][Player.y]) then left = false end
    if right and not isWalkable(map.terrain[Player.x+1][Player.y]) then right = false end
    if up and not isWalkable(map.terrain[Player.x][Player.y-1]) then up = false end
    if down and not isWalkable(map.terrain[Player.x][Player.y+1]) then down = false end

    if (not (up or right or left or down)) and (Player.x ~= shipX or Player.y ~= shipY) then return true end
    return false
end

function Player.update(map, shipX, shipY, pScores, dt)

    Player.frame = Player.frame + 5 * dt
    if Player.frame >= 3 then Player.frame = 1 end

    if Player.x ~= Player.drawX or Player.y ~= Player.drawY then 
        Player.timer = Player.timer + 1 * dt
        Player.drawX = math.linear(Player.timer, Player.lX, Player.x - Player.lX, 0.3)
        Player.drawY = math.linear(Player.timer, Player.lY, Player.y - Player.lY, 0.3)

        if Player.timer > 0.3 then 
            Player.drawX = Player.x
            Player.drawY = Player.y
            Player.timer = 0 
        end
    end

    if love.keyboard.isDown("w","a","s","d","z","q","up","right","down","left") and pScores.pop > 0 and pScores.food > 0
    and Player.drawX == Player.x and Player.drawY == Player.y then 
        Player.oX, Player.oY = Player.x, Player.y
        
        if not Player.keyPressed then 
            Player.keyPressed = true

            if love.keyboard.isDown("w","z","up") and Player.y > 1 then 
                Player.lX = Player.x
                Player.lY = Player.y
                Player.y = Player.y - 1
                Player.sfxMv:play()
            end
            if love.keyboard.isDown("a","q","left") and Player.x > 1 then 
                Player.lX = Player.x
                Player.lY = Player.y
                Player.x = Player.x - 1
                Player.sfxMv:play()
            end
            if love.keyboard.isDown("s","down") and Player.y < map.h then 
                Player.lX = Player.x
                Player.lY = Player.y
                Player.y = Player.y + 1
                Player.sfxMv:play()
            end
            if love.keyboard.isDown("d", "right") and Player.x < map.w then 
                Player.lX = Player.x
                Player.lY = Player.y
                Player.x = Player.x + 1
                Player.sfxMv:play()
            end

            if not isWalkable(map.terrain[Player.x][Player.y]) then 
                Player.x = Player.oX
                Player.y = Player.oY
            else
                map.terrain[Player.oX][Player.oY] = 2
                pScores.pop = pScores.pop - 50
                pScores.food = pScores.food - 25

                Player.trapped = Player.isTrapped(map, shipX, shipY)

                if pScores.pop < 0 then pScores.pop = 0 end
                if pScores.food < 0 then pScores.food = 0 end
            end

            if Player.x == shipX and Player.y == shipY then 
                Player.canTakeOff = true
            else
                Player.canTakeOff = false
            end

            if map.objects[Player.x][Player.y] == 1 then
                pScores.fuel = pScores.fuel + 10
                Player.sfxFu:play()
                if pScores.fuel > 100 then 
                    pScores.fuel = 100
                end
                map.objects[Player.x][Player.y] = 0
            elseif map.objects[Player.x][Player.y] == 2 then
                Player.sfxFo:play()
                pScores.food = pScores.food + 250
                map.objects[Player.x][Player.y] = 0
            end
        end
    else
        Player.keyPressed = false
    end
end

function Player.draw(pTileSize)
    love.graphics.draw(Player.tex, Player.img[math.floor(Player.frame)], (Player.drawX-1)*pTileSize, (Player.drawY-1)*pTileSize)
    if Player.canTakeOff then 
        love.graphics.print("Press 'X' to take off.", Player.x*pTileSize-125, Player.y*pTileSize, 0, 2, 2)
    end
end

function Player.keypressed(key)
    if key == "x" and Player.canTakeOff then 
        Player.takeOff = true
    end
end

return Player