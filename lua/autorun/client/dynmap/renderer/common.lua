local uiUtils = include("../ui/utils.lua")
local colors = include("../colors.lua")

local setDrawColor = surface.SetDrawColor
local drawRect = surface.DrawRect
local abs = math.abs
local rad = math.rad
local cos = math.cos
local sin = math.sin

local RenderCommon = {}

--- Draws the points on the map, applying culling based on map bounds and height, as well as optional rotation based on player view angle.
---@param pPos table @Player position
---@param mapBound table @The bounds of the map for culling points outside of it
---@param mapCenter table @The center position of the map
---@param doRotate boolean @Whether to apply rotation to the points based on player view angle
local function drawPoints(pPos, mapBound, mapCenter, doRotate)
    -- We predefine just to avoid unbound variable warnings
    -- but we only really need if we're rotating the map
    local angleY = 0
    local angleRadians = 0
    local cosAngle = 0
    local sinAngle = 0

    local zoom = Config.mapZoomLevel
    local radiusSq = Config.halfMapSize * Config.halfMapSize

    local color = colors.WHITE

    if Config.astigmatismMode then
        color = colors.BLACK
    end

    if doRotate then
        angleY = LocalPlayer():EyeAngles().y
        angleRadians = rad(-angleY + 90) -- We rotate so 90 is upwards/north
        cosAngle = cos(angleRadians)
        sinAngle = sin(angleRadians)
    end

    local zoomLevelPointSize = Config.uiZoomLevel * Config.pointSize

    for _, pos in pairs(State.Points) do
        local diffZ = abs(pos.z - pPos.z)

        if diffZ >= Config.heightDisplayRange then continue end

        local finalX = (pos.x - pPos.x) * zoom
        local finalY = (pos.y - pPos.y) * zoom

        if doRotate or Config.roundMode then
            local rx = finalX
            finalX = finalX * cosAngle - finalY * sinAngle
            finalY = rx * sinAngle + finalY * cosAngle
        end

        local isVisible = false
        if Config.roundMode then
            local distSquared = (finalX * finalX) + (finalY * finalY)
            isVisible = distSquared < radiusSq
        else
            isVisible = abs(finalX) < mapBound.x and abs(finalY) < mapBound.y
        end

        if isVisible then
            local alpha = 255 - (diffZ * Config.heightFadeMultiplier)
            local renderX = mapCenter.x + finalX
            local renderY = mapCenter.y - finalY

            setDrawColor(color.r, color.g, color.b, alpha)
            drawRect(
                renderX,
                renderY,
                zoomLevelPointSize + 1,
                zoomLevelPointSize + 1
            )
        end
    end
end

function RenderCommon.pointRender(mapBounds, mapCenter, doRotate)
    local renderStart = SysTime()
    local playerPos = LocalPlayer():GetPos()

    draw.NoTexture()

    drawPoints(playerPos, mapBounds, mapCenter, doRotate)

    if Config.showFrameTimeDebug then
        uiUtils.PointRenderDebug(renderStart)
    end
end

return RenderCommon
