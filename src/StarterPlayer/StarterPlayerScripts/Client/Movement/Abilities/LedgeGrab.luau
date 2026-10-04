--[[
	LedgeGrab
	While in the air and holding toward a wall, grab its top edge if it's within reach.
	Hanging: Jump = climb up, Slide key or moving away from the wall = let go.
	A ledge is only grabbed if there's room to stand on top of it.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementConfig = require(ReplicatedStorage:WaitForChild("Shared").Config.MovementConfig)

local config = MovementConfig.LedgeGrab

local STAND_HEIGHT = 3.05 -- R6 HumanoidRootPart height above the floor when standing
local CLIMB_UP_PORTION = 0.6 -- share of ClimbTime spent going up (the rest goes forward)

local LedgeGrab = {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude

local function flat(v: Vector3): Vector3?
	local f = Vector3.new(v.X, 0, v.Z)
	return if f.Magnitude > 1e-3 then f.Unit else nil
end

local function hasRoomToStand(position: Vector3): boolean
	for _, part in workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(1.6, 4.4, 1.2), overlapParams) do
		if part.CanCollide then
			return false
		end
	end
	return true
end

local function findLedge(ctx)
	local root = ctx.root
	local look = flat(root.CFrame.LookVector)
	if not look then
		return nil
	end
	if config.RequireMoveTowardWall and ctx.humanoid.MoveDirection:Dot(look) < 0.3 then
		return nil
	end
	rayParams.FilterDescendantsInstances = { ctx.character }
	overlapParams.FilterDescendantsInstances = { ctx.character }

	-- 1. A wall in front (checked at head and chest height).
	local wall
	for _, height in { 1.6, 0.6 } do
		local hit = workspace:Raycast(root.Position + Vector3.new(0, height, 0), look * config.ReachForward, rayParams)
		if hit and math.abs(hit.Normal.Y) < 0.3 and hit.Instance.CanCollide then
			wall = hit
			break
		end
	end
	local normal = wall and flat(wall.Normal)
	if not (wall and normal) then
		return nil
	end

	-- 2. Its top surface, within reach above us.
	local origin = Vector3.new(wall.Position.X, root.Position.Y + config.MaxHeight + 0.3, wall.Position.Z) - normal * 0.35
	local down = workspace:Raycast(origin, Vector3.new(0, -(config.MaxHeight - config.MinHeight + 0.3), 0), rayParams)
	if not (down and down.Normal.Y > 0.7 and down.Instance.CanCollide) then
		return nil
	end
	local height = down.Position.Y - root.Position.Y
	if height < config.MinHeight or height > config.MaxHeight then
		return nil
	end

	-- 3. Room to stand on top.
	local stand = down.Position - normal * 1.0 + Vector3.new(0, STAND_HEIGHT, 0)
	if not hasRoomToStand(stand) then
		return nil
	end
	return { normal = normal, wallPoint = wall.Position, top = down.Position, stand = stand }
end

local function grab(ctx, ledge)
	ctx:endMove()
	ctx:setState("Hang")
	local position = Vector3.new(ledge.wallPoint.X, ledge.top.Y - config.HangDepth, ledge.wallPoint.Z)
		+ ledge.normal * config.WallGap
	ledge.hang = CFrame.lookAt(position, position - ledge.normal)
	ctx.ledge = ledge
	ctx.humanoid.AutoRotate = false
	ctx.humanoid.PlatformStand = true
	ctx.root.AssemblyLinearVelocity = Vector3.zero
	ctx.mover:hold(ledge.hang)
	ctx.anims:play("LedgeHang", 0.08)
	ctx.airJumps = 0
	ctx.airSlides = 0
end

local function letGo(ctx)
	ctx:endMove()
	ctx.root.AssemblyLinearVelocity = Vector3.zero
	ctx.ledge = nil
	ctx.regrabAt = os.clock() + config.RegrabCooldown
end

local function startClimb(ctx)
	local ledge = ctx.ledge
	ctx:setState("Climb")
	ctx.anims:stop("LedgeHang", 0.1)
	ctx.anims:play("ClimbUp", 0.05)
	ledge.from = ledge.hang.Position
	ledge.mid = Vector3.new(ledge.from.X, ledge.stand.Y, ledge.from.Z)
end

function LedgeGrab.onJumpRequest(ctx): boolean
	if ctx.state == "Hang" then
		startClimb(ctx)
		return true
	end
	return ctx.state == "Climb"
end

function LedgeGrab.onSlidePressed(ctx): boolean
	if ctx.state == "Hang" then
		letGo(ctx)
		return true
	end
	return ctx.state == "Climb"
end

function LedgeGrab.update(ctx)
	if ctx.state == "Hang" then
		if ctx.humanoid.MoveDirection:Dot(ctx.ledge.normal) > 0.6 then
			letGo(ctx)
		end
	elseif ctx.state == "Climb" then
		local ledge = ctx.ledge
		local t = math.clamp(ctx.stateTime / config.ClimbTime, 0, 1)
		local position = if t < CLIMB_UP_PORTION
			then ledge.from:Lerp(ledge.mid, t / CLIMB_UP_PORTION)
			else ledge.mid:Lerp(ledge.stand, (t - CLIMB_UP_PORTION) / (1 - CLIMB_UP_PORTION))
		ctx.mover:hold(CFrame.lookAt(position, position - ledge.normal))
		if t >= 1 then
			letGo(ctx)
		end
	elseif config.Enabled and (ctx.state == "Normal" or ctx.state == "AirSlide") and not ctx.grounded
		and ctx.airTime > 0.1 and os.clock() >= (ctx.regrabAt or 0) then
		local ledge = findLedge(ctx)
		if ledge then
			grab(ctx, ledge)
		end
	end
end

return LedgeGrab
