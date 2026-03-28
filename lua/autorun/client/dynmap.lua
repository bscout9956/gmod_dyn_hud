-- GMOD Dynamic Map v0.10.0 by BlackScout/bscout9956
Config = include("dynmap/config.lua")
State = include("dynmap/state.lua")
Settings = include("dynmap/settings.lua")
UiSettings = include("dynmap/ui/settings.lua")
local bmap = include("dynmap/renderer/big_map.lua")
Map = include("dynmap/renderer/map.lua")
local inputHandler = include("dynmap/input.lua")

-- Localization for Math Functions
local round = math.floor



-- Hooks and other shit

local hooks = hook.GetTable()

function StartHooks()
    if hooks["HUDPaint"]["DynMap_Render"] then
        hook.Remove("HUDPaint", "DynMap_Render")
        print("DynMap: Existing HUDPaint hook found, replacing it with the new one...")
    end

    hook.Add("HUDPaint", "DynMap_Render", function()
        if not State.bmapVisible then
            Map.Render()
        else
            bmap.Render()
        end
        State.registerPlayerPos()
    end)

    if hooks["Think"]["DynMap_Input"] then
        hook.Remove("Think", "DynMap_Input")
        print("DynMap: Existing Think hook found, replacing it with the new one...")
    end

    local nextChange = 0
    hook.Add("Think", "DynMap_Input", function()
        local curTime = CurTime()
        if input.IsKeyDown(KEY_Z) and curTime > nextChange then
            State.ChangeZoom()
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
