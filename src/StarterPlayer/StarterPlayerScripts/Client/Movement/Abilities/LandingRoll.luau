--[[
	LandingRoll
	Landing from MinFallHeight or higher rolls you forward instead of stopping dead.
	Jump to cancel the roll.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementConfig = require(ReplicatedStorage:WaitForChild("Shared").Config.MovementConfig)

local config = MovementConfig.LandingRoll

local LandingRoll = {}

function LandingRoll.onLanded(ctx, fallHeight: number): boolean
	if not config.Enabled or ctx.state ~= "Normal" or fallHeight < config.MinFallHeight then
		return false
	end
	local dir = ctx:moveDirection()
	ctx:setState("Roll")
	ctx.humanoid.AutoRotate = false
	ctx:face(dir)
	ctx.mover:setPlaneVelocity(dir * config.Speed)
	ctx.anims:play("Roll", 0.05)
	return true
end

function LandingRoll.onJumpRequest(ctx): boolean
	if ctx.state == "Roll" then
		ctx:endMove()
	end
	return false
end

function LandingRoll.update(ctx)
	if ctx.state == "Roll" and ctx.stateTime >= config.Duration then
		ctx:endMove()
	end
end

return LandingRoll
