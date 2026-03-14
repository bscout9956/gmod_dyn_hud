Settings = include("settings.lua")
UiSettings = include("ui_settings.lua")
local bmap = include("big_map.lua")
local map = include("map.lua")

local bmapVisible = false

-- GMOD Dynamic HUD v0.5 by BlackScout/bscout9956
-- Data
Points = {}
local ply = LocalPlayer()

-- HUD Parameters
local mapResolution = Settings.uiResolution / 100

local pointsLookup = {}

-- Localization for Math Functions
local cos = math.cos
local sin = math.sin
local rad = math.rad
local round = math.floor

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

local function switchMaps()
    bmapVisible = not bmapVisible
end


-- Hooks and other shit
hook.Add("HUDPaint", "HUDMain", function()
    if not bmapVisible then
        map.Render()
    else
        bmap.Render()
    end
    registerPlayerPos()
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
    if input.IsKeyDown(KEY_T) and curTime > nextChange then
        switchMaps()
        nextChange = curTime + 0.25
    end
end)

hook.Add("OnScreenSizeChanged", "UIRefresh", function()
    print("DynHUD: Screen Resolution change detected, refreshing UI elements...")
    UiSettings.refreshValues()
end)
