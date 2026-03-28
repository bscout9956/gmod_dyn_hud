local hudinfo = include("../hud_info.lua")
local colors = include("../colors.lua")
local utils = include("../utils.lua")
local uiUtils = include("../ui/utils.lua")
local geometry = include("../geometry.lua")

---@type table
local Map = {}

-- Localization for surface stuff
local drawRect = surface.DrawRect

---@type number
local noBoundMapSize = Config.mapSize - (Config.borderThickness * 2)
---@type number
local mapBound = Config.halfMapSize - Config.borderThickness
---@type table
local mapBounds = { x = mapBound, y = mapBound }

-- Localization for Math Functions
local abs = math.abs
local cos = math.cos
local sin = math.sin

--- Renders all the points for the registered player positions applying rotation and checking Map Bounds.
local function pointRender()
    local renderStart = SysTime()
    local playerPos = LocalPlayer():GetPos()

    draw.NoTexture()

    utils.drawPoints(playerPos, mapBounds, { x = Config.mapCenterX, y = Config.mapCenterY }, true)
    if Config.showFrameTimeDebug then
        uiUtils.PointRenderDebug(renderStart)
    end
end

--- Draws the map box including its outline and background.
--- Applies different colors based on the astigmatism mode setting.
local function drawMapBox()
    local colorRect = Config.astigmatismMode and colors.ASH or colors.WHITE
    surface.SetDrawColor(colorRect)
    surface.DrawOutlinedRect(Config.mapXpos, Config.mapYpos, Config.mapSize, Config.mapSize,
        Config.borderThickness)

    local colorRectFill = Config.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorRectFill.a = 220
    surface.SetDrawColor(colorRectFill)

    drawRect(Config.mapXpos + Config.borderThickness, Config.mapYpos + Config.borderThickness, noBoundMapSize,
        noBoundMapSize)
end

--- Draws the map as a circle instead of a square, if the roundMode setting is enabled.
local function drawMapCircle()
    local color = Config.astigmatismMode and colors.SOFT_GRAY or colors.WHITE

    surface.DrawCircle(
        Config.mapCenterX,
        Config.mapCenterY,
        Config.mapSize / 2, -- radius
        color.r, color.g, color.b, color.a
    )

    local colorFill = Config.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorFill.a = 220
    surface.SetDrawColor(colorFill)

    geometry.DrawCircle(Config.mapCenterX, Config.mapCenterY, Config.mapSize / 2, 67)
end

--- Draws the player indicator triangle itself.
--- The coordinates are defined in a pre-computed indicator table.
local function drawPlayerIndicator()
    surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    surface.DrawPoly(Config.playerIndicatorTable)
end

--- Draws the north point indicator, which is a circle at the edges of the map pointing towards North
local function drawNorthPoint()
    local angle = math.rad(LocalPlayer():EyeAngles().y - 90)
    local sinAngle = sin(angle)
    local cosAngle = cos(angle)

    local renderX = (cosAngle * Config.halfMapSize) + Config.mapCenterX
    local renderY = (sinAngle * Config.halfMapSize) + Config.mapCenterY

    surface.SetDrawColor(128, 0, 0, 255)
    geometry.DrawCircle(renderX, renderY, 10, 10)

    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, colors.PURE_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Helper function to render the lines for the compass, used in the square map mode
-- Helps keep the code tidy
local function renderLines(offset, range, yShift)
    if abs(offset) <= range then
        local relX = -(offset / range)
        local posX = Config.mapCenterX + (relX * Config.halfMapSize)
        local posY = Config.mapCenterY + Config.halfMapSize + 1
        local alpha = 1 - abs(relX)

        local color = Config.astigmatismMode and colors.SOFT_GRAY or colors.WHITE
        surface.SetDrawColor(color.r, color.g, color.b, color.a * alpha)
        surface.DrawLine(posX, posY, posX, yShift)
    end
end

local function renderLetters(offset, range, label)
    if abs(offset) <= range then
        local relX = -(offset / range)
        local posX = Config.mapCenterX + (relX * Config.halfMapSize)
        local posY = Config.mapCenterY + Config.halfMapSize
        local alpha = 1 - abs(relX)
        local color = Config.astigmatismMode and colors.SOFT_GRAY or colors.WHITE

        local textColor = Color(color.r, color.g, color.b, color.a * alpha)
        draw.SimpleText(label, "CloseCaption_Normal", posX, posY + 10, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
end

-- Draws a compass underneath the map, showing NSWE directions
-- Is disabled when using the round map.
local function drawCompass()
    local pAngle = LocalPlayer():EyeAngles().y
    local range = 120 -- TURN INTO SETTING

    for angle = -360, 360, 90 do
        local offset = math.NormalizeAngle(angle - pAngle)
        renderLines(offset, range, Config.mapCenterY + Config.halfMapSize + 15)
    end

    -- Minor ticks every 5°
    for angle = -360, 360, 5 do
        local offset = math.NormalizeAngle(angle - pAngle)
        renderLines(offset, range, Config.mapCenterY + Config.halfMapSize + 5)
    end

    local cardinals = { [0] = "N", [90] = "W", [180] = "S", [-90] = "E" }

    for angle, label in pairs(cardinals) do
        local offset = math.NormalizeAngle(angle - pAngle)
        renderLetters(offset, range, label)
    end
end

local function drawCompassBox()
    local color = Config.astigmatismMode and colors.ASH or colors.WHITE
    surface.SetDrawColor(color)

    surface.DrawOutlinedRect(
        Config.mapXpos,                                             -- x
        (Config.mapYpos + Config.mapSize) - Config.borderThickness, -- y
        Config.mapSize, Config.spacing * 2,                         -- width, height
        Config.borderThickness                                      -- thickness
    )

    local colorRect = Config.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorRect.a = 220
    surface.SetDrawColor(colorRect)

    drawRect(
        Config.mapXpos + Config.borderThickness,                      -- x
        (Config.mapYpos + Config.mapSize) - Config.borderThickness,   -- y
        noBoundMapSize, (Config.spacing * 2) - Config.borderThickness -- width, height
    )
end

--- Helper to update the map size variables when it gets changed on the Settings Panel
function Map.updateSize()
    noBoundMapSize = Config.mapSize - (Config.borderThickness * 2)
    mapBound = Config.halfMapSize - Config.borderThickness
    mapBounds = { x = mapBound, y = mapBound }
end

--- Wraps all the necessary drawing calls for rendering the map itself
function Map.Render()
    if Config.roundMode then
        drawMapCircle()
        pointRender()
        drawNorthPoint()
        hudinfo.drawInfo(false)
    else
        drawMapBox()
        pointRender()
        drawCompassBox()
        drawCompass()
        hudinfo.drawInfo(true)
    end
    drawPlayerIndicator()
end

return Map
