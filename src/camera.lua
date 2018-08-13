local Camera = {}

function Camera.init(pX, pY, pS) 
    Camera.x = pX
    Camera.y = pY
    Camera.s = pS
end

function Camera.set() 
    love.graphics.push()
    love.graphics.scale(1/Camera.s, 1/Camera.s)
    love.graphics.translate(-Camera.x, -Camera.y)
end

function Camera.unset() 
    love.graphics.pop()
end

function Camera.moveTo(pX, pY)
    Camera.x = pX-w/2*Camera.s
    Camera.y = pY-h/2*Camera.s
end

function Camera.zoomTo(pS)
    Camera.s = math.lerp(Camera.s, pS, 0.01)
    if Camera.s <= 0.5 then 
        Camera.s = math.lerp(Camera.s, 0.5, 0.05)
    end
end

return Camera 