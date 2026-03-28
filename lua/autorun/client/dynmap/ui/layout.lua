local UILayout = {}
local SCALE_FACTOR = 0.25



---@type number
local screenWidth = ScrW()
---@type number
local screenHeight = ScrH()


--- Initializes the default values for the settings panel based on the current screen size.
local function initLayout()
    screenWidth = ScrW()
    screenHeight = ScrH()

    UILayout.GRID_COUNT_X, UILayout.GRID_COUNT_Y = 2, 15

    UILayout.frameWidth = SCALE_FACTOR * screenWidth
    UILayout.frameHeight = SCALE_FACTOR * screenHeight

    UILayout.leftMargin = 0.01 * screenWidth
    UILayout.topMargin = 0.03 * screenHeight

    UILayout.gridSizeX = UILayout.frameWidth / UILayout.GRID_COUNT_X
    UILayout.gridSizeY = UILayout.frameHeight / UILayout.GRID_COUNT_Y
end

--- Returns the position given a specific X and Y grid index
---@param grid table @The grid position with x and y indices
---@return table @The position with x and y coordinates
function UILayout.getGridPosition(grid)
    local pos = {
        x = nil,
        y = nil
    }

    if grid then
        pos.x = (UiLayout.leftMargin + (UiLayout.gridSizeX * grid.x)) or 0
        pos.y = (UiLayout.topMargin + (UiLayout.gridSizeY * grid.y)) or 0
    end

    return pos
end

-- We run this for whenever it gets imported so the variables are set and no code freaks out lmao
initLayout()

-- We also define a function so whenever we need to do it again we're ready for it
function UILayout.refreshValues()
    initLayout()
end

return UILayout
