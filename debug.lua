local colors = include("colors.lua")
local utils = include("utils.lua")

local Debug = {}

--- Draws whether or not astigmatism mode is enabled.
local function drawAstigmatismInfo()
    return "Astigmatism Mode: " .. utils.boolToStr(Settings.astigmatismMode)
end

--- Draws the current zoom level on the HUD
local function drawZoomInfo()
    return "Zoom Level: " .. Settings.uiZoomLevel
end

--- Draws the player's current coordinates on the HUD
local function drawCoordinates()
    local pPos = LocalPlayer():GetPos()
    local floor = math.floor
    return "X: " .. floor(pPos.x) .. " Y: " .. floor(pPos.y) .. " Z: " .. floor(pPos.z)
end

--- Draws the number of points
local function drawPCount()
    return "Number of Points: " .. #Points
end

-- Draw all debug/HUD information
function Debug.drawInfo()
    local funcs = { drawCoordinates, drawAstigmatismInfo, drawZoomInfo, drawPCount }
    for index, func in ipairs(funcs) do
        draw.SimpleText(func(), "DermaDefault", Settings.hudXpos + (Settings.spacing * 0.5),
            Settings.hudSize + (Settings.hudYpos * index) + Settings.spacing, colors.PURE_WHITE, TEXT_ALIGN_LEFT,
            TEXT_ALIGN_TOP)
    end
end

return Debug
