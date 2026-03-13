local colors = include("colors.lua")
Settings = include("settings.lua")
UiSettings = include("ui_settings.lua")
local debug = include("debug.lua")

-- GMOD Dynamic HUD v0.5 by BlackScout/bscout9956
-- Data
Points = {}
local ply = LocalPlayer()

-- HUD Parameters
local hudBound = Settings.halfSize - Settings.hudThickness
local noBoundHudSize = Settings.hudSize - (Settings.hudThickness * 2)
local mapResolution = Settings.uiResolution / 100

local pointsLookup = {}

-- Localization for Math Functions
local abs = math.abs
local cos = math.cos
local sin = math.sin
local rad = math.rad
local max = math.max
local round = math.floor

-- Localization for surface stuff
local drawRect = surface.DrawRect
local setDrawColor = surface.SetDrawColor


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
        local a = rad((i / seg) * -360)
        table.insert(cir, {
            x = x + sin(a) * radius,
            y = y + cos(a) * radius,
            u = (sin(a) * .5) + 0.5,
            v = (cos(a) * .5) + 0.5
        })
    end

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(cir, {
        x = x + sin(a) * radius,
        y = y + cos(a) * radius,
        u = (sin(a) * .5) + 0.5,
        v = (cos(a) * .5) + 0.5
    })

    surface.DrawPoly(cir)
end

local function changeAstimagtismMode()
    Settings.astigmatismMode = not Settings.astigmatismMode
end

--- Adds a point to the points table if it doesn't already exist
---@param x number @X coordinate
---@param y number @Y coordinate
---@param z number @Z coordinate
local function addPoint(x, y, z)
    local key = x .. "_" .. y .. "_" .. z
    if not pointsLookup[key] then
        pointsLookup[key] = true
        table.insert(Points, {
            x = x,
            y = y,
            z = z
        })
    end
end

local function registerPlayerPos()
    local pos = ply:GetPos()
    -- We drop some precision for X and Y because we don't really need that much precision honestly
    -- It also looks really cool lmao
    addPoint(round(pos.x * mapResolution) / mapResolution, round(pos.y * mapResolution) / mapResolution,
        round(pos.z * mapResolution) / mapResolution)
end


local function drawHUDBox()
    if not Settings.astigmatismMode then
        surface.SetDrawColor(255, 255, 255, 255)
    else
        surface.SetDrawColor(60, 60, 60, 255)
    end

    surface.DrawOutlinedRect(Settings.hudXpos, Settings.hudYpos, Settings.hudSize, Settings.hudSize,
        Settings.hudThickness)

    if not Settings.astigmatismMode then
        surface.SetDrawColor(0, 0, 0, 220)
    else
        surface.SetDrawColor(235, 235, 235, 240)
    end

    drawRect(Settings.hudXpos + Settings.hudThickness, Settings.hudYpos + Settings.hudThickness, noBoundHudSize,
        noBoundHudSize)
end

-- Draws the player indicator triangle
local function drawPlayerIndicator()
    surface.SetDrawColor(0, 100, 200, 255) -- Smoother blue
    surface.DrawPoly(Settings.playerIndicatorTable)
end

local function mapRender()
    local renderStart = SysTime()
    local pPos = ply:GetPos()
    local angY = ply:EyeAngles().y

    local radA = rad(-angY + 90) -- We rotate so 90 is upwards/north
    local cosA = cos(radA)
    local sinA = sin(radA)

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

            local rotX = relX * cosA - relY * sinA
            local rotY = relX * sinA + relY * cosA

            if abs(rotX) < hudBound and abs(rotY) < hudBound then
                local renderX = Settings.hudCenterX + rotX
                local renderY = Settings.hudCenterY - rotY

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

local function northPointRender()
    local angY = rad(ply:EyeAngles().y - 90)
    local cosA = cos(angY)
    local sinA = sin(angY)

    local scale = Settings.halfSize / max(abs(cosA), abs(sinA))

    local renderX = Settings.hudCenterX + (cosA * scale);
    local renderY = Settings.hudCenterY + (sinA * scale);

    surface.SetDrawColor(128, 0, 0, 255)
    draw.Circle(renderX, renderY, 10, 10)

    draw.SimpleText("N", "DermaDefaultBold", renderX, renderY, colors.PURE_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Hooks and other shit

hook.Add("HUDPaint", "HUDMain", function()
    drawHUDBox()
    debug.drawInfo()
    drawPlayerIndicator()
    registerPlayerPos()
    mapRender()
    northPointRender()
end)

local nextChange = 0
hook.Add("Think", "Zoomer", function()
    local curTime = CurTime()
    if input.IsKeyDown(KEY_Z) and curTime > nextChange then
        Settings.changeZoom()
        nextChange = curTime + 0.009
    end
    if input.IsKeyDown(KEY_X) and curTime > nextChange then
        changeAstimagtismMode()
        nextChange = curTime + 0.2
    end
    if input.IsKeyDown(KEY_M) and curTime > nextChange and Settings.settingsFramePresent == false then
        Settings.OpenDynHudSettings()
        nextChange = curTime + 0.5 -- We make it real slow lmao
    end
end)

hook.Add("OnScreenSizeChanged", "UIRefresh", function()
    print("DynHUD: Screen Resolution change detected, refreshing UI elements...")
    UiSettings.refreshValues()
end)
