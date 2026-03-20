local Utils = {}

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
---@param color Color @The color to draw the points with
---@param mapBound table @The bounds of the map for culling points outside of it
---@param mapCenter table @The center position of the map
---@param doRotate boolean @Whether to apply rotation to the points based on player view angle
function Utils.drawPoints(pPos, color, mapBound, mapCenter, doRotate)
    -- We predefine just to avoid unbound variable warnings
    -- but we only really need if we're rotating the map
    local angleY = 0
    local angleRadians = 0
    local cosAngle = 0
    local sinAngle = 0

    if doRotate then
        angleY = LocalPlayer():EyeAngles().y
        angleRadians = math.rad(-angleY + 90) -- We rotate so 90 is upwards/north
        cosAngle = math.cos(angleRadians)
        sinAngle = math.sin(angleRadians)
    end

    for _, pos in pairs(Points) do
        local diffZ = abs(pos.z - pPos.z)

        -- TODO: Turn Z fade into a setting
        if diffZ < 500 then                    -- we don't perform any crazy arithmetic on points we're not drawing
            local alpha = 255 - (diffZ * 0.51) -- TODO: Same here

            local finalX = (pos.x - pPos.x) * Settings.mapZoomLevel
            local finalY = (pos.y - pPos.y) * Settings.mapZoomLevel

            if doRotate then
                local rotX = finalX
                finalX = finalX * cosAngle - finalY * sinAngle
                finalY = rotX * sinAngle + finalY * cosAngle
            end

            if abs(finalX) < mapBound.x and abs(finalY) < mapBound.y then
                local renderX = mapCenter.x + finalX
                local renderY = mapCenter.y - finalY

                setDrawColor(color.r, color.g, color.b, alpha)
                drawRect(renderX, renderY, 3, 3)
            end
        end
    end
end

return Utils
