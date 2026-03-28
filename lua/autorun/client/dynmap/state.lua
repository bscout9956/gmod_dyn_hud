local State = {}
local geometry = include("geometry.lua")

function State.ChangeZoom()
    if Config.uiZoomLevel >= 1 then
        Config.uiZoomLevel = 0.1
    else
        Config.uiZoomLevel = Config.uiZoomLevel + 0.01
    end
    Config.mapZoomLevel = Config.uiZoomLevel / 10
end

--- Intializes all the derivative values based on the current settings.
function State.initDerivativeValues()
    Config.halfMapSize = Config.mapSize / 2
    Config.bigMapHalfSizeX = Config.bigMapSizeX / 2
    Config.bigMapHalfSizeY = Config.bigMapSizeY / 2
    Config.mapZoomLevel = Config.uiZoomLevel / 10
    Config.mapXpos = Config.margin
    Config.mapYpos = Config.margin
    Config.bigMapXpos = (ScrW() / 2) - Config.bigMapHalfSizeX
    Config.bigMapYpos = (ScrH() / 2) - Config.bigMapHalfSizeY
    Config.mapCenterX = Config.mapXpos + Config.halfMapSize
    Config.mapCenterY = Config.mapYpos + Config.halfMapSize
    Config.bigMapCenterX = Config.bigMapXpos + Config.bigMapHalfSizeX
    Config.bigMapCenterY = Config.bigMapYpos + Config.bigMapHalfSizeY
    Config.mapResolution = Config.uiResolution / 100

    Config.playerIndicatorTable = geometry.createIndicatorVertices(
        Config.mapCenterX, Config.mapCenterY, Config.playerIndicatorSize
    )
    Config.bigMapPlayerIndicatorTable = geometry.createIndicatorVertices(
        Config.bigMapCenterX, Config.bigMapCenterY, Config.playerIndicatorSize
    )
end

return State
