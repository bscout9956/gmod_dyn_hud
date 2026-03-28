local utils = include("utils.lua")
local uiUtils = include("ui_utils.lua")
local colors = include("colors.lua")
local BMap = {}

-- Optimization locals
local ply = LocalPlayer()
local rad = math.rad
local cos = math.cos
local sin = math.sin
local drawRect = surface.DrawRect

local hudBoundX = Settings.bigMapHalfSizeX - Settings.borderThickness
local hudBoundY = Settings.bigMapHalfSizeY - Settings.borderThickness
local mapBounds = { x = hudBoundX, y = hudBoundY }
local noBoundHudSizeX = Settings.bigMapSizeX - (Settings.borderThickness * 2)
local noBoundHudSizeY = Settings.bigMapSizeY - (Settings.borderThickness * 2)

local pIndicatorSize = Settings.playerIndicatorSize
local pIndicatorNotch = Settings.playerIndicatorNotch

local baseIndicatorPos = {
    { x = 0,                  y = -pIndicatorSize },                                     -- 1. Top Tip
    { x = pIndicatorSize,     y = pIndicatorSize },                                      -- 2. Bottom Right
    { x = 0,                  y = pIndicatorSize - (pIndicatorNotch * pIndicatorSize) }, -- 3. The Notch (Center Base)
    { x = 0 - pIndicatorSize, y = pIndicatorSize },                                      -- 4. Bottom Left
    { x = 0,                  y = -pIndicatorSize },                                     -- 5. Back to Top Tip
}


local function pointRender()
    local renderStart = SysTime()
    local playerPos = LocalPlayer():GetPos()

    draw.NoTexture()

    utils.drawPoints(playerPos, mapBounds, { x = Settings.bigMapCenterX, y = Settings.bigMapCenterY }, false)

    if Settings.showFrameTimeDebug then
        uiUtils.pointRenderDebug(renderStart)
    end
end

local function updateBigMapPIndicator()
    local ang = LocalPlayer():EyeAngles().y
    local radA = rad(-ang + 90)
    local cosA = cos(radA)
    local sinA = sin(radA)

    local centerX = Settings.bigMapCenterX
    local centerY = Settings.bigMapCenterY

    for i, point in ipairs(baseIndicatorPos) do
        local rotX = point.x * cosA - point.y * sinA
        local rotY = point.x * sinA + point.y * cosA

        Settings.bigMapPlayerIndicatorTable[i].x = centerX + rotX
        Settings.bigMapPlayerIndicatorTable[i].y = centerY + rotY
    end
end

local function drawPlayerIndicator()
    surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    draw.NoTexture()
    updateBigMapPIndicator()
    surface.DrawPoly(Settings.bigMapPlayerIndicatorTable)
end

local function drawBox()
    local colorRect = Settings.astigmatismMode and colors.ASH or colors.WHITE

    surface.SetDrawColor(colorRect)

    surface.DrawOutlinedRect(
        Settings.bigMapXpos, Settings.bigMapYpos,   -- XY position
        Settings.bigMapSizeX, Settings.bigMapSizeY, -- Width and Height
        Settings.borderThickness
    )

    local colorFill = Settings.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorFill.a = 220
    surface.SetDrawColor(colorFill)

    drawRect(
        Settings.bigMapXpos + Settings.borderThickness, Settings.bigMapYpos + Settings.borderThickness, -- XY position with border offset
        noBoundHudSizeX, noBoundHudSizeY                                                                -- Width and Height without borders
    )
end

function BMap.Render()
    drawBox()
    pointRender()
    drawPlayerIndicator()
end

return BMap
