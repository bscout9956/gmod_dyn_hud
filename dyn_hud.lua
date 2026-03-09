-- GMOD Dynamic HUD v0.2.3 by BlackScout/bscout9956
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
xPos = margin
yPos = margin

-- Auxiliary Variables and Globals

hudCenterX = xPos + (size / 2)
hudCenterY = yPos + (size / 2)
hudBound = halfSize - thickness

ply = LocalPlayer()
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
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
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

function round(n)
    return math.floor(n + 0.5)
end

--- Adds a point to the points table if it doesn't already exist
---@param x number @X coordinate
---@param y number @Y coordinate
---@param z number @Z coordinate
function addPoint(x, y, z)
    if not hasPoint(x, y, z) then
        table.insert(points, {
            x = x,
            y = y,
            z = z
        })
    end
end

--- Checks if the points table has a specific coordinate
---@param x number @X coordinate
---@param y number @Y coordinate
---@param z number @Z coordinate
function hasPoint(x, y, z)
    for _, pt in ipairs(points) do
        if pt.x == x and pt.y == y and pt.z == z then
            return true
        end
    end
    return false
end

function registerPlayerPos()
    local pos = ply:GetPos()
    addPoint(round(pos.x), round(pos.y), round(pos.z)) -- We round first, we don't need extremely granular HUD points
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
        surface.SetDrawColor(0, 100, 200, 255)
    end
    surface.DrawPoly(playerIndicatorTable)
end

function mapRender()
    local pPos = ply:GetPos()
    local angY = ply:EyeAngles().y

    -- Locals for optimization
    local zLevel = zoomLevel
    local abs = math.abs
    local cos = math.cos
    local sin = math.sin
    local rad = math.rad
    local clamp = math.Clamp
    local dR = surface.DrawRect
    local sdc = surface.SetDrawColor

    local radA = rad(-angY + 90) -- We rotate so 90 is upwards/north
    local cosA = cos(radA)
    local sinA = sin(radA)

    local r,g,b=255,255,255
    if astigmatismMode then
        r,g,b=40,40,40
    end

    local hudBound = hudBound

    draw.NoTexture()

    for _, pos in pairs(points) do
        local diffZ = abs(pos.z - pPos.z)

        if diffZ < 80 then -- we don't perform any crazy arithmetic on points we're not drawing
            local alpha = 255 - (diffZ * 3.1875) -- 3.1875 aka 255/80 or the distance of the fade
            
            local relX = (pos.x - pPos.x) * zLevel
            local relY = (pos.y - pPos.y) * zLevel

            local rotX = relX * cosA - relY * sinA -- renderX = hudCenterX + (pos.x - pPos.x)
            local rotY = relX * sinA + relY * cosA -- hudCenterY - (pos.y - pPos.y) -- We subtract Y because Source coordinate system

            if abs(rotX) < hudBound and abs(rotY) < hudBound then
                local renderX = hudCenterX + rotX
                local renderY = hudCenterY - rotY

                sdc(r, g, b, alpha)
                dR(renderX - 1, renderY - 1, 3, 3)
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

    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, pure_white, TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER)
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

hook.Add("Think", "Zoomer", function(ply, button)
    if input.IsKeyDown(KEY_Z) then
        changeZoom()
    end
    -- I need to figure out a way to do this that doesn't cause an epilepsy seizure to the user...
    -- DO NOT UNCOMMENT THIS IF YOU HAVE PHOTOSENSITIVITY
    -- if input.IsKeyDown(KEY_X) then
    --     changeAstimagtismMode()
    -- end
end)
