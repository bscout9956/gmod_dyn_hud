local Geometry = {}

--- Creates the coordinates for where the player indicator should be.
--- It's in the shape of a triangle with a notch.
---@param cx number @X coordinate of the center
---@param cy number @Y coordinate of the center
---@param size number @Size of the indicator
---@return table
local function createIndicatorVertices(cx, cy, size)
    local notchOffset = size * Settings.playerIndicatorNotch

    return {
        { x = cx,        y = cy - size,               u = 0, v = 0 }, -- 1. Top Tip
        { x = cx + size, y = cy + size,               u = 0, v = 0 }, -- 2. Bottom Right
        { x = cx,        y = cy + size - notchOffset, u = 0, v = 0 }, -- 3. The Notch (Center Base)
        { x = cx - size, y = cy + size,               u = 0, v = 0 }, -- 4. Bottom Left
        { x = cx,        y = cy - size,               u = 0, v = 0 }  -- 5. Back to Top Tip
    }
end

--- Intializes all the derivative values based on the current settings.
function Geometry.initDerivativeValues()
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

    Config.playerIndicatorTable = createIndicatorVertices(
        Config.mapCenterX, Config.mapCenterY, Config.playerIndicatorSize
    )
    Config.bigMapPlayerIndicatorTable = createIndicatorVertices(
        Config.bigMapCenterX, Config.bigMapCenterY, Config.playerIndicatorSize
    )
end

return Geometry
