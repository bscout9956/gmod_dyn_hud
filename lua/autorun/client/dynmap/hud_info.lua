local colors = include("colors.lua")
local utils = include("utils.lua")

local HudInfo = {}

--- Draws whether or not astigmatism mode is enabled.
local function drawAstigmatism()
    return "Astigmatism Mode: " .. utils.boolToStr(Config.astigmatismMode)
end

--- Draws the current zoom level on the HUD
local function drawZoom()
    return "Zoom Level: " .. Config.uiZoomLevel
end

--- Draws the player's current coordinates on the HUD
local function drawCoordinates()
    local pPos = LocalPlayer():GetPos()
    local floor = math.floor
    return "X: " .. floor(pPos.x) .. " Y: " .. floor(pPos.y) .. " Z: " .. floor(pPos.z)
end

--- Draws the number of points
local function drawPointCount()
    return "Number of Points: " .. #Points
end

-- Draw all debug/HUD information
function HudInfo.draw(offset)
    local yOffset = Config.spacing

    -- Offset means we're using the square map with the compass below
    if offset then
        yOffset = yOffset + (2 * Config.spacing)
    end

    local funcs = { drawCoordinates, drawAstigmatism, drawZoom, drawPointCount }
    for index, func in ipairs(funcs) do
        draw.SimpleText(
            func(),
            "DermaDefault",
            Config.mapXpos + (Config.spacing * 0.5),
            Config.mapSize + (Config.mapYpos * index) + yOffset,
            colors.PURE_WHITE,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_TOP
        )
    end
end

return HudInfo
