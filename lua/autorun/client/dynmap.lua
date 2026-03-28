print("DynMap: Initializing client-side script...")
print("DynMap: Loading configuration...")
Config = include("dynmap/config.lua")
print("DynMap: Loading settings...")
Settings = include("dynmap/settings.lua")
print("DynMap: Loading UI settings...")
UiSettings = include("dynmap/ui/settings.lua")
print("DynMap: Loading map renderer...")
local bmap = include("dynmap/renderer/big_map.lua")
print("DynMap: Loading main map renderer...")
Map = include("dynmap/renderer/map.lua")


local bmapVisible = false

-- GMOD Dynamic Map v0.6 by BlackScout/bscout9956
-- Data
Points = {} -- TODO: I think this shouldn't be a global variable exposed like this, if you're reading this, don't mess it up lmao

-- HUD Parameters
---@type table
local pointsLookup = {}

-- Localization for Math Functions

local round = math.floor

local function changeAstimagtismMode()
    Settings.astigmatismMode = not Settings.astigmatismMode
end

--- Adds a point to the points table if it doesn't already exist.
--- Avoids adding unnecessary points, helps with performance.
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

--- Register the current player position in the points table, with some precision reduction
local function registerPlayerPos()
    local pos = LocalPlayer():GetPos()
    -- We drop some precision for X and Y because we don't really need that much precision honestly
    -- It also looks really cool lmao
    addPoint(
        round(pos.x * Settings.mapResolution) / Settings.mapResolution,
        round(pos.y * Settings.mapResolution) / Settings.mapResolution,
        round(pos.z * Settings.mapResolution) / Settings.mapResolution
    )
end

--- Helper to switch between the big map and the regular map
local function switchMaps()
    bmapVisible = not bmapVisible
end

-- Hooks and other shit

local hooks = hook.GetTable()

function StartHooks()
    if hooks["HUDPaint"]["DynMap_Render"] then
        hook.Remove("HUDPaint", "DynMap_Render")
        print("DynMap: Existing HUDPaint hook found, replacing it with the new one...")
    end

    hook.Add("HUDPaint", "DynMap_Render", function()
        if not bmapVisible then
            Map.Render()
        else
            bmap.Render()
        end
        registerPlayerPos()
    end)

    if hooks["Think"]["DynMap_Input"] then
        hook.Remove("Think", "DynMap_Input")
        print("DynMap: Existing Think hook found, replacing it with the new one...")
    end

    local nextChange = 0
    hook.Add("Think", "DynMap_Input", function()
        local curTime = CurTime()
        if input.IsKeyDown(KEY_Z) and curTime > nextChange then
            Settings.ChangeZoom()
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

    if hooks["OnScreenSizeChanged"] then
        if hooks["OnScreenSizeChanged"]["DynMap_UIRefresh"] then
            hook.Remove("OnScreenSizeChanged", "DynMap_UIRefresh")
            print("DynMap: Existing OnScreenSizeChanged hook found, replacing it with the new one...")
        end
    end


    hook.Add("OnScreenSizeChanged", "DynMap_UIRefresh", function()
        print("DynHUD: Screen Resolution change detected, refreshing UI elements...")
        UiSettings.refreshValues()
    end)
end

StartHooks()
