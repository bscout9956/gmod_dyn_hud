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

local hudBoundX = Settings.bigMapHalfSizeX - Settings.hudThickness
local hudBoundY = Settings.bigMapHalfSizeY - Settings.hudThickness
local noBoundHudSizeX = Settings.bigMapSizeX - (Settings.hudThickness * 2)
local noBoundHudSizeY = Settings.bigMapSizeY - (Settings.hudThickness * 2)
-- local mapResolution = Settings.uiResolution / 100

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

local function drawBox()
    if not Settings.astigmatismMode then
        surface.SetDrawColor(255, 255, 255, 255)
    else
        surface.SetDrawColor(60, 60, 60, 255)
    end

    surface.DrawOutlinedRect(Settings.bigMapXpos, Settings.bigMapYpos, Settings.bigMapSizeX, Settings.bigMapSizeY,
        Settings.hudThickness)

    if not Settings.astigmatismMode then
        surface.SetDrawColor(0, 0, 0, 220)
    else
        surface.SetDrawColor(235, 235, 235, 240)
    end

    drawRect(Settings.bigMapXpos + Settings.hudThickness, Settings.bigMapYpos + Settings.hudThickness, noBoundHudSizeX,
        noBoundHudSizeY)
end

function BMap.Render()
    drawBox()
    pointRender()
end

return BMap
