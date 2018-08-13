local MusicManager = {}

MusicManager.musics = {}
MusicManager.currentMusic = 0
MusicManager.maxVolume = 0.7

function MusicManager.addMusic(pMusic)
    local newMusic = {}
    newMusic.source = pMusic
    newMusic.source:setLooping(true)
    newMusic.source:setVolume(0)
    table.insert(MusicManager.musics, newMusic)
end

function MusicManager.update()
    for i, music in ipairs(MusicManager.musics) do 
        if i == MusicManager.currentMusic then 
            if music.source:getVolume() < MusicManager.maxVolume then
                music.source:setVolume(music.source:getVolume()+0.01)
            end
        else
            if music.source:getVolume() > 0 then
                music.source:setVolume(music.source:getVolume()-0.01)
            end

            if music.source:getVolume() <= 0.1 then 
                music.source:setVolume(0)
                music.source:stop()
            end
        end
    end
end

function MusicManager.playMusic(num) 
    local music = MusicManager.musics[num]

    if music.source:getVolume() == 0 and MusicManager.currentMusic ~= num then
        music.source:play()
    end

    MusicManager.currentMusic = num
end

return MusicManager