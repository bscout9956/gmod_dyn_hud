local uiUtils = include("ui_utils.lua")
local Settings = {}

Settings.settingsFramePresent = false
Settings.uiZoomLevel = 0.5
Settings.astigmatismMode = false
Settings.uiResolution = 1 -- Fractional, the higher the worse, keep it small

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

Settings.playerIndicatorTable = { {
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
    frame:SetSize(UiSettings.FRAME_WIDTH, UiSettings.FRAME_WIDTH)
    frame:Center()
    frame:SetTitle("DynHud Settings")
    frame:MakePopup()

    uiUtils.createLabelGrid(frame, 0, 0, {
        w = UiSettings.gridSizeX,
        h = UiSettings.gridSizeY,
        text = "Main Options:",
        font = "HudDefault"
    })

    uiUtils.createLabelGrid(frame, 0, 2, {
        w = UiSettings.gridSizeX,
        h = UiSettings.gridSizeY,
        text = "Astigmatism Mode:",
        font = "DermaDefault"
    })

    local zoomSlider = uiUtils.createNumSliderGrid(frame, 0, 1, {
        w = UiSettings.gridSizeX,
        h = UiSettings.gridSizeY,
        text = "Zoom Level:",
        min = 0,
        max = 1,
        decimals = 1,
        value = Settings.uiZoomLevel
    })

    local astigmatismCheckbox = uiUtils.createDCheckboxGrid(frame, 1, 2, {
        value = Settings.astigmatismMode
    })

    zoomSlider.OnValueChanged = function(_, value)
        Settings.uiZoomLevel = value
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
