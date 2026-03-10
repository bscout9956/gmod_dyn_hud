local Settings = {}

Settings.settingsFramePresent = false
Settings.uiZoomLevel = 0.5
Settings.astigmatismMode = false
Settings.uiResolution = 1 -- Fractional, the higher the worse, keep it small
Settings.mapZoomLevel = Settings.uiZoomLevel / 10

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
