local uiUtils = include("ui_utils.lua")
local Settings = {}

Settings.settingsFramePresent = false
Settings.uiZoomLevel = 0.5
Settings.astigmatismMode = false
Settings.uiResolution = 1 -- Fractional, the higher the worse, keep it small
Settings.hudThickness = 3

-- HUD Parameters
Settings.spacing = 20
Settings.margin = 20
Settings.hudSize = math.floor(0.125 * ScrW())
Settings.playerIndicatorSize = 18

-- Derivative values
Settings.halfSize = Settings.hudSize / 2
Settings.mapZoomLevel = Settings.uiZoomLevel / 10
Settings.hudXpos = Settings.margin
Settings.hudYpos = Settings.margin
Settings.hudCenterX = Settings.hudXpos + Settings.halfSize
Settings.hudCenterY = Settings.hudYpos + Settings.halfSize

local function computePlayerIndicatorTable()
    return { {
        x = Settings.hudCenterX - Settings.playerIndicatorSize,
        y = Settings.hudCenterY + Settings.playerIndicatorSize,
        u = 0,
        v = 0
    }, {
        x = Settings.hudCenterX,
        y = Settings.hudCenterY - Settings.playerIndicatorSize,
        u = 0,
        v = 0
    }, {
        x = Settings.hudCenterX + Settings.playerIndicatorSize,
        y = Settings.hudCenterY + Settings.playerIndicatorSize,
        u = 0,
        v = 0
    }, {
        x = Settings.hudCenterX - Settings.playerIndicatorSize,
        y = Settings.hudCenterY + Settings.playerIndicatorSize,
        u = 0,
        v = 0
    } }
end

Settings.playerIndicatorTable = computePlayerIndicatorTable()

function Settings.changeZoom()
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
    frame:SetTitle("DynHud Settings")
    frame:MakePopup()

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

    playerSizeWang.OnValueChanged = function(_, value)
        Settings.playerIndicatorSize = value
        Settings.playerIndicatorTable = computePlayerIndicatorTable()
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

return Settings
