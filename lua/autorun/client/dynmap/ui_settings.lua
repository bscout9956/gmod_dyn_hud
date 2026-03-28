local UISettings = {}
local SCALE_FACTOR = 0.25

---@type number
local screenWidth = ScrW()
---@type number
local screenHeight = ScrH()

--- Initializes the default values for the settings panel based on the current screen size.
local function initDefaultValues()
    screenWidth = ScrW()
    screenHeight = ScrH()

    UISettings.GRID_COUNT_X, UISettings.GRID_COUNT_Y = 2, 15

    UISettings.frameWidth = SCALE_FACTOR * screenWidth
    UISettings.frameHeight = SCALE_FACTOR * screenHeight

    UISettings.leftMargin = 0.01 * screenWidth
    UISettings.topMargin = 0.03 * screenHeight

    UISettings.gridSizeX = UISettings.frameWidth / UISettings.GRID_COUNT_X
    UISettings.gridSizeY = UISettings.frameHeight / UISettings.GRID_COUNT_Y
end

-- We run this for whenever it gets imported so the variables are set and no code freaks out lmao
initDefaultValues()

-- We also define a function so whenever we need to do it again we're ready for it
function UISettings.refreshValues()
    initDefaultValues()
end

return UISettings
