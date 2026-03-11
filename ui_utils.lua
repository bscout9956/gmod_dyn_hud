local UIUtils = {}

-- Mapping for the properties and their function calls
local uiSetMapper = {
    value = "SetValue",
    val = "SetValue",
    min = "SetMin",
    max = "SetMax",
    interval = "SetInterval",
    decimals = "SetDecimals",
    text = "SetText",
    font = "SetFont"
}

-- Mapping for the properties, their function calls and the expected parameters
local uiDualElementMapper = {
    size = { func = "SetSize", params = { "w", "h" } },
    pos = { func = "SetPos", params = { "x", "y" } },
    minMax = { func = "SetMinMax", params = { "min", "max" } }
}

--- Returns the position given a specific X and Y grid index
---@param grid table
---@return table
function UIUtils.getGridPosition(grid)
    local pos = {
        x = nil,
        y = nil
    }

    if grid then
        pos.x = (UiSettings.LEFT_MARGIN + (UiSettings.gridSizeX * grid.x)) or 0
        pos.y = (UiSettings.TOP_MARGIN + (UiSettings.gridSizeY * grid.y)) or 0
    end

    return pos
end

local function dualElementSetter(element, propName, values)
    local mapping = uiDualElementMapper[propName]
    if not mapping then return end

    local func = mapping.func
    local p1 = mapping.params[1]
    local p2 = mapping.params[2]

    if element[func] then
        element[func](element, values[p1], values[p2])
    end
end

local function createUIElement(className, frame, props)
    local element = vgui.Create(className, frame)

    for propName, value in pairs(props) do
        if propName ~= "grid" then
            local funcSetter = uiSetMapper[propName]

            if type(value) == "table" then
                -- Dual parameter properties
                dualElementSetter(element, propName, value)
            else
                -- Single parameter properties
                if funcSetter and element then
                    element[funcSetter](element, value)
                end
            end
        end
    end

    return element
end

--- Creates a label given the className using the grid system
---@param frame Panel
---@param className string
---@param props table
function UIUtils.createUIElementOnGrid(frame, className, props)
    props.pos = UIUtils.getGridPosition(props.grid)
    local element = createUIElement(className, frame, props)
    return element
end

return UIUtils
