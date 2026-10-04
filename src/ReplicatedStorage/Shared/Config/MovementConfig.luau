--[[
	MovementConfig
	Parkour tuning. Speeds are studs/second, times are seconds.
	Hat boosts are applied on top: HatBoost_Speed scales WalkSpeed, HatBoost_Jump scales
	JumpPower and the double jump.
]]

local MovementConfig = {}

MovementConfig.WalkSpeed = 16
MovementConfig.JumpPower = 50

-- Keys for the slide button (also: drop off a ledge). Touch screens get an on-screen button.
MovementConfig.SlideKeys = { Enum.KeyCode.LeftControl, Enum.KeyCode.C, Enum.KeyCode.ButtonB }
MovementConfig.MobileButtons = true

MovementConfig.DoubleJump = {
	Enabled = true,
	MaxAirJumps = 1, -- jumps allowed in the air (2 = triple jump)
	PowerMultiplier = 1.0, -- x JumpPower
	MinAirTime = 0.12, -- can't air-jump this soon after leaving the ground
}

-- Slide on the ground: a burst of speed that slows down to walking speed.
MovementConfig.Slide = {
	Enabled = true,
	Speed = 42,
	EndSpeed = 16,
	Duration = 0.75,
	Cooldown = 0.35,
	MinMoveSpeed = 4, -- have to be moving at least this fast to start a slide
}

-- Slide in the air: dive forward. Landing during the dive turns into a ground slide.
MovementConfig.AirSlide = {
	Enabled = true,
	Speed = 46,
	Duration = 0.4,
	VerticalVelocity = -12, -- downward push when the dive starts (0 = keep current)
	MaxPerJump = 1,
	LandIntoSlide = true,
}

MovementConfig.LedgeGrab = {
	Enabled = true,
	ReachForward = 2.4, -- how far in front of you a wall can be
	MinHeight = 0.6, -- ledge top must be between these heights above your torso centre
	MaxHeight = 3.6,
	HangDepth = 2.3, -- how far below the ledge top your torso hangs
	WallGap = 0.65, -- distance from the wall while hanging
	ClimbTime = 0.4,
	RegrabCooldown = 0.45,
	RequireMoveTowardWall = true, -- only grab while holding toward the wall
	-- While hanging: Jump = climb up, Slide key or moving away from the wall = let go.
}

-- Roll when landing from high up (keeps your speed instead of stopping dead).
MovementConfig.LandingRoll = {
	Enabled = true,
	MinFallHeight = 14,
	Speed = 30,
	Duration = 0.45,
}

return MovementConfig
