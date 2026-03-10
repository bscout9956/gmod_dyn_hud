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

Settings.playerIndicatorTable = {{
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
}}

local SCREEN_WIDTH = ScrW()
local SCREEN_HEIGHT = ScrH()

local FRAME_WIDTH = 0.5 * SCREEN_WIDTH
local FRAME_HEIGHT = 0.5 * SCREEN_HEIGHT
local LEFT_MARGIN = 0.01 * SCREEN_WIDTH
local TOP_MARGIN = 0.03 * SCREEN_HEIGHT

local gridCountX, gridCountY = 2, 20
local gridSizeX = FRAME_WIDTH / gridCountX
local gridSizeY = FRAME_HEIGHT / gridCountY

function Settings.changeZoom()
    if Settings.uiZoomLevel >= 1 then
        Settings.uiZoomLevel = 0.1
    else
        Settings.uiZoomLevel = Settings.uiZoomLevel + 0.01
    end
    Settings.mapZoomLevel = Settings.uiZoomLevel / 10
end

local function getGridPosition(gridX, gridY)
    local pos = {
        x = nil,
        y = nil
    }

    if gridX ~= nil then
        pos.x = LEFT_MARGIN + (gridSizeX * gridX)
    end

    if gridY ~= nil then
        pos.y = TOP_MARGIN + (gridSizeY * gridY)
    end

    return pos
end

function Settings.OpenDynHudSettings()
    local frame = vgui.Create("DFrame")
    frame:SetSize(FRAME_WIDTH, FRAME_WIDTH)
    frame:Center()
    frame:SetTitle("DynHud Settings")
    frame:MakePopup()

    local section = uiUtils.createLabelGrid(frame, 0, 0, {
        w = gridSizeX,
        h = gridSizeY,
        text = "Main Options:",
        font = "HudDefault"
    })

    local zoomSlider = uiUtils.createNumSliderGrid(frame, 0, 1, {
        w = gridSizeX,
        h = gridSizeY,
        text = "Zoom Level:",
        min = 0,
        max = 1,
        decimals = 1,
        value = Settings.uiZoomLevel
    })

    zoomSlider.OnValueChanged = function(self, value)
        Settings.uiZoomLevel = value
        Settings.mapZoomLevel = Settings.uiZoomLevel / 10
    end

    Settings.settingsFramePresent = true

    function frame:OnClose()
        Settings.settingsFramePresent = false
    end
end

return Settings
