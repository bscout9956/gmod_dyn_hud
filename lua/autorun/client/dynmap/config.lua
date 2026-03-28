local Config = {}

Config.ConfigFramePresent = false
Config.showFrameTimeDebug = true
Config.uiZoomLevel = 0.5
Config.astigmatismMode = false
Config.uiResolution = 1 -- Fractional, the higher the worse, keep it small
Config.borderThickness = 3
Config.heightDisplayRange = 500
Config.heightFadeMultiplier = 0.51

-- HUD Parameters
Config.spacing = 20
Config.margin = 20
Config.mapSize = math.floor(0.125 * ScrW())
Config.playerIndicatorSize = 18
Config.playerIndicatorNotch = 0.5
Config.roundMode = false -- Whether to use a round map or not

-- Big Map Parameters
Config.bigMapSizeX = math.floor(0.75 * ScrW())
Config.bigMapSizeY = math.floor(0.75 * ScrH())

return Config
