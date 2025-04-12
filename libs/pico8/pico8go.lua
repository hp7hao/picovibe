function vibrate(s,d)
    printh("vibrate "..s.." "..d,"vibrator")
end

function sfxplay(s)
    printh("mpv:stop","pico8goapi")
    printh("mpv:play "..s,"pico8goapi")
end

function sfxstop()
    printh("mpv:stop","pico8goapi")
end

function sfxpause()
    printh("mpv:pause","pico8goapi")
end

function sfxresume()
    printh("mpv:resume","pico8goapi")
end
