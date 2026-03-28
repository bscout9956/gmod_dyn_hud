local colors = include("../colors.lua")
local renderCommon = include("common.lua")
local BMap = {}

-- Optimization locals
local rad = math.rad
local cos = math.cos
local sin = math.sin
local drawRect = surface.DrawRect

local hudBoundX = Config.bigMapHalfSizeX - Config.borderThickness
local hudBoundY = Config.bigMapHalfSizeY - Config.borderThickness
local mapBounds = { x = hudBoundX, y = hudBoundY }
local noBoundHudSizeX = Config.bigMapSizeX - (Config.borderThickness * 2)
local noBoundHudSizeY = Config.bigMapSizeY - (Config.borderThickness * 2)

local pIndicatorSize = Config.playerIndicatorSize
local pIndicatorNotch = Config.playerIndicatorNotch

local baseIndicatorPos = {
    { x = 0,                  y = -pIndicatorSize },                                     -- 1. Top Tip
    { x = pIndicatorSize,     y = pIndicatorSize },                                      -- 2. Bottom Right
    { x = 0,                  y = pIndicatorSize - (pIndicatorNotch * pIndicatorSize) }, -- 3. The Notch (Center Base)
    { x = 0 - pIndicatorSize, y = pIndicatorSize },                                      -- 4. Bottom Left
    { x = 0,                  y = -pIndicatorSize },                                     -- 5. Back to Top Tip
}


local function updateBigMapPIndicator()
    local ang = LocalPlayer():EyeAngles().y
    local radA = rad(-ang + 90)
    local cosA = cos(radA)
    local sinA = sin(radA)

    local centerX = Config.bigMapCenterX
    local centerY = Config.bigMapCenterY

    for i, point in ipairs(baseIndicatorPos) do
        local rotX = point.x * cosA - point.y * sinA
        local rotY = point.x * sinA + point.y * cosA

        Config.bigMapPlayerIndicatorTable[i].x = centerX + rotX
        Config.bigMapPlayerIndicatorTable[i].y = centerY + rotY
    end
end

local function drawPlayerIndicator()
    surface.SetDrawColor(colors.SOFT_BLUE) -- Smoother blue
    draw.NoTexture()
    updateBigMapPIndicator()
    surface.DrawPoly(Config.bigMapPlayerIndicatorTable)
end

local function drawBox()
    local colorRect = Config.astigmatismMode and colors.ASH or colors.WHITE

    surface.SetDrawColor(colorRect)

    surface.DrawOutlinedRect(
        Config.bigMapXpos, Config.bigMapYpos,   -- XY position
        Config.bigMapSizeX, Config.bigMapSizeY, -- Width and Height
        Config.borderThickness
    )

    local colorFill = Config.astigmatismMode and colors.SOFT_GRAY or colors.BLACK
    colorFill.a = 220
    surface.SetDrawColor(colorFill)

    drawRect(
        Config.bigMapXpos + Config.borderThickness, Config.bigMapYpos + Config.borderThickness, -- XY position with border offset
        noBoundHudSizeX,
        noBoundHudSizeY                                                                         -- Width and Height without borders
    )
end

function BMap.Render()
    drawBox()
    renderCommon.pointRender(mapBounds, { x = Config.bigMapCenterX, y = Config.bigMapCenterY }, false)
    drawPlayerIndicator()
end

return BMap
