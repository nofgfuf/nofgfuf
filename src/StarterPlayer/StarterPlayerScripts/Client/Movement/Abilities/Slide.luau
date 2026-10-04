--[[
	Slide
	On the ground: a burst of speed that slows down to walking speed (jump to cancel).
	In the air: a forward dive. Landing while diving turns straight into a ground slide.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementConfig = require(ReplicatedStorage:WaitForChild("Shared").Config.MovementConfig)

local ground = MovementConfig.Slide
local air = MovementConfig.AirSlide

local Slide = {}

local MAX_DIVE_TIME = 3 -- give up the dive state if we somehow never land

local function horizontalSpeed(ctx): number
	local v = ctx.root.AssemblyLinearVelocity
	return Vector3.new(v.X, 0, v.Z).Magnitude
end

local function finish(ctx)
	ctx:endMove()
	ctx.slideReadyAt = os.clock() + ground.Cooldown
end

local function startGroundSlide(ctx, dir: Vector3, speed: number)
	ctx:endMove()
	ctx:setState("Slide")
	ctx.slideDir = dir
	ctx.slideStartSpeed = speed
	ctx.humanoid.AutoRotate = false
	ctx:face(dir)
	ctx.mover:setPlaneVelocity(dir * speed)
	ctx.anims:play("Slide")
end

local function startDive(ctx)
	local dir = ctx:moveDirection()
	ctx:endMove()
	ctx:setState("AirSlide")
	ctx.airSlides += 1
	ctx.slideDir = dir
	ctx.humanoid.AutoRotate = false
	ctx:face(dir)
	if air.VerticalVelocity ~= 0 then
		local v = ctx.root.AssemblyLinearVelocity
		ctx.root.AssemblyLinearVelocity = Vector3.new(v.X, math.min(v.Y, air.VerticalVelocity), v.Z)
	end
	ctx.mover:setPlaneVelocity(dir * air.Speed)
	ctx.anims:play("AirSlide")
end

function Slide.onSlidePressed(ctx): boolean
	if ctx.state ~= "Normal" or os.clock() < (ctx.slideReadyAt or 0) then
		return false
	end
	if ctx.grounded then
		local speed = horizontalSpeed(ctx)
		if not ground.Enabled or (speed < ground.MinMoveSpeed and ctx.humanoid.MoveDirection.Magnitude < 0.1) then
			return false
		end
		startGroundSlide(ctx, ctx:moveDirection(), math.max(ground.Speed, speed))
		return true
	end
	if air.Enabled and ctx.airSlides < air.MaxPerJump then
		startDive(ctx)
		return true
	end
	return false
end

function Slide.onLanded(ctx): boolean
	if ctx.state == "AirSlide" then
		if air.LandIntoSlide and ground.Enabled then
			startGroundSlide(ctx, ctx.slideDir, air.Speed)
		else
			finish(ctx)
		end
		return true
	end
	return false
end

function Slide.onJumpRequest(ctx): boolean
	if ctx.state == "Slide" then
		finish(ctx) -- the Humanoid does the actual jump
	end
	return false
end

function Slide.update(ctx)
	if ctx.state == "Slide" then
		local t = ctx.stateTime / ground.Duration
		local slidOffEdge = not ctx.grounded and ctx.airTime > 0.25
		local blocked = ctx.stateTime > 0.15 and horizontalSpeed(ctx) < 3
		if t >= 1 or slidOffEdge or blocked then
			finish(ctx)
			return
		end
		local speed = ctx.slideStartSpeed + (ground.EndSpeed - ctx.slideStartSpeed) * t
		ctx.mover:setPlaneVelocity(ctx.slideDir * speed)
	elseif ctx.state == "AirSlide" then
		-- Push forward for Duration, then keep the dive pose until landing.
		if ctx.stateTime >= air.Duration then
			ctx.mover:clearVelocity()
		end
		if ctx.stateTime >= MAX_DIVE_TIME then
			finish(ctx)
		end
	end
end

return Slide
