local uiUtils = include("utils.lua")
local colors = include("../colors.lua")
local geometry = include("../geometry.lua")
local SettingsPanel = {}

local function refreshMap()
    State.initDerivativeValues()
    Map.updateSize()
end

--- Reduce the frame size based on the number of elements.
---@param frame Panel @Frame to squash
local function squashFrame(frame)
    local children = frame:GetChildren()
    local childrenCount = #children

    local maxHeight = 0
    for i = 1, childrenCount do
        local child = children[i]
        local childYPos = child:GetY() + child:GetTall()
        if childYPos > maxHeight then
            maxHeight = childYPos
        end
    end

    frame:SetHeight(maxHeight + UiLayout.gridSizeY) -- Add some padding at the bottom
end

function SettingsPanel.Create()
    local frame = vgui.Create("DFrame")
    frame:SetSize(UiLayout.frameWidth, UiLayout.frameWidth)
    frame:Center()
    frame:SetTitle("DynMap Settings")
    frame:MakePopup()

    local defaultSize = { w = UiLayout.gridSizeX, h = UiLayout.gridSizeY }

    --- Element creation

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 0 },
        size = defaultSize,
        text = "Main Options:",
        font = "HudDefault"
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 1 },
        size = defaultSize,
        text = "Zoom Level:",
    })

    local zoomSlider = uiUtils.createUIElementOnGrid(frame, "DNumSlider", {
        grid = { x = 1, y = 1 },
        size = defaultSize,
        min = 0,
        max = 1,
        decimals = 2,
        value = Config.uiZoomLevel
    })

    zoomSlider:AlignLeft(UiLayout.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 2 },
        size = defaultSize,
        text = "Astigmatism Mode:",
        font = "DermaDefault"
    })

    local astigmatismCheckbox = uiUtils.createUIElementOnGrid(frame, "DCheckBox", {
        grid = { x = 1, y = 2 },
        value = Config.astigmatismMode
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 3 },
        size = defaultSize,
        text = "Player Indicator Size:",
        font = "DermaDefault"
    })

    local playerSizeSlider = uiUtils.createUIElementOnGrid(frame, "DNumSlider", {
        grid = { x = 1, y = 3 },
        size = defaultSize,
        min = 1,
        max = 50,
        decimals = 0,
        value = Config.playerIndicatorSize,
    })

    playerSizeSlider:AlignLeft(UiLayout.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 4 },
        size = defaultSize,
        text = "Map Size:",
        font = "DermaDefault"
    })

    local mapSizeSlider = uiUtils.createUIElementOnGrid(frame, "DNumSlider", {
        grid = { x = 1, y = 4 },
        size = defaultSize,
        min = ScrH() * 0.1,
        max = math.min(ScrW() / 2, ScrH() / 2),
        decimals = 0,
        value = Config.mapSize
    })

    mapSizeSlider:AlignLeft(UiLayout.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 5 },
        size = defaultSize,
        text = "Map Resolution:",
        font = "DermaDefault",
        color = colors.WINE_RED,
    })

    local mapResolutionSlider = uiUtils.createUIElementOnGrid(frame, "DNumSlider", {
        grid = { x = 1, y = 5 },
        size = defaultSize,
        min = 0.1,
        max = Config.uiMaxResolution,
        decimals = 2,
        value = Config.uiResolution
    })

    mapResolutionSlider:AlignLeft(UiLayout.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 6 },
        size = defaultSize,
        text = "Round Mode",
        font = "DermaDefault",
        wrap = true, -- In case it doesn't fit
    })

    local roundModeCheckbox = uiUtils.createUIElementOnGrid(frame, "DCheckBox", {
        grid = { x = 1, y = 6 },
        value = Config.roundMode
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 7 },
        size = defaultSize,
        text = "Enable Frametime Debug",
        font = "DermaDefault",
    })

    local debugCheckbox = uiUtils.createUIElementOnGrid(frame, "DCheckBox", {
        grid = { x = 1, y = 7 },
        value = Config.showFrameTimeDebug
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 8 },
        size = defaultSize,
        text = "Height Display Range",
        font = "DermaDefault",
    })

    local heightRangeSlider = uiUtils.createUIElementOnGrid(frame, "DNumSlider", {
        grid = { x = 1, y = 8 },
        size = defaultSize,
        min = 20,
        max = 1000,
        decimals = 0,
        value = Config.heightDisplayRange
    })

    heightRangeSlider:AlignLeft(UiLayout.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 9 },
        size = defaultSize,
        text = "Height Fade Multiplier",
        font = "DermaDefault",
    })

    local heightFadeSlider = uiUtils.createUIElementOnGrid(frame, "DNumSlider", {
        grid = { x = 1, y = 9 },
        size = defaultSize,
        min = 0.01,
        max = 1,
        decimals = 2,
        value = Config.heightFadeMultiplier
    })

    heightFadeSlider:AlignLeft(UiLayout.gridSizeX * 1)


    -- Stuff that should be on the bottom

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = UiLayout.GRID_COUNT_Y - 1 }, -- The last column for the warning
        size = { w = defaultSize.w * 2, h = defaultSize.h },
        text = "WARNING: Changing settings in Red will reset all points on the map!",
        font = "DermaDefault",
        color = colors.WINE_RED,
        wrap = true, -- In case it doesn't fit
    })

    --- Hooks
    playerSizeSlider.OnValueChanged = function(_, value)
        Config.playerIndicatorSize = value
        Config.playerIndicatorTable = geometry.createIndicatorVertices(
            Config.mapCenterX,
            Config.mapCenterY,
            Config.playerIndicatorSize
        )
    end

    mapSizeSlider.OnValueChanged = function(_, value)
        Config.mapSize = value
        refreshMap()
    end

    zoomSlider.OnValueChanged = function(_, value)
        Config.uiZoomLevel = math.Round(value, 2)
        Config.mapZoomLevel = Config.uiZoomLevel / 10
    end

    mapResolutionSlider.OnValueChanged = function(_, value)
        Config.uiResolution = value
        Config.mapResolution = Config.uiResolution / 100
        State.resetPoints()
    end

    heightFadeSlider.OnValueChanged = function(_, value)
        Config.heightFadeMultiplier = value
    end

    heightRangeSlider.OnValueChanged = function(_, value)
        Config.heightDisplayRange = value
    end

    roundModeCheckbox.OnChange = function(_, value)
        Config.roundMode = value
    end

    astigmatismCheckbox.OnChange = function(_, value)
        Config.astigmatismMode = value
    end

    debugCheckbox.OnChange = function(_, value)
        Config.showFrameTimeDebug = value
    end

    squashFrame(frame)

    return frame
end

return SettingsPanel
