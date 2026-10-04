--[[
	DoubleJump
	Press jump again in the air. Also cancels a dive.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementConfig = require(ReplicatedStorage:WaitForChild("Shared").Config.MovementConfig)

local config = MovementConfig.DoubleJump

local DoubleJump = {}

function DoubleJump.onJumpRequest(ctx): boolean
	if not config.Enabled or ctx.grounded then
		return false
	end
	if ctx.state ~= "Normal" and ctx.state ~= "AirSlide" then
		return false
	end
	if ctx.airTime < config.MinAirTime or ctx.airJumps >= config.MaxAirJumps then
		return false
	end
	if ctx.state == "AirSlide" then
		ctx:endMove()
	end
	ctx.airJumps += 1
	local v = ctx.root.AssemblyLinearVelocity
	ctx.root.AssemblyLinearVelocity = Vector3.new(v.X, ctx:jumpPower() * config.PowerMultiplier, v.Z)
	ctx.anims:play("DoubleJump", 0.05)
	return true
end

return DoubleJump
