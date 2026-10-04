--[[
	GameConfig
	Game-wide switches.
]]

local GameConfig = {}

-- In Studio, check the character after every spawn and print PASS/FAIL lines to Output
-- (rig, uniform, hat, welds, animations, movement). Never runs in live servers.
GameConfig.SelfTestInStudio = true

return GameConfig
