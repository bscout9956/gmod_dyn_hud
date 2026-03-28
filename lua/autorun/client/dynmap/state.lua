local State = {}

function State.ChangeZoom()
    if Config.uiZoomLevel >= 1 then
        Config.uiZoomLevel = 0.1
    else
        Config.uiZoomLevel = Config.uiZoomLevel + 0.01
    end
    Config.mapZoomLevel = Config.uiZoomLevel / 10
end

return State
