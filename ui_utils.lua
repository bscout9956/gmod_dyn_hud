local UIUtils = {}

--- Returns the position given a specific X and Y grid index
---@param gridX number
---@param gridY number
---@return table
function UIUtils.getGridPosition(gridX, gridY)
    local pos = {
        x = nil,
        y = nil
    }

    if gridX ~= nil then
        pos.x = UiSettings.LEFT_MARGIN + (UiSettings.gridSizeX * gridX)
    end

    if gridY ~= nil then
        pos.y = UiSettings.TOP_MARGIN + (UiSettings.gridSizeY * gridY)
    end

    return pos
end

--- Creates a DLabel with the given properties
---@param frame Panel
---@param props table
---@return DLabel
function UIUtils.createLabel(frame, props)
    local label = vgui.Create("DLabel", frame)
    label:SetPos(props.pos.x, props.pos.y)
    label:SetSize(props.w, props.h)
    label:SetText(props.text)
    label:SetFont(props.font)
    return label
end

--- Creates a DNumSlider with the given properties
---@param frame Panel
---@param props table
---@return DNumSlider
function UIUtils.createNumSlider(frame, props)
    local slider = vgui.Create("DNumSlider", frame)
    slider:SetPos(props.pos.x, props.pos.y)
    slider:SetSize(props.w, props.h)
    slider:SetText(props.text)
    slider:SetMin(props.min)
    slider:SetMax(props.max)
    slider:SetDecimals(props.decimals)
    slider:SetValue(props.val)
    return slider
end

--- Creates a DCheckBox with the given properties
---@param frame Panel
---@param props table
---@return DCheckBox
function UIUtils.createDCheckBox(frame, props)
    local checkbox = vgui.Create("DCheckBox", frame)
    checkbox:SetPos(props.pos.x, props.pos.y)
    checkbox:SetValue(props.value)
    return checkbox
end

--- Creates a label using the grid system
---@param frame Panel
---@param xIndex number
---@param yIndex number
---@param props table
function UIUtils.createLabelGrid(frame, xIndex, yIndex, props)
    props.pos = UIUtils.getGridPosition(xIndex, yIndex)
    return UIUtils.createLabel(frame, props)
end

function UIUtils.createNumSliderGrid(frame, xIndex, yIndex, props)
    props.pos = UIUtils.getGridPosition(xIndex, yIndex)
    return UIUtils.createNumSlider(frame, props)
end

function UIUtils.createDCheckboxGrid(frame, xIndex, yIndex, props)
    props.pos = UIUtils.getGridPosition(xIndex, yIndex)
    return UIUtils.createDCheckBox(frame, props)
end

return UIUtils
