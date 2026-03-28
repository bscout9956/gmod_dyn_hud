local colors = include("colors.lua")
local uiUtils = include("ui_utils.lua")
local Settings = {}

Settings.settingsFramePresent = false
Settings.showFrameTimeDebug = true
Settings.uiZoomLevel = 0.5
Settings.astigmatismMode = false
Settings.uiResolution = 1 -- Fractional, the higher the worse, keep it small
Settings.borderThickness = 3
Settings.heightDisplayRange = 500
Settings.heightFadeMultiplier = 0.51

-- HUD Parameters
Settings.spacing = 20
Settings.margin = 20
Settings.mapSize = math.floor(0.125 * ScrW())
Settings.playerIndicatorSize = 18
Settings.playerIndicatorNotch = 0.5
Settings.roundMode = false -- Whether to use a round map or not

-- Big Map Parameters
Settings.bigMapSizeX = math.floor(0.75 * ScrW())
Settings.bigMapSizeY = math.floor(0.75 * ScrH())

--- Creates the coordinates for where the player indicator should be.
--- It's in the shape of a triangle with a notch.
---@param cx number @X coordinate of the center
---@param cy number @Y coordinate of the center
---@param size number @Size of the indicator
---@return table
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

    frame:SetHeight(maxHeight + UiSettings.gridSizeY) -- Add some padding at the bottom
end

function Settings.OpenDynHudSettings()
    local frame = vgui.Create("DFrame")
    frame:SetSize(UiSettings.frameWidth, UiSettings.frameWidth)
    frame:Center()
    frame:SetTitle("DynMap Settings")
    frame:MakePopup()

    local defaultSize = { w = UiSettings.gridSizeX, h = UiSettings.gridSizeY }

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
        value = Settings.uiZoomLevel
    })

    zoomSlider:AlignLeft(UiSettings.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 2 },
        size = defaultSize,
        text = "Astigmatism Mode:",
        font = "DermaDefault"
    })

    local astigmatismCheckbox = uiUtils.createUIElementOnGrid(frame, "DCheckBox", {
        grid = { x = 1, y = 2 },
        value = Settings.astigmatismMode
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
        value = Settings.playerIndicatorSize,
    })

    playerSizeSlider:AlignLeft(UiSettings.gridSizeX * 1)

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
        value = Settings.mapSize
    })

    mapSizeSlider:AlignLeft(UiSettings.gridSizeX * 1)

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
        max = 1,
        decimals = 2,
        value = Settings.uiResolution
    })

    mapResolutionSlider:AlignLeft(UiSettings.gridSizeX * 1)

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 6 },
        size = defaultSize,
        text = "Round Mode",
        font = "DermaDefault",
        wrap = true, -- In case it doesn't fit
    })

    local roundModeCheckbox = uiUtils.createUIElementOnGrid(frame, "DCheckBox", {
        grid = { x = 1, y = 6 },
        value = Settings.roundMode
    })

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = 7 },
        size = defaultSize,
        text = "Enable Frametime Debug",
        font = "DermaDefault",
    })

    local debugCheckbox = uiUtils.createUIElementOnGrid(frame, "DCheckBox", {
        grid = { x = 1, y = 7 },
        value = Settings.showFrameTimeDebug
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
        value = Settings.heightDisplayRange
    })

    heightRangeSlider:AlignLeft(UiSettings.gridSizeX * 1)

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
        value = Settings.heightFadeMultiplier
    })

    heightFadeSlider:AlignLeft(UiSettings.gridSizeX * 1)


    -- Stuff that should be on the bottom

    uiUtils.createUIElementOnGrid(frame, "DLabel", {
        grid = { x = 0, y = UiSettings.GRID_COUNT_Y - 1 }, -- The last column for the warning
        size = { w = defaultSize.w * 2, h = defaultSize.h },
        text = "WARNING: Changing settings in Red will reset all points on the map!",
        font = "DermaDefault",
        color = colors.WINE_RED,
        wrap = true, -- In case it doesn't fit
    })

    --- Hooks
    playerSizeSlider.OnValueChanged = function(_, value)
        Settings.playerIndicatorSize = value
        Settings.playerIndicatorTable = createIndicatorVertices(
            Settings.mapCenterX,
            Settings.mapCenterY,
            Settings.playerIndicatorSize
        )
    end

    mapSizeSlider.OnValueChanged = function(_, value)
        Settings.mapSize = value
        refreshMap()
    end

    zoomSlider.OnValueChanged = function(_, value)
        Settings.uiZoomLevel = math.Round(value, 2)
        Settings.mapZoomLevel = Settings.uiZoomLevel / 10
    end

    mapResolutionSlider.OnValueChanged = function(_, value)
        Settings.uiResolution = value
        Settings.mapResolution = Settings.uiResolution / 100
        Points = {}
    end

    heightFadeSlider.OnValueChanged = function(_, value)
        Settings.heightFadeMultiplier = value
    end

    heightRangeSlider.OnValueChanged = function(_, value)
        Settings.heightDisplayRange = value
    end

    roundModeCheckbox.OnChange = function(_, value)
        Settings.roundMode = value
    end

    astigmatismCheckbox.OnChange = function(_, value)
        Settings.astigmatismMode = value
    end

    debugCheckbox.OnChange = function(_, value)
        Settings.showFrameTimeDebug = value
    end

    Settings.settingsFramePresent = true

    squashFrame(frame)

    function frame:OnClose()
        Settings.settingsFramePresent = false
    end
end

-- Anything that needs to be executed upon script loading goes here:

initDerivativeValues()

return Settings
