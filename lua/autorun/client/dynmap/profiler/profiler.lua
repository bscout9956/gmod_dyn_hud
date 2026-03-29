--- This profiler is for development usage only. I can't guarantee nor will fix any bug requests.
--- Good luck!

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


local peakIndex = 1
local maxValues = math.floor(boxWidth) -- One value per pixel of width in the graph

local function drawGraph()
    middlePoint = (maxScale + minScale) / 2

    surface.SetDrawColor(colors.GREEN)
    local peak = 0
    for i = 1, maxValues do
        local curVal = values[i] or 0
        if curVal > peak then peak = curVal end
    end

    if peak > maxScale then
        maxScale = Lerp(0.1, maxScale, peak)
    end

    for x = 1, maxValues do
        local index = (peakIndex + x - 2) % maxValues + 1

        local curValue = values[index] or 0
        local percentPosition = curValue / maxScale
        local barHeight = percentPosition * boxHeight

        if barHeight > 0 then
            surface.DrawRect(
                boxXpos + x,
                (boxYpos + boxHeight) - barHeight,
                1,
                1
            )
        end
    end

    -- This drifts it back down and prevents it from becoming 0
    maxScale = maxScale * 0.99
    maxScale = math.max(maxScale, 0.01)
end

local function register(name)
    measurement = name
end

local function begin()
    if not measurement or measurement == "" then
        print("DYNMAP WARNING: NO REGISTERED NAME FOR PROFILER, YOU WON'T KNOW WHAT YOU ARE LOOKING FOR.")
    end
    startTime = SysTime()
end

local function drawXAxis()
    surface.SetDrawColor(colors.WHITE)
    surface.DrawLine(
        boxXpos,
        boxYpos + boxHalfSizeY - 2,
        boxXpos + boxWidth,
        boxYpos + boxHalfSizeY + 2
    )
end

local function drawYAxis()
    draw.DrawText(
        string.format("%.2f ms", maxScale),
        "DermaDefault",
        boxXpos + (spacing / 2),
        boxYpos + (spacing / 2),
        colors.WHITE,
        TEXT_ALIGN_LEFT
    )

    draw.DrawText(
        string.format("%.2f ms", middlePoint),
        "DermaDefault",
        boxXpos + (spacing / 2),
        boxCenterY,
        colors.WHITE,
        TEXT_ALIGN_LEFT
    )

    draw.DrawText(
        string.format("%.2f ms", minScale),
        "DermaDefault",
        boxXpos + (spacing / 2),
        boxYpos + boxHeight - spacing,
        colors.WHITE,
        TEXT_ALIGN_LEFT
    )
end

local function drawLabels()
    draw.DrawText(
        "DynMap Profiler:",
        "DermaDefaultBold",
        boxXpos + (spacing / 2), boxYpos - (spacing * 2), -- XY
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

local function drawBackgroundBox()
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
    drawLabels()
    drawBackgroundBox()
    drawXAxis()
    drawYAxis()
    drawGraph()
end

local function finish()
    endTime = SysTime()
    local frameTime = (endTime - startTime) * 1000

    values[peakIndex] = frameTime
    peakIndex = peakIndex + 1

    if peakIndex > maxValues then
        peakIndex = 1
    end
end

---
---@param func function @Function to run with the profiler
---@param name string @String to identify the measurement, will be shown above the graph
function DebugProfiler.RunWithProfiler(func, name)
    if not func then
        print("DYNMAP PROFILER ERROR: NO FUNCTION PASSED IN")
        return
    end

    register(name or "Unnamed Measurement\t:(")
    begin()
    func()
    finish()
end

return DebugProfiler
