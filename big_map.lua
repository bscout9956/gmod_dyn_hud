local BMap = {}
local colors = include("colors.lua")

-- Optimization locals
local ply = LocalPlayer()
local rad = math.rad
local cos = math.cos
local sin = math.sin
local abs = math.abs
local setDrawColor = surface.SetDrawColor
local drawRect = surface.DrawRect

local hudBoundX = Settings.bigMapHalfSizeX - Settings.borderThickness
local hudBoundY = Settings.bigMapHalfSizeY - Settings.borderThickness
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
    local pPos = ply:GetPos()

    local r, g, b = 255, 255, 255
    if Settings.astigmatismMode then
        r, g, b = 40, 40, 40
    end

    draw.NoTexture()

    for _, pos in pairs(Points) do
        local diffZ = abs(pos.z - pPos.z)

        if diffZ < 500 then -- we don't perform any crazy arithmetic on points we're not drawing
            local alpha = 255 - (diffZ * 0.51)

            local relX = (pos.x - pPos.x) * Settings.mapZoomLevel
            local relY = (pos.y - pPos.y) * Settings.mapZoomLevel

            if abs(relX) < hudBoundX and abs(relY) < hudBoundY then
                local renderX = Settings.bigMapCenterX + relX
                local renderY = Settings.bigMapCenterY - relY

                setDrawColor(r, g, b, alpha)
                drawRect(renderX, renderY, 3, 3)
            end
        end
    end

    local renderEnd = SysTime()
    local frameTime = (renderEnd - renderStart) * 1000
    local timeDiff = string.format("%.2f ms", frameTime)

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
