local uiUtils = include("ui_utils.lua")
local Settings = {}

Settings.settingsFramePresent = false
Settings.uiZoomLevel = 0.5
Settings.astigmatismMode = false
Settings.uiResolution = 1 -- Fractional, the higher the worse, keep it small
Settings.borderThickness = 3

-- HUD Parameters
Settings.spacing = 20
Settings.margin = 20
Settings.mapSize = math.floor(0.125 * ScrW())
Settings.playerIndicatorSize = 18
Settings.playerIndicatorNotch = 0.5

-- Big Map Parameters
Settings.bigMapSizeX = math.floor(0.75 * ScrW())
Settings.bigMapSizeY = math.floor(0.75 * ScrH())


local function createIndicatorVertices(cx, cy, size)
    local notchOffset = size * Settings.playerIndicatorNotch

    return {
        { x = cx,        y = cy - size,               u = 0, v = 0 }, -- 1. Top Tip
        { x = cx + size, y = cy + size,               u = 0, v = 0 }, -- 2. Bottom Right
        { x = cx,        y = cy + size - notchOffset, u = 0, v = 0 }, -- 3. The Notch (Center Base)
        { x = cx - size, y = cy + size,               u = 0, v = 0 }, -- 4. Bottom Left
        { x = cx,        y = cy - size,               u = 0, v = 0 }  -- 5. Back to Top Tip
    }
end

local function initDerivativeValues()
    Settings.halfMapSize = Settings.mapSize / 2
    Settings.bigMapHalfSizeX = Settings.bigMapSizeX / 2
    Settings.bigMapHalfSizeY = Settings.bigMapSizeY / 2
    Settings.mapZoomLevel = Settings.uiZoomLevel / 10
    Settings.mapXpos = Settings.margin
    Settings.mapYpos = Settings.margin
    Settings.bigMapXpos = (ScrW() / 2) - Settings.bigMapHalfSizeX
    Settings.bigMapYpos = (ScrH() / 2) - Settings.bigMapHalfSizeY
    Settings.mapCenterX = Settings.mapXpos + Settings.halfMapSize
    Settings.mapCenterY = Settings.mapYpos + Settings.halfMapSize
    Settings.bigMapCenterX = Settings.bigMapXpos + Settings.bigMapHalfSizeX
    Settings.bigMapCenterY = Settings.bigMapYpos + Settings.bigMapHalfSizeY
    Settings.mapResolution = Settings.uiResolution / 100

    Settings.playerIndicatorTable = createIndicatorVertices(
        Settings.mapCenterX, Settings.mapCenterY, Settings.playerIndicatorSize
    )
    Settings.bigMapPlayerIndicatorTable = createIndicatorVertices(
        Settings.bigMapCenterX, Settings.bigMapCenterY, Settings.playerIndicatorSize
    )
end

local function refreshMap()
    initDerivativeValues()
    Map.updateSize()
end


function Settings.ChangeZoom()
    if Settings.uiZoomLevel >= 1 then
        Settings.uiZoomLevel = 0.1
    else
        Settings.uiZoomLevel = Settings.uiZoomLevel + 0.01
    end
    Settings.mapZoomLevel = Settings.uiZoomLevel / 10
end

function Settings.OpenDynHudSettings()
    local frame = vgui.Create("DFrame")
    frame:SetSize(UiSettings.frameWidth, UiSettings.frameWidth)
    frame:Center()
    frame:SetTitle("DynMap Settings")
    frame:MakePopup()

    --- Element creation

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 0 },
        size = { w = UiSettings.gridSizeX, h = UiSettings.gridSizeY },
        text = "Main Options:",
        font = "HudDefault"
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 1 },
        size = { w = UiSettings.gridSizeX, h = UiSettings.gridSizeY },
        text = "Zoom Level:",
    })

    local zoomSlider = uiUtils.createUIElementOnGrid(frame, "DNumSlider", {
        grid = { x = 1, y = 1 },
        size = { w = UiSettings.gridSizeX, h = UiSettings.gridSizeY },
        min = 0,
        max = 1,
        decimals = 2,
        value = Settings.uiZoomLevel
    })

    zoomSlider:AlignLeft(UiSettings.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 2 },
        size = { w = UiSettings.gridSizeX, h = UiSettings.gridSizeY },
        text = "Astigmatism Mode:",
        font = "DermaDefault"
    })

    local astigmatismCheckbox = uiUtils.createUIElementOnGrid(frame, "DCheckBox", {
        grid = { x = 1, y = 2 },
        value = Settings.astigmatismMode
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 3 },
        size = { w = UiSettings.gridSizeX, h = UiSettings.gridSizeY },
        text = "Player Indicator Size:",
        font = "DermaDefault"
    })

    local playerSizeWang = uiUtils.createUIElementOnGrid(frame, "DNumberWang", {
        grid = { x = 1, y = 3 },
        min = 1,
        max = 50,
        value = Settings.playerIndicatorSize,
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 4 },
        size = { w = UiSettings.gridSizeX, h = UiSettings.gridSizeY },
        text = "Map Size:",
        font = "DermaDefault"
    })

    local mapSizeWang = uiUtils.createUIElementOnGrid(frame, "DNumberWang", {
        grid = { x = 1, y = 4 },
        min = 50,
        max = math.max(ScrW(), ScrH()),
        value = Settings.mapSize
    })

    --- Hooks
    playerSizeWang.OnValueChanged = function(_, value)
        Settings.playerIndicatorSize = value
        Settings.playerIndicatorTable = createIndicatorVertices(
            Settings.mapCenterX,
            Settings.mapCenterY,
            Settings.playerIndicatorSize
        )
    end

    mapSizeWang.OnValueChanged = function(_, value)
        Settings.mapSize = value
        refreshMap()
    end

    zoomSlider.OnValueChanged = function(_, value)
        Settings.uiZoomLevel = math.Round(value, 2)
        Settings.mapZoomLevel = Settings.uiZoomLevel / 10
    end

    astigmatismCheckbox.OnChange = function(_, value)
        Settings.astigmatismMode = value
    end


    Settings.settingsFramePresent = true
    function frame:OnClose()
        Settings.settingsFramePresent = false
    end
end

-- Anything that needs to be executed upon script loading goes here:

initDerivativeValues()

return Settings
