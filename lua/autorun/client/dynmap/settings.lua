local settingsPanel = include("ui/settings_panel.lua")

local Settings = {}

Settings.settingsFramePresent = false

function Settings.OpenDynHudSettings()
    local frame = settingsPanel.Create()

    function frame:OnClose()
        Settings.settingsFramePresent = false
    end
end

-- Anything that needs to be executed upon script loading goes here:

State.initDerivativeValues()

return Settings
