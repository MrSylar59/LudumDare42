local Player = {}

Player.bullets = {}

function createBullet()
    local _bullet = {}

    _bullet.x = Player.x
    _bullet.y = Player.y
    _bullet.angle = Player.angle
    _bullet.vx = Player.vx
    _bullet.vy = Player.vy
    _bullet.accel = 20
    _bullet.tex = love.graphics.newImage("res/img/space/bullets.png") 
    _bullet.w = _bullet.tex:getWidth()
    _bullet.h = _bullet.tex:getHeight()
    _bullet.currFrame = 1
    _bullet.anim = {
        love.graphics.newQuad(0, 0, 32, 32, _bullet.w, _bullet.h),
        love.graphics.newQuad(0, 33, 32, 32, _bullet.w, _bullet.h),
        love.graphics.newQuad(0, 66, 32, 32, _bullet.w, _bullet.h)
    }

    _bullet.lifeSpan = 3.5

    _bullet.sfx = love.audio.newSource("res/sfx/missile.wav", "static")
    _bullet.sfx:setVolume(0.2)
    _bullet.sfx:setPitch(math.round(math.prandom(0.2, 1.2), 1))

    _bullet.sfx:play()

    table.insert(Player.bullets, _bullet)
end

function updateBullets(dt, asteroids)
    for i=#Player.bullets,1,-1 do 
        local bullet = Player.bullets[i]

        bullet.currFrame = bullet.currFrame + 20*dt
        if bullet.currFrame >= 4 then bullet.currFrame = 1 end

        bullet.vx = bullet.vx + bullet.accel * math.cos(math.rad(bullet.angle)) *60*dt
        bullet.vy = bullet.vy + bullet.accel * math.sin(math.rad(bullet.angle)) *60*dt

        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt

        bullet.lifeSpan = bullet.lifeSpan - dt
        if bullet.lifeSpan <= 0 then 
            table.remove(Player.bullets, i)
            bullet = nil
        end

        -- Check collision between bullets and asteroids
        for j=#asteroids,1,-1 do 
            local asteroid = asteroids[j]
            if bullet and math.dist(asteroid.x, asteroid.y, bullet.x, bullet.y) < 30 then 
                asteroid.destroyed = true
                table.remove(Player.bullets, i)
                bullet = nil
            end
        end
    end
end

function drawBullets()
    for i=1,#Player.bullets do 
        local bullet = Player.bullets[i]
        love.graphics.draw(bullet.tex, bullet.anim[math.floor(bullet.currFrame)], bullet.x-16, bullet.y, math.rad(bullet.angle))
        --love.graphics.circle("fill", bullet.x, bullet.y, 2)
    end
end

function Player.init(pX, pY, pImg) 
    Player.x = pX
    Player.y = pY
    Player.angle = 270
    Player.vx = 0
    Player.vy = 0
    Player.accel = 3

    Player.maxLandSpeed = 150

    Player.img = love.graphics.newImage(pImg)
    Player.w = Player.img:getWidth()
    Player.h = Player.img:getHeight()

    Player.landX = pX
    Player.landY = pY + Player.h/3

    Player.tookOff = false
    Player.refPlanet = nil
    Player.crashed = false
    Player.destroyed = false
    Player.landed = false
    Player.goodLandingAngle = true
    Player.explode = true

    Player.flame = {}
    Player.flame.tex = love.graphics.newImage("res/img/space/flames.png")
    Player.flame.w = Player.flame.tex:getWidth()
    Player.flame.h = Player.flame.tex:getHeight()
    Player.flame.currFrame = 1
    Player.flame.anims = {
        land = {},
        fly = {
            love.graphics.newQuad(33, 0, 32, 32, Player.flame.w, Player.flame.h),
            love.graphics.newQuad(33, 33, 32, 32, Player.flame.w, Player.flame.h)
        },
        boost = {
            love.graphics.newQuad(0, 0, 32, 32, Player.flame.w, Player.flame.h),
            love.graphics.newQuad(0, 33, 32, 32, Player.flame.w, Player.flame.h)
        }
    }
    Player.flame.x = 0
    Player.flame.y = 0

    Player.sfxAccel = love.audio.newSource("res/sfx/acceleration.wav", "static")
    Player.sfxAccel:setVolume(0.5)
    Player.sfxTakeOff = love.audio.newSource("res/sfx/decollage.wav", "static")
    Player.sfxTakeOff:setVolume(0.5)

    Player.action = "fly"
end

function Player.getSpeed()
    return math.mag(Player.vx, Player.vy)
end

function Player.update(dt, pPlanets, pScores, pAsteroids, pExplosions)
    if Player.x < -2180 then 
        Player.x = 3780
    elseif Player.x > 3780 then
        Player.x = -2180
    end

    if Player.y < -65580 then 
        Player.y = 2380
    elseif Player.y > 2380 then
        Player.y = -65580
    end

    for i=1,#pPlanets do 
        local planet = pPlanets[i]
        if math.dist(Player.x, Player.y, planet.x, planet.y) < planet.r * 2 then 
            Player.refPlanet = planet
        end
    end

    for i=1,#pAsteroids do 
        local ast = pAsteroids[i]
        if math.dist(Player.x, Player.y, ast.x, ast.y) < 20 then 
            Player.destroyed = true 
            Player.vx = 0
            Player.vy = 0

            ast.destroyed = true
        end
    end

    local animSpeed = 5

    if Player.action == "boost" then 
        animSpeed = 10
    end

    Player.flame.currFrame = Player.flame.currFrame + animSpeed*dt
    if Player.flame.currFrame >= 3 then Player.flame.currFrame = 1 end

    if math.dist(Player.landX, Player.landY, Player.refPlanet.x, Player.refPlanet.y) > Player.refPlanet.r+1 and not Player.tookOff then 
        Player.tookOff = true
    end

    local planetAngle = math.angle(Player.refPlanet.x, Player.refPlanet.y, Player.x, Player.y)
    local fangle = math.deg(math.rad(Player.angle)-planetAngle)
    if fangle < 0 then 
        fangle = fangle*-1
    end
    if (fangle >= 0 and fangle <= 20) or (fangle >= 340 and fangle <= 380) then 
        Player.goodLandingAngle = true
    else
        Player.goodLandingAngle = false
    end

    if math.dist(Player.landX, Player.landY, Player.refPlanet.x, Player.refPlanet.y) <= Player.refPlanet.r and Player.tookOff then
        if Player.getSpeed() <= Player.maxLandSpeed and Player.goodLandingAngle then 
            Player.tookOff = false
            Player.vx = 0
            Player.vy = 0
        else
            Player.crashed = true
            Player.vx = 0
            Player.vy = 0
        end
    end

    if not Player.crashed and not Player.destroyed then
        if Player.tookOff then 
            if love.keyboard.isDown("d", "right") then 
                Player.angle = Player.angle + 180 * dt
                if Player.angle > 360 then 
                    Player.angle = 0
                end
            end

            if love.keyboard.isDown("a", "q", "left") then 
                Player.angle = Player.angle - 180 * dt
                if Player.angle < 0 then 
                    Player.angle = 360
                end
            end

            pScores.pop = pScores.pop + 50 * dt
        end

        if love.keyboard.isDown("w", "z", "up") then 
            Player.vx = Player.vx + Player.accel * math.cos(math.rad(Player.angle))
            Player.vy = Player.vy + Player.accel * math.sin(math.rad(Player.angle))

            Player.action = "boost"

            pScores.fuel = pScores.fuel - 1.5*dt
        else
            Player.action = "fly"
        end

        -- Add planet / player attraction
        if Player.tookOff and math.dist(Player.x, Player.y, Player.refPlanet.x, Player.refPlanet.y) <= Player.refPlanet.r*2 then 
            local angle = math.angle(Player.x, Player.y, Player.refPlanet.x, Player.refPlanet.y)
            Player.vx = Player.vx + math.cos(angle) * 60*dt  
            Player.vy = Player.vy + math.sin(angle) * 60*dt
        end

        if Player.vx > 200 then 
            Player.vx = 200
        elseif Player.vx < -200 then
            Player.vx = -200
        end

        if Player.vy > 200 then 
            Player.vy = 200
        elseif Player.vy < -200 then
            Player.vy = -200
        end

        Player.x = Player.x + Player.vx * dt
        Player.y = Player.y + Player.vy * dt
        Player.landX = Player.x - Player.h/3 * math.cos(math.rad(Player.angle))
        Player.landY = Player.y - Player.h/3 * math.sin(math.rad(Player.angle))
        Player.flame.x = Player.x - (Player.h/2 + 3) * math.cos(math.rad(Player.angle))
        Player.flame.y = Player.y - (Player.h/2 + 3) * math.sin(math.rad(Player.angle))
    else
        if Player.explode then
            explode(Player.x, Player.y, pExplosions, 0)
            Player.explode = false
        end
    end
end

function Player.draw()
    if not Player.crashed and not Player.destroyed then
        if Player.tookOff or Player.vx ~= 0 or Player.vy ~= 0 then
            love.graphics.draw(Player.flame.tex, Player.flame.anims[Player.action][math.floor(Player.flame.currFrame)], Player.flame.x, Player.flame.y, math.rad(Player.angle), 1,1, 32,16)
        end
        love.graphics.draw(Player.img, Player.x, Player.y, math.rad(Player.angle), 1, 1, Player.w/2, Player.h/2)
        if not Player.tookOff and Player.refPlanet.landable then 
            love.graphics.print("Press 'X' to exit the spaceship", Player.x-75, Player.y-75)
        end
    end
end

function Player.keypressed(key)
    if not (Player.crashed or Player.destroyed) then
        if key == "x" and not Player.tookOff and Player.refPlanet.landable then
            Player.landed = true
        end

        if key == "space" and Player.tookOff then 
            createBullet()
        end

        if key == "w" or key == "z" or key == "up" then 
            if math.dist(Player.x, Player.y, Player.refPlanet.x, Player.refPlanet.y) < Player.refPlanet.r + 100 then 
                Player.sfxTakeOff:play()
            else
                Player.sfxAccel:play()
            end
        end
    end
end

return Player