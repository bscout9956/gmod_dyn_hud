local utils = include("utils.lua")
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
    local playerPos = ply:GetPos()

    local color = colors.WHITE

    if Settings.astigmatismMode then
        color = colors.SOFT_GRAY
    end

    draw.NoTexture()

    utils.drawPoints(playerPos, color, mapBounds, true)

    local renderEnd = SysTime()
    local frameTime = (renderEnd - renderStart) * 1000
    local timeDiff = string.format("%.2f ms", frameTime)
    -- TODO: Make this optional
    draw.SimpleText(timeDiff, "DermaDefaultBold", Settings.bigMapXpos + 30, Settings.bigMapYpos + 30, colors.GREEN,
        TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

local function updateBigMapPIndicator()
    local ang = ply:EyeAngles().y
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
    if not Settings.astigmatismMode then
        surface.SetDrawColor(255, 255, 255, 255)
    else
        surface.SetDrawColor(60, 60, 60, 255)
    end

    surface.DrawOutlinedRect(Settings.bigMapXpos, Settings.bigMapYpos, Settings.bigMapSizeX, Settings.bigMapSizeY,
        Settings.borderThickness)

    if not Settings.astigmatismMode then
        surface.SetDrawColor(0, 0, 0, 220)
    else
        surface.SetDrawColor(235, 235, 235, 240)
    end

    drawRect(Settings.bigMapXpos + Settings.borderThickness, Settings.bigMapYpos + Settings.borderThickness,
        noBoundHudSizeX,
        noBoundHudSizeY)
end

function BMap.Render()
    drawBox()
    pointRender()
    drawPlayerIndicator()
end

return BMap
