local colors = include("../colors.lua")
local DebugProfiler = {}

local startTime = 0
local endTime = 0

local boxWidth = ScrW() * .25
local boxHeight = ScrH() * .25
local boxXpos = ScrW() - (boxWidth + 10)
local boxYpos = ScrH() - (boxHeight + 10)
local boxCenterX = boxXpos / 2
local boxCenterY = boxYpos / 2
local boxHalfSizeX = boxWidth / 2
local boxHalfSizeY = boxHeight / 2
local spacing = 20

function DebugProfiler.DrawGraph()

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
end

function DebugProfiler.DrawBackgroundBox()
    surface.SetDrawColor(0, 0, 0, 150)
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
end

return DebugProfiler
