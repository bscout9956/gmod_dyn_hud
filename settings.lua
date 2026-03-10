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

function Settings.OpenDynHudSettings()
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    frame:SetTitle("DynHud Settings")
    frame:MakePopup()

    local label = vgui.Create("DLabel", frame)
    label:SetPos(20, 40)
    label:SetSize(300, 20)
    label:SetText("Test")

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetText("Button Test")
    closeBtn:SetPos(150, 250)
    closeBtn:SetSize(100, 30)

    Settings.settingsFramePresent = true

    closeBtn.DoClick = function()
        Settings.settingsFramePresent = false
        frame:Close()
    end
end

return Settings
