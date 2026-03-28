local Utils = {}
local colors = include("colors.lua")

local abs = math.abs
local setDrawColor = surface.SetDrawColor
local drawRect = surface.DrawRect

--- Converts a boolean value to a string for display purposes
---@param value boolean @The boolean value to convert to a string
function Utils.boolToStr(value)
    if value then
        return "On"
    else
        return "Off"
    end
end

---comment
---@param pPos table @Player position
---@param mapBound table @The bounds of the map for culling points outside of it
---@param mapCenter table @The center position of the map
---@param doRotate boolean @Whether to apply rotation to the points based on player view angle
function Utils.drawPoints(pPos, mapBound, mapCenter, doRotate)
    -- We predefine just to avoid unbound variable warnings
    -- but we only really need if we're rotating the map
    local angleY = 0
    local angleRadians = 0
    local cosAngle = 0
    local sinAngle = 0

    local zoom = Settings.mapZoomLevel
    local radiusSq = Settings.halfMapSize * Settings.halfMapSize

    local color = colors.WHITE

    if Settings.astigmatismMode then
        color = colors.BLACK
    end

    if doRotate then
        angleY = LocalPlayer():EyeAngles().y
        angleRadians = math.rad(-angleY + 90) -- We rotate so 90 is upwards/north
        cosAngle = math.cos(angleRadians)
        sinAngle = math.sin(angleRadians)
    end

    for _, pos in pairs(Points) do
        local diffZ = abs(pos.z - pPos.z)

        if diffZ >= Settings.heightDisplayRange then continue end

        local finalX = (pos.x - pPos.x) * zoom
        local finalY = (pos.y - pPos.y) * zoom

        if doRotate or Settings.roundMode then
            local rx = finalX
            finalX = finalX * cosAngle - finalY * sinAngle
            finalY = rx * sinAngle + finalY * cosAngle
        end

        local isVisible = false
        if Settings.roundMode then
            local distSquared = (finalX * finalX) + (finalY * finalY)
            isVisible = distSquared < radiusSq
        else
            isVisible = abs(finalX) < mapBound.x and abs(finalY) < mapBound.y
        end

        if isVisible then
            local alpha = 255 - (diffZ * Settings.heightFadeMultiplier)
            local renderX = mapCenter.x + finalX
            local renderY = mapCenter.y - finalY

            setDrawColor(color.r, color.g, color.b, alpha)
            drawRect(renderX, renderY, 3, 3)
        end
    end
end

return Utils
