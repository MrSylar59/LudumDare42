-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function math.mag(x,y) return (x^2+y^2)^0.5 end

function math.dot(x1,y1, x2,y2) return x1*x2+y1*y2 end

-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

-- Linear interpolation between two numbers.
function math.lerp(a,b,t) return (1-t)*a + t*b end

-- Linear tweening
-- t = time
-- b = start
-- c = dist
-- d = forHowLong
function math.linear(t, b, c, d) return c * t / d + b end

-- Gives a precise random decimal number given a minimum and maximum
function math.prandom(min, max) return love.math.random() * (max - min) + min end

-- Normalize a number.
function math.normalize(x, min, max) return (x-min)/(max-min) end

-- Normalize two numbers.
function math.normalize2(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end

function math.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function explode(x, y, exp, dist)
    local sfx = love.audio.newSource("res/sfx/explosion.wav", "static")
    local pitch = math.round(math.prandom(0.5, 2), 1)
    sfx:setPitch(pitch)

    local num = math.floor(math.prandom(1,3))

    exp.new(x, y)
    num = num - 1

    for i=1,num do 
        local dx, dy = x + math.prandom(-100, 100), y + math.prandom(-100, 100)
        exp.new(dx, dy)
    end

    if dist < 1000 then 
        sfx:play()
    end
end