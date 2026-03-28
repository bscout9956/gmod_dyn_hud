local InputHandler = {}
local nextChange = 0

local function changeAstimagtismMode()
    Config.astigmatismMode = not Config.astigmatismMode
end

function InputHandler.handleShortcuts()
    local curTime = CurTime()
    if input.IsKeyDown(KEY_Z) and curTime > nextChange then
        State.ChangeZoom()
        nextChange = curTime + 0.009
    end

    if input.IsKeyDown(KEY_X) and curTime > nextChange then
        changeAstimagtismMode()
        nextChange = curTime + 0.2
    end
    if input.IsKeyDown(KEY_M) and curTime > nextChange and Settings.settingsFramePresent == false then
        Settings.OpenDynHudSettings()
        nextChange = curTime + 0.5 -- We make it real slow lmao
    end
    if input.IsKeyDown(KEY_T) and curTime > nextChange then
        State.switchMaps()
        nextChange = curTime + 0.25
    end
end

return InputHandler
