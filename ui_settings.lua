local UISettings = {}

local SCREEN_WIDTH = ScrW()
local SCREEN_HEIGHT = ScrH()
UISettings.FRAME_WIDTH = 0.5 * SCREEN_WIDTH
UISettings.FRAME_HEIGHT = 0.5 * SCREEN_HEIGHT

UISettings.LEFT_MARGIN = 0.01 * SCREEN_WIDTH
UISettings.TOP_MARGIN = 0.03 * SCREEN_HEIGHT

local gridCountX, gridCountY = 2, 20
UISettings.gridSizeX = UISettings.FRAME_WIDTH / gridCountX
UISettings.gridSizeY = UISettings.FRAME_HEIGHT / gridCountY

return UISettings
