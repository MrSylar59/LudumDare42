local Explosions = {}

Explosions.tex = love.graphics.newImage("res/img/space/kboom.png")
Explosions.texW = Explosions.tex:getWidth()
Explosions.texH = Explosions.tex:getHeight()
Explosions.frames = {}
Explosions.frames[1] = love.graphics.newQuad(0, 0, 32, 32, Explosions.texW, Explosions.texH)
Explosions.frames[2] = love.graphics.newQuad(32, 0, 32, 32, Explosions.texW, Explosions.texH)
Explosions.frames[3] = love.graphics.newQuad(32*2, 0, 32, 32, Explosions.texW, Explosions.texH)
Explosions.frames[4] = love.graphics.newQuad(32*3, 0, 32, 32, Explosions.texW, Explosions.texH)
Explosions.frames[5] = love.graphics.newQuad(32*4, 0, 32, 32, Explosions.texW, Explosions.texH)
Explosions.frames[6] = love.graphics.newQuad(32*5, 0, 32, 32, Explosions.texW, Explosions.texH)
Explosions.frames[7] = love.graphics.newQuad(32*6, 0, 32, 32, Explosions.texW, Explosions.texH)

Explosions.exp = {}

function Explosions.new(pX, pY)
    _explosion = {}

    _explosion.x = pX
    _explosion.y = pY
    _explosion.frame = 1

    table.insert(Explosions.exp, _explosion)    
end

function Explosions.update(dt)
    for i=#Explosions.exp,1,-1 do 
        local exp = Explosions.exp[i]

        exp.frame = exp.frame + 7 * dt
        if exp.frame >= 8 then 
            table.remove(Explosions.exp, i)
            exp = nil
        end
    end
end

function Explosions.draw()
    for i=1,#Explosions.exp do 
        local exp = Explosions.exp[i]
        love.graphics.draw(Explosions.tex, Explosions.frames[math.floor(exp.frame)], exp.x-16*3, exp.y-16*3, 0, 3, 3)
    end
end

return Explosions