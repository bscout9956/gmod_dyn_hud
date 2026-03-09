-- GMOD Dynamic HUD v0.3 by BlackScout/bscout9956
-- Data
points = {}
zoomLevel = 0.5
astigmatismMode = false
spacing = 20
margin = spacing

pure_white = Color(255, 255, 255)
soft_gray = Color(240, 240, 240)

-- HUD Parameters
local width = ScrW()
size = math.floor(0.125 * width)
halfSize = size / 2
thickness = 3
hudBound = halfSize - thickness
xPos = margin
yPos = margin
hudCenterX = xPos + halfSize
hudCenterY = yPos + halfSize

ply = LocalPlayer()

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

function changeZoom()
    if zoomLevel >= 1 then
        zoomLevel = 0.1
    else
        zoomLevel = zoomLevel + 0.01
    end
end

function changeAstimagtismMode()
    astigmatismMode = not astigmatismMode
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
    addPoint(round(pos.x / 10) * 10, round(pos.y / 10) * 10, round(pos.z))
end

function drawHUDBox()
    if not astigmatismMode then
        surface.SetDrawColor(255, 255, 255, 255)
    else
        surface.SetDrawColor(60, 60, 60, 255)
    end

    surface.DrawOutlinedRect(xPos, yPos, size, size, thickness)

    if not astigmatismMode then
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

--- Wrapper function to reduce font contrast when necessary
---@param text string @The text that will be fed to draw.SimpleText
---@param style string @The font style
---@param x number @ X Position
---@param y number @ Y Position
---@param align_x any @ Text Alignment on X Axis
---@param align_y any @ Text Alignment on Y Axis
function draw.SimpleAstigmatismText(text, style, x, y, align_x, align_y)
    if not astigmatismMode then
        draw.SimpleText(text, style, x, y, pure_white, align_x, align_y)
    else
        draw.SimpleText(text, style, x, y, soft_gray, align_x, align_y)
    end
end

--- Draws whether or not astigmatism mode is enabled.
---@param idx number @ Index for rendering info at the right spot
function drawAstigmatismInfo(idx)
    local astStr = boolToStr(astigmatismMode)

    local astigmatismModeStr = "Astigmatism Mode: " .. astStr
    draw.SimpleAstigmatismText(astigmatismModeStr, "DermaDefault", xPos + (spacing / 2), size + (yPos * idx) + spacing,
        TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

--- Draws the current zoom level on the HUD
---@param idx number @ Index for rendering info at the right spot
function drawZoomInfo(idx)
    local infoZoom = "Zoom Level: " .. zoomLevel
    draw.SimpleAstigmatismText(infoZoom, "DermaDefault", xPos + (spacing / 2), size + (yPos * idx) + spacing,
        TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end
--- Draws the player's current coordinates on the HUD
---@param idx number @ Index for rendering info at the right spot
function drawCoordinates(idx)
    local pPos = ply:GetPos()
    local floor = math.floor
    local infoCoords = "X: " .. floor(pPos.x) .. " Y: " .. floor(pPos.y) .. " Z: " .. floor(pPos.z)

    draw.SimpleAstigmatismText(infoCoords, "DermaDefault", xPos + (spacing / 2), size + (yPos * idx) + spacing,
        TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Helper functions for drawing the HUD and info
function drawInfo()
    drawZoomInfo(1)
    drawAstigmatismInfo(2)
    drawCoordinates(3)
end

-- Draws the player indicator triangle
function drawPlayerIndicator()
    if not astigmatismMode then
        surface.SetDrawColor(255, 255, 0, 200) -- Default Yellow
    else
        surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    end
    surface.DrawPoly(playerIndicatorTable)
end

function mapRender()
    -- Locals for optimization
    local zoomLevel = zoomLevel
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
    if astigmatismMode then
        r, g, b = 40, 40, 40
    end

    draw.NoTexture()

    for _, pos in pairs(points) do
        local diffZ = abs(pos.z - pPos.z)

        if diffZ < 80 then -- we don't perform any crazy arithmetic on points we're not drawing
            local alpha = 255 - (diffZ * 3.1875) -- 3.1875 aka 255/80 or the distance of the fade

            local relX = (pos.x - pPos.x) * zoomLevel
            local relY = (pos.y - pPos.y) * zoomLevel

            local rotX = relX * cosA - relY * sinA -- renderX = hudCenterX + (pos.x - pPos.x)
            local rotY = relX * sinA + relY * cosA -- hudCenterY - (pos.y - pPos.y) -- We subtract Y because Source coordinate system

            if abs(rotX) < hudBound and abs(rotY) < hudBound then
                local renderX = hudCenterX + rotX
                local renderY = hudCenterY - rotY

                setDrawColor(r, g, b, alpha)
                drawRect(renderX - 1, renderY - 1, 3, 3)
            end
        end
    end
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
    draw.Circle(renderX, renderY, 10, 255)

    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, pure_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
        nextChange = CurTime() + 0.2
    end
end)
