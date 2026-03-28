local round = math.Round

local State = {}
local geometry = include("geometry.lua")

State.bmapVisible = false

State.Points = {} -- TODO: I think this shouldn't be a global variable exposed like this, if you're reading this, don't mess it up lmao

---@type table
local pointsLookup = {}

--- Adds a point to the points table if it doesn't already exist.
--- Avoids adding unnecessary points, helps with performance.
---@param x number @X coordinate
---@param y number @Y coordinate
---@param z number @Z coordinate
function State.addPoint(x, y, z)
    local key = x .. "_" .. y .. "_" .. z
    if not pointsLookup[key] then
        pointsLookup[key] = true
        table.insert(State.Points, {
            x = x,
            y = y,
            z = z
        })
    end
end

--- Helper to switch between the big map and the regular map
function State.switchMaps()
    State.bmapVisible = not State.bmapVisible
end

--- Helper to reset the points when changing resolution
function State.resetPoints()
    Points = {}
    pointsLookup = {}
end

function State.ChangeZoom()
    if Config.uiZoomLevel >= 1 then
        Config.uiZoomLevel = 0.1
    else
        Config.uiZoomLevel = Config.uiZoomLevel + 0.01
    end
    Config.mapZoomLevel = Config.uiZoomLevel / 10
end

--- Register the current player position in the points table, with some precision reduction
function State.registerPlayerPos()
    local pos = LocalPlayer():GetPos()
    -- We drop some precision for X and Y because we don't really need that much precision honestly
    -- It also looks really cool lmao
    State.addPoint(
        round(pos.x * Config.mapResolution) / Config.mapResolution,
        round(pos.y * Config.mapResolution) / Config.mapResolution,
        round(pos.z * Config.mapResolution) / Config.mapResolution
    )
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
