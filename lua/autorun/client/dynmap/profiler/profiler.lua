local colors = include("../colors.lua")
local DebugProfiler = {}

local startTime = 0
local endTime = 0

local boxWidth = ScrW() * .25
local boxHeight = ScrH() * .25
local boxXpos = ScrW() - (boxWidth + 10)
local boxYpos = ScrH() - (boxHeight + 10)
local boxHalfSizeX = boxWidth / 2
local boxHalfSizeY = boxHeight / 2
local boxCenterX = boxXpos + boxHalfSizeX
local boxCenterY = boxYpos + boxHalfSizeY
local spacing = 20
local measurement = ""

local values = {}
local minScale = 0.01
local maxScale = 2
local middlePoint = (maxScale + minScale) / 2

function DebugProfiler.DrawGraph()
    middlePoint = (maxScale + minScale) / 2

    surface.SetDrawColor(colors.GREEN)
    local peak = 0
    for i = 1, #values do
        if values[i] > peak then peak = values[i] end
    end

    if peak > maxScale then
        maxScale = Lerp(0.1, maxScale, peak)
    end

    for i = 1, #values do
        local curValue = values[i]
        local percentPosition = curValue / maxScale
        local barHeight = percentPosition * boxHeight

        if barHeight <= boxHeight then
            surface.DrawRect(boxXpos + i, (boxYpos + boxHeight) - barHeight, 3, 3) -- TODO: Make smaller later
        end
    end

    -- This drifts it back down and prevents it from becoming 0
    maxScale = maxScale * 0.99
    maxScale = math.max(maxScale, 0.01)
end

function DebugProfiler.Register(name)
    measurement = name
end

function DebugProfiler.Begin()
    startTime = SysTime()
end

function DebugProfiler.DrawLabel()
    draw.DrawText(
        "DynMap Profiler:",
        "DermaDefaultBold",
        boxXpos + (spacing / 2), boxYpos - spacing, -- XY
        colors.SOFT_GREEN,
        TEXT_ALIGN_LEFT
    )

    draw.DrawText(
        measurement,
        "DermaDefault",
        boxXpos + (spacing / 2), boxYpos - (spacing * 1), -- XY
        colors.WHITE,
        TEXT_ALIGN_LEFT
    )
end

function DebugProfiler.DrawBackgroundBox()
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(boxXpos, boxYpos, boxWidth, boxHeight)

    local frameTime = (endTime - startTime) * 1000
    draw.DrawText(
        string.format("%.2f ms", frameTime),
        "DermaDefaultBold",
        boxXpos + spacing, boxYpos + spacing,
        Color(255, 255, 255),
        TEXT_ALIGN_LEFT
    )
end

function DebugProfiler.Draw()
    DebugProfiler.DrawLabel()
    DebugProfiler.DrawBackgroundBox()
end

function DebugProfiler.End()
    endTime = SysTime()
    if #values > boxWidth then
        table.remove(values, 1)
    end
    values[#values + 1] = (endTime - startTime) * 1000
end

return DebugProfiler
