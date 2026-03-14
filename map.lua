local debug = include("debug.lua")
local colors = include("colors.lua")

local Map = {}

-- Localization for surface stuff
local drawRect = surface.DrawRect
local setDrawColor = surface.SetDrawColor

local noBoundHudSize = Settings.mapSize - (Settings.borderThickness * 2)
local hudBound = Settings.halfMapSize - Settings.borderThickness

-- Localization for Math Functions
local abs = math.abs
local cos = math.cos
local sin = math.sin
local rad = math.rad
local max = math.max

local ply = LocalPlayer()

local r, g, b = 255, 255, 255

local function pointRender()
    local renderStart = SysTime()
    local pPos = ply:GetPos()
    local angY = ply:EyeAngles().y

    local radA = rad(-angY + 90) -- We rotate so 90 is upwards/north
    local cosA = cos(radA)
    local sinA = sin(radA)

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

            local rotX = relX * cosA - relY * sinA
            local rotY = relX * sinA + relY * cosA

            if abs(rotX) < hudBound and abs(rotY) < hudBound then
                local renderX = Settings.mapCenterX + rotX
                local renderY = Settings.mapCenterY - rotY

                setDrawColor(r, g, b, alpha)
                drawRect(renderX, renderY, 3, 3)
            end
        end
    end

    local renderEnd = SysTime()
    local frameTime = (renderEnd - renderStart) * 1000
    local timeDiff = string.format("%.2f ms", frameTime)

    draw.SimpleText(timeDiff, "DermaDefaultBold", 30, 30, colors.GREEN, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

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

    drawRect(Settings.mapXpos + Settings.borderThickness, Settings.mapYpos + Settings.borderThickness, noBoundHudSize,
        noBoundHudSize)
end

-- Draws the player indicator triangle
local function drawPlayerIndicator()
    surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    surface.DrawPoly(Settings.playerIndicatorTable)
end

local function drawNorthPoint()
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

function Map.Render()
    drawMapBox()
    debug.drawInfo()
    pointRender()
    drawPlayerIndicator()
    drawNorthPoint()
end

return Map
