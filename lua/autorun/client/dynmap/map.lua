local debug = include("debug.lua")
local colors = include("colors.lua")
local utils = include("utils.lua")

---@type table
local Map = {}

-- Localization for surface stuff
local drawRect = surface.DrawRect
local setDrawColor = surface.SetDrawColor

---@type number
local noBoundMapSize = Settings.mapSize - (Settings.borderThickness * 2)
---@type number
local mapBound = Settings.halfMapSize - Settings.borderThickness
---@type table
local mapBounds = { x = mapBound, y = mapBound }

-- Localization for Math Functions
local abs = math.abs
local cos = math.cos
local sin = math.sin
local rad = math.rad
local max = math.max

local ply = LocalPlayer()

local r, g, b = 255, 255, 255

--- Renders all the points for the registered player positions applying rotation and checking Map Bounds.
local function pointRender()
    local renderStart = SysTime()
    -- Early return in case the player is still loading
    if not IsValid(ply) then return end
    local playerPos = ply:GetPos()

    local color = colors.WHITE

    if Settings.astigmatismMode then
        color = colors.SOFT_GRAY
    end

    draw.NoTexture()

    utils.drawPoints(playerPos, colors.WHITE, mapBounds, true)

    local renderEnd = SysTime()
    local frameTime = (renderEnd - renderStart) * 1000
    local timeDiff = string.format("%.2f ms", frameTime)
    -- TODO: Make this optional
    draw.SimpleText(timeDiff, "DermaDefaultBold", 30, 30, colors.GREEN, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

--- Draws the map box including its outline and background.
--- Applies different colors based on the astigmatism mode setting.
local function drawMapBox()
    if not Settings.astigmatismMode then
        surface.SetDrawColor(255, 255, 255, 255)
    else
        surface.SetDrawColor(60, 60, 60, 255)
    end

    surface.DrawOutlinedRect(Settings.mapXpos, Settings.mapYpos, Settings.mapSize, Settings.mapSize,
        Settings.borderThickness)

    if not Settings.astigmatismMode then
        surface.SetDrawColor(0, 0, 0, 220)
    else
        surface.SetDrawColor(235, 235, 235, 240)
    end

    drawRect(Settings.mapXpos + Settings.borderThickness, Settings.mapYpos + Settings.borderThickness, noBoundMapSize,
        noBoundMapSize)
end

--- Draws the player indicator triangle itself.
--- The coordinates are defined in a pre-computed indicator table.
local function drawPlayerIndicator()
    surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    surface.DrawPoly(Settings.playerIndicatorTable)
end

--- Draws the north point indicator, which is a circle at the edges of the map pointing towards North
local function drawNorthPoint()
    -- Early return in case the player is still loading
    if not IsValid(ply) then return end
    local angY = rad(ply:EyeAngles().y - 90)
    local cosA = cos(angY)
    local sinA = sin(angY)

    local scale = Settings.halfMapSize / max(abs(cosA), abs(sinA))

    local renderX = Settings.mapCenterX + (cosA * scale);
    local renderY = Settings.mapCenterY + (sinA * scale);

    surface.SetDrawColor(128, 0, 0, 255)
    draw.Circle(renderX, renderY, 10, 10)

    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, colors.PURE_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

--- Helper to update the map size variables when it gets changed on the Settings Panel
function Map.updateSize()
    noBoundMapSize = Settings.mapSize - (Settings.borderThickness * 2)
    mapBound = Settings.halfMapSize - Settings.borderThickness
end

--- Wraps all the necessary drawing calls for rendering the map itself
function Map.Render()
    drawMapBox()
    debug.drawInfo()
    pointRender()
    drawPlayerIndicator()
    drawNorthPoint()
end

return Map
