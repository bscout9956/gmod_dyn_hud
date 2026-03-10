local colors = include("colors.lua")
local settings = include("settings.lua")
-- GMOD Dynamic HUD v0.3 by BlackScout/bscout9956
-- Data
points = {}
ply = LocalPlayer()

-- HUD Parameters
local width = ScrW()
spacing = 20
margin = spacing
size = math.floor(0.125 * width)
halfSize = size / 2
thickness = 3
hudBound = halfSize - thickness
xPos = margin
yPos = margin
hudCenterX = xPos + halfSize
hudCenterY = yPos + halfSize
mapResolution = settings.uiResolution / 100

local pointsLookup = {}
local playerIndicatorSize = 18

playerIndicatorTable = {{
    x = hudCenterX - playerIndicatorSize,
    y = hudCenterY + playerIndicatorSize,
    u = 0,
    v = 0
}, {
    x = hudCenterX,
    y = hudCenterY - playerIndicatorSize,
    u = 0,
    v = 0
}, {
    x = hudCenterX + playerIndicatorSize,
    y = hudCenterY + playerIndicatorSize,
    u = 0,
    v = 0
}, {
    x = hudCenterX - playerIndicatorSize,
    y = hudCenterY + playerIndicatorSize,
    u = 0,
    v = 0
}}

funcs = {drawZoomInfo, drawAstigmatismInfo, drawCoordinates, drawPCount}

-- Functions

-- Taken from: https://wiki.facepunch.com/gmod/surface.DrawPoly
-- Why isn't this included bro? It's not bloat, it's useful lmao
function draw.Circle(x, y, radius, seg)
    local cir = {}

    table.insert(cir, {
        x = x,
        y = y,
        u = 0.5,
        v = 0.5
    })

    local cos, sin = math.cos, math.sin
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, {
            x = x + sin(a) * radius,
            y = y + cos(a) * radius,
            u = sin(a) / 2 + 0.5,
            v = cos(a) / 2 + 0.5
        })
    end

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(cir, {
        x = x + math.sin(a) * radius,
        y = y + math.cos(a) * radius,
        u = math.sin(a) / 2 + 0.5,
        v = math.cos(a) / 2 + 0.5
    })

    surface.DrawPoly(cir)
end

function changeAstimagtismMode()
    settings.astigmatismMode = not settings.astigmatismMode
end

--- Adds a point to the points table if it doesn't already exist
---@param x number @X coordinate
---@param y number @Y coordinate
---@param z number @Z coordinate
function addPoint(x, y, z)
    local key = x .. "_" .. y .. "_" .. z
    if not pointsLookup[key] then
        pointsLookup[key] = true
        table.insert(points, {
            x = x,
            y = y,
            z = z
        })
    end
end

function registerPlayerPos()
    local pos = ply:GetPos()
    local round = math.floor
    -- We drop some precision for X and Y because we don't really need that much precision honestly
    -- It also looks really cool lmao
    addPoint(round(pos.x * mapResolution) / mapResolution, round(pos.y * mapResolution) / mapResolution,
        round(pos.z * mapResolution) / mapResolution)
end

function drawHUDBox()
    if not settings.astigmatismMode then
        surface.SetDrawColor(255, 255, 255, 255)
    else
        surface.SetDrawColor(60, 60, 60, 255)
    end

    surface.DrawOutlinedRect(xPos, yPos, size, size, thickness)

    if not settings.astigmatismMode then
        surface.SetDrawColor(0, 0, 0, 220)
    else
        surface.SetDrawColor(235, 235, 235, 240)
    end

    surface.DrawRect(xPos + thickness, yPos + thickness, size - (thickness * 2), size - (thickness * 2))
end

--- Converts a boolean value to a string for display purposes
---@param value boolean @The boolean value to convert to a string
function boolToStr(value)
    if value then
        return "On"
    else
        return "Off"
    end
end

-- DRY HELL INCOMING:

--- Draws whether or not astigmatism mode is enabled.
function drawAstigmatismInfo()
    return "Astigmatism Mode: " .. boolToStr(settings.astigmatismMode)
end

--- Draws the current zoom level on the HUD
function drawZoomInfo()
    return "Zoom Level: " .. settings.uiZoomLevel
end

--- Draws the player's current coordinates on the HUD
function drawCoordinates()
    local pPos = ply:GetPos()
    local floor = math.floor
    return "X: " .. floor(pPos.x) .. " Y: " .. floor(pPos.y) .. " Z: " .. floor(pPos.z)
end

--- Draws the number of points
function drawPCount()
    return "Number of Points: " .. #points
end

-- Draw all debug/HUD information
function drawInfo()
    for index, func in ipairs(funcs) do
        draw.SimpleText(func(), "DermaDefault", xPos + (spacing * 0.5), size + (yPos * index) + spacing,
            colors.PURE_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

-- Draws the player indicator triangle
function drawPlayerIndicator()
    surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    surface.DrawPoly(playerIndicatorTable)
end

function mapRender()
    local renderStart = SysTime()
    -- Locals for optimization
    local mapZoomLevel = mapZoomLevel
    local hudBound = hudBound

    -- Math stuff
    local abs = math.abs
    local cos = math.cos
    local sin = math.sin
    local rad = math.rad
    local clamp = math.Clamp

    -- Render/Surface stuff
    local drawRect = surface.DrawRect
    local setDrawColor = surface.SetDrawColor
    -- End of optimization fluff
    local pPos = ply:GetPos()
    local angY = ply:EyeAngles().y

    local radA = rad(-angY + 90) -- We rotate so 90 is upwards/north
    local cosA = cos(radA)
    local sinA = sin(radA)

    local r, g, b = 255, 255, 255
    if settings.astigmatismMode then
        r, g, b = 40, 40, 40
    end

    draw.NoTexture()

    for _, pos in pairs(points) do
        local diffZ = abs(pos.z - pPos.z)

        if diffZ < 500 then -- we don't perform any crazy arithmetic on points we're not drawing
            local alpha = 255 - (diffZ * 0.51)

            local relX = (pos.x - pPos.x) * settings.mapZoomLevel
            local relY = (pos.y - pPos.y) * settings.mapZoomLevel

            local rotX = relX * cosA - relY * sinA -- renderX = hudCenterX + (pos.x - pPos.x)
            local rotY = relX * sinA + relY * cosA -- hudCenterY - (pos.y - pPos.y) -- We subtract Y because Source coordinate system

            if abs(rotX) < hudBound and abs(rotY) < hudBound then
                local renderX = hudCenterX + rotX
                local renderY = hudCenterY - rotY

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

function northPointRender()
    local angY = math.rad(ply:EyeAngles().y - 90)

    local radius = halfSize

    local dirX = math.cos(angY)
    local dirY = math.sin(angY)

    local limit = 1 / math.max(math.abs(dirX), math.abs(dirY))

    local renderX = hudCenterX + (dirX * radius * limit);
    local renderY = hudCenterY + (dirY * radius * limit);

    surface.SetDrawColor(128, 0, 0, 255)
    draw.Circle(renderX, renderY, 10, 10)

    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, colors.PURE_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Hooks and other shit

hook.Add("HUDPaint", "HUDMain", function()
    drawHUDBox()
    drawInfo()
    drawPlayerIndicator()
    registerPlayerPos()
    mapRender()
    northPointRender()
end)

local nextChange = 0
hook.Add("Think", "Zoomer", function(ply, button)
    local curTime = CurTime
    if input.IsKeyDown(KEY_Z) and curTime() > nextChange then
        changeZoom()
        nextChange = curTime() + 0.009
    end
    if input.IsKeyDown(KEY_X) and curTime() > nextChange then
        changeAstimagtismMode()
        nextChange = curTime() + 0.2
    end
    if input.IsKeyDown(KEY_M) and curTime() > nextChange and settings.settingsFramePresent == false then
        settingsFramePresent = settings:OpenDynHudSettings()
        nextChange = curTime() + 0.5 -- We make it real slow lmao
    end
end)
