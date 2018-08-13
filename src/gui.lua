local Gui = {}

Gui.tex = love.graphics.newImage("res/img/gui/gui.png")
Gui.texW = Gui.tex:getWidth()
Gui.texH = Gui.tex:getHeight()

Gui.food = love.graphics.newQuad(0, 0, 32, 32, Gui.texW, Gui.texH)
Gui.fuel = love.graphics.newQuad(32, 0, 32, 32, Gui.texW, Gui.texH)
Gui.pop = love.graphics.newQuad(64, 0, 32, 32, Gui.texW, Gui.texH)
Gui.plan = love.graphics.newQuad(96, 0, 32, 32, Gui.texW, Gui.texH)

Gui.drawAngleWarning = false
Gui.drawSpeedWarning = false

Gui.blinkTimer = 0
Gui.blinkState = 1

function Gui.update(dt, player)
    Gui.blinkTimer = Gui.blinkTimer + 1 * dt
    if Gui.blinkTimer >= 0.3 and Gui.blinkState == 0 then 
        Gui.blinkState = 1
        Gui.blinkTimer = 0
    elseif Gui.blinkTimer >= 1 and Gui.blinkState == 1 then
        Gui.blinkState = 0
        Gui.blinkTimer = 0
    end

    if math.dist(player.landX, player.landY, player.refPlanet.x, player.refPlanet.y) <= player.refPlanet.r*7 then 
        if player.getSpeed() >= player.maxLandSpeed then
            Gui.drawSpeedWarning = true
        else
            Gui.drawSpeedWarning = false
        end
        
        if not player.goodLandingAngle then 
            Gui.drawAngleWarning = true
        else
            Gui.drawAngleWarning = false
        end
    else
        Gui.drawSpeedWarning = false
        Gui.drawAngleWarning = false
    end
end

function Gui.draw(scores, width, height)
    love.graphics.setColor(25/255, 25/255, 25/255, 180/255)
    love.graphics.rectangle("fill", 0, 0, width, 50)
    love.graphics.setColor(1,1,1,1)

    love.graphics.draw(Gui.tex, Gui.food, 50, 9)
    love.graphics.print(scores.food, 90, 12, 0, 1.5, 1.5)

    love.graphics.draw(Gui.tex, Gui.fuel, 250, 9)
    love.graphics.print(math.round(scores.fuel,2), 290, 12, 0, 1.5, 1.5)

    love.graphics.draw(Gui.tex, Gui.pop, 450, 9)
    love.graphics.print(math.floor(scores.pop), 490, 12, 0, 1.5, 1.5)

    love.graphics.draw(Gui.tex, Gui.plan, 650, 9)
    love.graphics.print(scores.plan, 690, 12, 0, 1.5, 1.5)

    if true then
        love.graphics.setColor(1,0,0)
        if Gui.drawSpeedWarning then 
            love.graphics.print("Too fast to land.", 50, h-50, 0, 2, 2)
        end
        if Gui.drawAngleWarning then 
            love.graphics.print("Bad angle to land.", w-300, h-50, 0, 2, 2)
        end
        love.graphics.setColor(1,1,1)
    end
end

return Gui