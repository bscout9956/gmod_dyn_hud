local UIUtils = {}

local cos = math.cos
local sin = math.sin
local rad = math.rad

-- Mapping for the properties and their function calls
---@type table
local uiSetMapper = {
    value = "SetValue",
    val = "SetValue",
    min = "SetMin",
    max = "SetMax",
    interval = "SetInterval",
    decimals = "SetDecimals",
    text = "SetText",
    font = "SetFont",
    color = "SetColor",
    wrap = "SetWrap",
}

-- Mapping for the properties, their function calls and the expected parameters
---@type table
local uiDualElementMapper = {
    size = { func = "SetSize", params = { "w", "h" } },
    pos = { func = "SetPos", params = { "x", "y" } },
    minMax = { func = "SetMinMax", params = { "min", "max" } },
}

--- Returns the position given a specific X and Y grid index
---@param grid table @The grid position with x and y indices
---@return table @The position with x and y coordinates
function UIUtils.getGridPosition(grid)
    local pos = {
        x = nil,
        y = nil
    }

    if grid then
        pos.x = (UiSettings.leftMargin + (UiSettings.gridSizeX * grid.x)) or 0
        pos.y = (UiSettings.topMargin + (UiSettings.gridSizeY * grid.y)) or 0
    end

    return pos
end

--- Dynamic setter for VGUI Elements based on element, property name and values to be used
---@param element Panel @The VGUI element to set properties for
---@param propName string @The property name
---@param values table @The values to set
local function dualElementSetter(element, propName, values)
    local mapping = uiDualElementMapper[propName]
    if not mapping then
        print("No mapping found for dual parameter property: ", propName)
        return
    end

    local func = mapping.func
    local p1 = mapping.params[1]
    local p2 = mapping.params[2]

    if element[func] then
        element[func](element, values[p1], values[p2])
    end
end

--- Dynamic setter for VGUI Elements based on the class name, frame, and properties to be set
---@param className string @The VGUI element class name to create
---@param frame Panel @The parent frame for the VGUI element
---@param props table @The properties to set for the VGUI element
local function createUIElement(className, frame, props)
    local element = vgui.Create(className, frame)

    for propName, value in pairs(props) do
        if propName ~= "grid" then
            local funcSetter = uiSetMapper[propName]

            --- Tables usually mean we need to use the dual element setter,
            --- but we make an exception for color since it's a single parameter function that takes a table
            if type(value) == "table" and propName ~= "color" then
                dualElementSetter(element, propName, value)
            else
                if funcSetter and element then
                    element[funcSetter](element, value)
                else
                    print(
                        "No mapping found for property: ",
                        propName,
                        " for element of class: ",
                        className, " value: ",
                        value
                    )
                end
            end
        end
    end

    return element
end

--- Creates a label given the className using the grid system
---@param frame Panel @The parent frame for the label
---@param className string @The VGUI element class name to create
---@param props table @The properties to set for the label
function UIUtils.createUIElementOnGrid(frame, className, props)
    props.pos = UIUtils.getGridPosition(props.grid)
    local element = createUIElement(className, frame, props)

    -- Patch for when we don't want the text there, VGUI forces empty space to its left
    if className == "DNumSlider" and (not props.text or props.text == "") then
        element.Label:SetVisible(false)
        element.Label:SetWide(0)
    end

    return element
end

-- Taken from: https://wiki.facepunch.com/gmod/surface.DrawPoly
-- Why isn't this included bro? It's not bloat, it's useful lmao
---@param x number @x Coordinate
---@param y number @y Coordinate
---@param radius number @radius Radius of Circle
---@param seg number @How many segments aka precision
function UIUtils.DrawCircle(x, y, radius, seg)
    local cir = {}

    table.insert(cir, {
        x = x,
        y = y,
        u = 0.5,
        v = 0.5
    })

    for i = 0, seg do
        local a = rad((i / seg) * -360)
        table.insert(cir, {
            x = x + sin(a) * radius,
            y = y + cos(a) * radius,
            u = (sin(a) * .5) + 0.5,
            v = (cos(a) * .5) + 0.5
        })
    end

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(cir, {
        x = x + sin(a) * radius,
        y = y + cos(a) * radius,
        u = (sin(a) * .5) + 0.5,
        v = (cos(a) * .5) + 0.5
    })

    surface.DrawPoly(cir)
end

return UIUtils
