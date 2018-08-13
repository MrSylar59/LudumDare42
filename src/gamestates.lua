local GameState = {}

GameState.state = "SpaceFlight"

function GameState.get() 
    return GameState.state
end

function GameState.set(pState)
    GameState.state = pState
end

return GameState