local UIUtils = {}

function UIUtils.createLabel(frame, props)
    local label = vgui.Create("DLabel", frame)
    label:SetPos(props.pos.x, props.pos.y)
    label:SetSize(props.w, props.h)
    label:SetText(props.text)
    label:SetFont(props.font)
    return label
end

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

function UIUtils.createLabelGrid(frame, xIndex, yIndex, props)
    props.pos = UIUtils:getGridPosition(xIndex, yIndex)
    return UIUtils:createLabel(frame, props)
end

function UIUtils.createNumSliderGrid(frame, xIndex, yIndex, props)
    props.pos = UIUtils:getGridPosition(xIndex, yIndex)
    return UIUtils:createNumSlider(frame, props)
end

return UIUtils
