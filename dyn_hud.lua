-- GMOD Dynamic HUD v0.1.1 by BlackScout/bscout9956

-- Data
points = {}

-- HUD Parameters
local width = ScrW()
size = math.floor(0.125 * width)
halfSize = size / 2

thickness = 3
xPos = 20
yPos = 20

-- Auxiliary Variables and Globals

hudCenterX = xPos + (size / 2)
hudCenterY = yPos + (size / 2)

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
function round(n)
    return math.floor(n + 0.5)
end

function addPoint(x, y)
    if not hasPoint(x, y) then
        table.insert(points, {
            x = x,
            y = y
        })
    end
end

function hasPoint(x, y)
    for _, pt in ipairs(points) do
        if pt.x == x and pt.y == y then
            return true
        end
    end
    return false
end

function registerPlayerPos()
    local pos = ply:GetPos()
    addPoint(round(pos.x), round(pos.y)) -- We round first, we don't need extremely granular HUD points
end

function drawHUDBox()
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawOutlinedRect(xPos, yPos, size, size, thickness)

    surface.SetDrawColor(0, 0, 0, 220)
    surface.DrawRect(xPos + thickness, yPos + thickness, size - (thickness * 2), size - (thickness * 2))
end

function drawPlayerIndicator()
    surface.SetDrawColor(255, 255, 0, 200) -- yellow
    surface.DrawPoly(playerIndicatorTable)
end

function mapRender()
    local pPos = ply:GetPos()
    local yAngle = ply:EyeAngles().y
    local radA = math.rad(-yAngle + 90) -- We rotate so 90 is upwards/north
    
    local cosA = math.cos(radA)
    local sinA = math.sin(radA)

    surface.SetDrawColor(255, 255, 255, 255)
    draw.NoTexture()

    for _, pos in pairs(points) do
        local relX = pos.x - pPos.x
        local relY = pos.y - pPos.y

        local rotX = relX * cosA - relY * sinA -- renderX = hudCenterX + (pos.x - pPos.x)
        local rotY = relX * sinA + relY * cosA -- hudCenterY - (pos.y - pPos.y) -- We subtract Y because Source coordinate system
        
        local renderX = hudCenterX + rotX
        local renderY = hudCenterY - rotY

        if (math.abs(rotX) < halfSize) and (math.abs(rotY) < halfSize) then
            surface.DrawRect(renderX - 1, renderY - 1, 3, 3)
        end
    end
end

function northPointRender()
    local angY = ply:EyeAngles().y
    local radA = math.rad(-angY + 90)

    -- We need the distance, why? I don't know
    local northDist = radA - math.rad(90)

    surface.SetDrawColor(0,0,0,255)
    draw.NoTexture()

    local renderX = hudCenterX + northDist
    local renderY = hudCenterY - northDist

    print(renderX, renderY)

    surface.DrawRect(renderX, renderY, 10, 10)
end

-- Hook and other shit

hook.Add("HUDPaint", "HUDMain", function()
    drawHUDBox()
    drawPlayerIndicator()
    registerPlayerPos()
    mapRender()
    northPointRender()
end)
