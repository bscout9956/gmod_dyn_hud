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
local noBoundMapSize = Settings.mapSize - (Settings.borderThickness * 2)
---@type number
local mapBound = Settings.halfMapSize - Settings.borderThickness
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

    utils.drawPoints(playerPos, mapBounds, { x = Settings.mapCenterX, y = Settings.mapCenterY }, true)
    if Settings.showFrameTimeDebug then
        uiUtils.PointRenderDebug(renderStart)
    end
end

--- Draws the map box including its outline and background.
--- Applies different colors based on the astigmatism mode setting.
local function drawMapBox()
    local colorRect = Settings.astigmatismMode and colors.ASH or colors.WHITE
    surface.SetDrawColor(colorRect)
    surface.DrawOutlinedRect(Settings.mapXpos, Settings.mapYpos, Settings.mapSize, Settings.mapSize,
        Settings.borderThickness)

    local colorRectFill = Settings.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorRectFill.a = 220
    surface.SetDrawColor(colorRectFill)

    drawRect(Settings.mapXpos + Settings.borderThickness, Settings.mapYpos + Settings.borderThickness, noBoundMapSize,
        noBoundMapSize)
end

--- Draws the map as a circle instead of a square, if the roundMode setting is enabled.
local function drawMapCircle()
    local color = Settings.astigmatismMode and colors.SOFT_GRAY or colors.WHITE

    surface.DrawCircle(
        Settings.mapCenterX,
        Settings.mapCenterY,
        Settings.mapSize / 2, -- radius
        color.r, color.g, color.b, color.a
    )

    local colorFill = Settings.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorFill.a = 220
    surface.SetDrawColor(colorFill)

    geometry.DrawCircle(Settings.mapCenterX, Settings.mapCenterY, Settings.mapSize / 2, 67)
end

--- Draws the player indicator triangle itself.
--- The coordinates are defined in a pre-computed indicator table.
local function drawPlayerIndicator()
    surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    surface.DrawPoly(Settings.playerIndicatorTable)
end

--- Draws the north point indicator, which is a circle at the edges of the map pointing towards North
local function drawNorthPoint()
    local angle = math.rad(LocalPlayer():EyeAngles().y - 90)
    local sinAngle = sin(angle)
    local cosAngle = cos(angle)

    local renderX = (cosAngle * Settings.halfMapSize) + Settings.mapCenterX
    local renderY = (sinAngle * Settings.halfMapSize) + Settings.mapCenterY

    surface.SetDrawColor(128, 0, 0, 255)
    geometry.DrawCircle(renderX, renderY, 10, 10)

    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, colors.PURE_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Helper function to render the lines for the compass, used in the square map mode
-- Helps keep the code tidy
local function renderLines(offset, range, yShift)
    if abs(offset) <= range then
        local relX = -(offset / range)
        local posX = Settings.mapCenterX + (relX * Settings.halfMapSize)
        local posY = Settings.mapCenterY + Settings.halfMapSize + 1
        local alpha = 1 - abs(relX)

        local color = Settings.astigmatismMode and colors.SOFT_GRAY or colors.WHITE
        surface.SetDrawColor(color.r, color.g, color.b, color.a * alpha)
        surface.DrawLine(posX, posY, posX, yShift)
    end
end

local function renderLetters(offset, range, label)
    if abs(offset) <= range then
        local relX = -(offset / range)
        local posX = Settings.mapCenterX + (relX * Settings.halfMapSize)
        local posY = Settings.mapCenterY + Settings.halfMapSize
        local alpha = 1 - abs(relX)
        local color = Settings.astigmatismMode and colors.SOFT_GRAY or colors.WHITE

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
        renderLines(offset, range, Settings.mapCenterY + Settings.halfMapSize + 15)
    end

    -- Minor ticks every 5°
    for angle = -360, 360, 5 do
        local offset = math.NormalizeAngle(angle - pAngle)
        renderLines(offset, range, Settings.mapCenterY + Settings.halfMapSize + 5)
    end

    local cardinals = { [0] = "N", [90] = "W", [180] = "S", [-90] = "E" }

    for angle, label in pairs(cardinals) do
        local offset = math.NormalizeAngle(angle - pAngle)
        renderLetters(offset, range, label)
    end
end

local function drawCompassBox()
    local color = Settings.astigmatismMode and colors.ASH or colors.WHITE
    surface.SetDrawColor(color)

    surface.DrawOutlinedRect(
        Settings.mapXpos,                                                 -- x
        (Settings.mapYpos + Settings.mapSize) - Settings.borderThickness, -- y
        Settings.mapSize, Settings.spacing * 2,                           -- width, height
        Settings.borderThickness                                          -- thickness
    )

    local colorRect = Settings.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorRect.a = 220
    surface.SetDrawColor(colorRect)

    drawRect(
        Settings.mapXpos + Settings.borderThickness,                      -- x
        (Settings.mapYpos + Settings.mapSize) - Settings.borderThickness, -- y
        noBoundMapSize, (Settings.spacing * 2) - Settings.borderThickness -- width, height
    )
end

--- Helper to update the map size variables when it gets changed on the Settings Panel
function Map.updateSize()
    noBoundMapSize = Settings.mapSize - (Settings.borderThickness * 2)
    mapBound = Settings.halfMapSize - Settings.borderThickness
    mapBounds = { x = mapBound, y = mapBound }
end

--- Wraps all the necessary drawing calls for rendering the map itself
function Map.Render()
    if Settings.roundMode then
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
