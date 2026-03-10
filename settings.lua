local Settings = {}

Settings.settingsFramePresent = false
Settings.uiZoomLevel = 0.5
Settings.astigmatismMode = false
Settings.uiResolution = 1 -- Fractional, the higher the worse, keep it small

-- HUD Parameters
Settings.spacing = 20
Settings.margin = 20
Settings.hudSize = math.floor(0.125 * ScrW())

-- Derivative values
Settings.mapZoomLevel = Settings.uiZoomLevel / 10
Settings.hudXpos = Settings.margin
Settings.hudYpos = Settings.margin

local SCREEN_WIDTH = ScrW()
local SCREEN_HEIGHT = ScrH()

local FRAME_WIDTH = 0.5 * SCREEN_WIDTH
local FRAME_HEIGHT = 0.5 * SCREEN_HEIGHT
local LEFT_MARGIN = 0.01 * SCREEN_WIDTH
local TOP_MARGIN = 0.03 * SCREEN_HEIGHT

function Settings.changeZoom()
    if Settings.uiZoomLevel >= 1 then
        Settings.uiZoomLevel = 0.1
    else
        Settings.uiZoomLevel = Settings.uiZoomLevel + 0.01
    end
    Settings.mapZoomLevel = Settings.uiZoomLevel / 10
end

local function createLabel(frame, x, y, w, h, txt)
    local label = vgui.Create("DLabel", frame)
    label:SetPos(x, y)
    label:SetSize(w, h)
    label:SetText(txt)
    return label
end

local function createNumSlider(frame, x, y, w, h, txt, min, max, decimals, val)
    local slider = vgui.Create("DNumSlider", frame)
    slider:SetPos(x, y)
    slider:SetSize(w, h)
    slider:SetText(txt)
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetDecimals(decimals)
    slider:SetValue(val)
    return slider
end

function Settings.OpenDynHudSettings()
    local frame = vgui.Create("DFrame")
    frame:SetSize(FRAME_WIDTH, FRAME_WIDTH)
    frame:Center()
    frame:SetTitle("DynHud Settings")
    frame:MakePopup()

    local zoomSlider = createNumSlider(frame, LEFT_MARGIN, TOP_MARGIN + 20, 300, 20, "Zoom Level:", 0, 1, 1,
        Settings.uiZoomLevel)

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
