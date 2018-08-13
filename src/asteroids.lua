local Asteroids = {}

Asteroids.tex = love.graphics.newImage("res/img/space/asteroids.png")
Asteroids.texW = Asteroids.tex:getWidth()
Asteroids.texH = Asteroids.tex:getHeight()
Asteroids.img = {}
Asteroids.img[1] = love.graphics.newQuad(0, 0, 64, 64, Asteroids.texW, Asteroids.texH)
Asteroids.img[2] = love.graphics.newQuad(0, 64, 64, 64, Asteroids.texW, Asteroids.texH)
Asteroids.img[3] = love.graphics.newQuad(0, 128, 64, 64, Asteroids.texW, Asteroids.texH)
Asteroids.img[4] = love.graphics.newQuad(64, 0, 64, 64, Asteroids.texW, Asteroids.texH)
Asteroids.img[5] = love.graphics.newQuad(64, 64, 64, 64, Asteroids.texW, Asteroids.texH)

function Asteroids.add(pX, pY, pAngle) 
    local _asteroid = {}

    _asteroid.x = pX
    _asteroid.y = pY
    _asteroid.angle = pAngle
    _asteroid.accel = math.floor(math.prandom(1, 8))+1
    _asteroid.vx = 0
    _asteroid.vy = 0

    _asteroid.imgIndex = math.floor(math.prandom(1, 6))

    _asteroid.destroyed = false

    _asteroid.rot = 0

    table.insert(Asteroids, _asteroid)
end

function Asteroids.update(player, planets, explosions, dt)
    for i=#Asteroids,1,-1 do 
        local asteroid = Asteroids[i]

        asteroid.vx = asteroid.vx + asteroid.accel * math.cos(math.rad(asteroid.angle)) * 60 * dt
        asteroid.vy = asteroid.vy + asteroid.accel * math.sin(math.rad(asteroid.angle)) * 60 * dt

        asteroid.x = asteroid.x + asteroid.vx * dt
        asteroid.y = asteroid.y + asteroid.vy * dt

        asteroid.rot = asteroid.rot + (2*asteroid.accel)*dt
        if asteroid.rot > 360 then asteroid.rot = 0 end

        local dist = math.dist(player.x, player.y, asteroid.x, asteroid.y)

        for j=1,#planets do 
            local planet = planets[j]
            if math.dist(asteroid.x, asteroid.y, planet.x, planet.y) <= planet.r+30 then
                asteroid.destroyed = true 
            end
        end

        if dist > 1200 or asteroid.destroyed then 
            if dist < 1200 then
                explode(asteroid.x, asteroid.y, explosions, dist)
            end
            table.remove(Asteroids, i)
            asteroid = nil
        end
    end
end

function Asteroids.draw()
    for i=1,#Asteroids do 
        local asteroid = Asteroids[i]
        love.graphics.draw(Asteroids.tex, Asteroids.img[asteroid.imgIndex], asteroid.x, asteroid.y, asteroid.rot, 1, 1, 32, 32)
    end
end

return Asteroids