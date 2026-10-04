--[[
	Client entry point. Starts the client systems (only movement for now).
]]

local Movement = script.Parent:WaitForChild("Movement")

require(Movement:WaitForChild("MovementController")).start()
