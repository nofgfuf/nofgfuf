--[[
	MovementController
	Runs the parkour moves for the local player's character. Each move lives in ./Abilities
	and can react to these events (all optional, return true to "use up" the event):
	  onJumpRequest(ctx)        jump pressed (fresh press only)
	  onSlidePressed(ctx)       slide key / button pressed
	  onLanded(ctx, fallHeight) touched the ground after being airborne
	  update(ctx, dt)           every frame
	Abilities are asked in ABILITY_ORDER. Tuning lives in Shared/Config/MovementConfig.

	ctx.state is one of: "Normal", "Slide", "AirSlide", "Hang", "Climb", "Roll".
]]

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MovementConfig = require(Shared.Config.MovementConfig)
local GameConfig = require(Shared.Config.GameConfig)

local Mover = require(script.Parent:WaitForChild("Mover"))
local AnimPlayer = require(script.Parent:WaitForChild("AnimPlayer"))

local ABILITY_ORDER = { "LedgeGrab", "Slide", "LandingRoll", "DoubleJump" }
local SLIDE_ACTION = "MailmanSlide"

local player = Players.LocalPlayer
local abilities = {}
local abilityFolder = script.Parent:WaitForChild("Abilities")
for _, name in ABILITY_ORDER do
	table.insert(abilities, require(abilityFolder:WaitForChild(name)))
end

local MovementController = {}

-- ------------------------------------------------------------------ per-character context

local Context = {}
Context.__index = Context

function Context:setState(state: string)
	self.state = state
	self.stateTime = 0
end

-- Stops whatever move is running and gives control back to the Humanoid.
function Context:endMove()
	self.mover:clearVelocity()
	self.mover:release()
	self.humanoid.AutoRotate = true
	self.humanoid.PlatformStand = false
	self.anims:stopMoves()
	self:setState("Normal")
end

-- Flat unit direction the player is steering (or facing, if not steering).
function Context:moveDirection(): Vector3
	local steer = self.humanoid.MoveDirection
	local dir = Vector3.new(steer.X, 0, steer.Z)
	if dir.Magnitude < 0.1 then
		local look = self.root.CFrame.LookVector
		dir = Vector3.new(look.X, 0, look.Z)
	end
	return dir.Unit
end

function Context:face(dir: Vector3)
	local position = self.root.Position
	self.root.CFrame = CFrame.lookAt(position, position + dir)
end

function Context:jumpPower(): number
	return MovementConfig.JumpPower * (1 + (player:GetAttribute("HatBoost_Jump") or 0))
end

function Context:fire(event: string, ...): boolean
	for _, ability in abilities do
		local handler = ability[event]
		if handler and handler(self, ...) then
			return true
		end
	end
	return false
end

local ctx = nil

local function applyStats(c)
	c.humanoid.UseJumpPower = true
	c.humanoid.JumpPower = c:jumpPower()
	c.humanoid.WalkSpeed = MovementConfig.WalkSpeed * (1 + (player:GetAttribute("HatBoost_Speed") or 0))
end

local function report(c)
	if not (GameConfig.SelfTestInStudio and RunService:IsStudio()) then
		return
	end
	local found, missing = c.anims:report()
	print(`[Movement] Ready. WalkSpeed {c.humanoid.WalkSpeed}, JumpPower {c.humanoid.JumpPower}`
		.. ` | move anims: {#found > 0 and table.concat(found, ", ") or "none"}`
		.. ` | placeholders (no anim yet): {#missing > 0 and table.concat(missing, ", ") or "none"}`)
end

local function bind(character: Model)
	if ctx then
		for _, connection in ctx.connections do
			connection:Disconnect()
		end
	end
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local root = character:WaitForChild("HumanoidRootPart") :: BasePart

	local c = setmetatable({
		character = character,
		humanoid = humanoid,
		root = root,
		mover = Mover.new(root),
		anims = AnimPlayer.new(humanoid),
		state = "Normal",
		stateTime = 0,
		grounded = true,
		airTime = 0,
		airJumps = 0,
		airSlides = 0,
		peakY = root.Position.Y,
		connections = {},
	}, Context)
	ctx = c

	applyStats(c)
	for _, attribute in { "HatBoost_Speed", "HatBoost_Jump" } do
		table.insert(c.connections, player:GetAttributeChangedSignal(attribute):Connect(function()
			applyStats(c)
		end))
	end
	table.insert(c.connections, humanoid.Died:Connect(function()
		c.dead = true
		pcall(c.endMove, c)
	end))
	report(c)
end

-- ------------------------------------------------------------------ events

local function update(dt: number)
	local c = ctx
	if not c or c.dead or not c.root.Parent then
		return
	end
	c.stateTime += dt

	local y = c.root.Position.Y
	if c.state == "Hang" or c.state == "Climb" then
		c.grounded = false
		c.airTime = 0
		c.peakY = y
	elseif c.humanoid.FloorMaterial ~= Enum.Material.Air then
		if not c.grounded then
			c.grounded = true
			c:fire("onLanded", c.peakY - y)
		end
		c.airTime = 0
		c.airJumps = 0
		c.airSlides = 0
		c.peakY = y
	else
		c.grounded = false
		c.airTime += dt
		c.peakY = math.max(c.peakY, y)
	end

	for _, ability in abilities do
		if ability.update then
			ability.update(c, dt)
		end
	end
end

local lastJumpRequest = 0
local function onJumpRequest()
	-- JumpRequest repeats while the button is held; only react to a fresh press.
	local now = os.clock()
	local fresh = now - lastJumpRequest > 0.12
	lastJumpRequest = now
	if fresh and ctx and not ctx.dead then
		ctx:fire("onJumpRequest")
	end
end

local function onSlideAction(_, inputState: Enum.UserInputState)
	if inputState == Enum.UserInputState.Begin and ctx and not ctx.dead then
		ctx:fire("onSlidePressed")
		return Enum.ContextActionResult.Sink
	end
	return Enum.ContextActionResult.Pass
end

function MovementController.start()
	player.CharacterAdded:Connect(bind)
	if player.Character then
		task.spawn(bind, player.Character)
	end

	UserInputService.JumpRequest:Connect(onJumpRequest)
	RunService.Heartbeat:Connect(update)

	ContextActionService:BindAction(SLIDE_ACTION, onSlideAction, MovementConfig.MobileButtons,
		table.unpack(MovementConfig.SlideKeys))
	ContextActionService:SetTitle(SLIDE_ACTION, "Slide")
	ContextActionService:SetPosition(SLIDE_ACTION, UDim2.new(1, -170, 1, -90))
end

return MovementController
