-- GMOD Dynamic HUD v0.2 by BlackScout/bscout9956

-- Data
points = {}
zoomLevel = 0.5

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

-- Taken from: https://wiki.facepunch.com/gmod/surface.DrawPoly
-- Why isn't this included bro? It's not bloat, it's useful lmao
function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function changeZoom()
    if zoomLevel >= 1 then
        zoomLevel = 0.1
    else
        zoomLevel = zoomLevel + 0.01
    end
end

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

function boolToStr(value)
    if value then
        return "On"
    else
        return "Off"
    end
end


function drawInfo()
    local infoText = "Zoom Level: " .. zoomLevel
    draw.SimpleText(infoText, "DermaDefault", xPos, size + yPos + yPos, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function drawPlayerIndicator()
    surface.SetDrawColor(255, 255, 0, 200) -- yellow
    surface.DrawPoly(playerIndicatorTable)
end

function mapRender()
    local pPos = ply:GetPos()
    local angY = ply:EyeAngles().y
    local radA = math.rad(-angY + 90) -- We rotate so 90 is upwards/north
    
    local cosA = math.cos(radA)
    local sinA = math.sin(radA)

    surface.SetDrawColor(255, 255, 255, 255)
    draw.NoTexture()

    for _, pos in pairs(points) do
        local relX = (pos.x - pPos.x) * zoomLevel
        local relY = (pos.y - pPos.y) * zoomLevel

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
    local angY = math.rad(ply:EyeAngles().y - 90)

    local radius = halfSize

    local dirX = math.cos(angY)
    local dirY = math.sin(angY)

    local limit = 1 / math.max(math.abs(dirX), math.abs(dirY))

    local renderX = hudCenterX + (dirX * radius * limit);
    local renderY = hudCenterY + (dirY * radius * limit);

    surface.SetDrawColor(0,0,0,255)
    draw.Circle(renderX, renderY, 10, 255)
    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Hook and other shit

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
end)