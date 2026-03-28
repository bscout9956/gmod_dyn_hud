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

return Utils
