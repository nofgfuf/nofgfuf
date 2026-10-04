--[[
	AnimationConfig
	Points the game at YOUR animation folder. When you add or update animations, just replace
	the Animation objects inside that folder (keep the names) - no script changes needed.

	Keep the folder in ReplicatedStorage: the movement moves (slide, roll...) are played by the
	client, which can't see ServerStorage.
	Animations must be R6 (the mailman is R6) and owned by you / the group that owns the game.
]]

local AnimationConfig = {}

-- Folder names to look for (first match wins, case-insensitive) ...
AnimationConfig.FolderNames = { "Animations", "Anims", "Animation" }

-- ... searched (recursively) inside these services, in this order.
AnimationConfig.SearchIn = { "ReplicatedStorage", "Workspace", "ServerStorage" }

-- ------------------------------------------------------------------ default character anims
-- Slots of Roblox's "Animate" script -> Animation names to look for in your folder
-- (case-insensitive, subfolders are fine, first match wins). Missing = Roblox default.
AnimationConfig.Slots = {
	run = { "Run", "Running", "RunAnim", "RunAnimation", "Sprint" },
	walk = { "Walk", "Walking", "WalkAnim", "WalkAnimation" },
	idle = { "Idle", "IdleAnim", "IdleAnimation" },
	jump = { "Jump", "JumpAnim", "JumpAnimation" },
	fall = { "Fall", "Falling", "FallAnim", "FallAnimation" },
	climb = { "Climb", "Climbing", "ClimbAnim", "ClimbAnimation" },
	swim = { "Swim", "Swimming", "SwimAnim" },
	swimidle = { "SwimIdle", "SwimIdleAnim" },
	sit = { "Sit", "SitAnim" },
	toolnone = { "ToolNone", "Hold", "ToolHold" },
}

-- R6 plays the "walk" slot whenever the character moves. true = use your Run animation there
-- (the mailman always runs). Set false to use a separate Walk animation instead.
AnimationConfig.UseRunForWalk = true

-- ------------------------------------------------------------------ movement anims (placeholders)
-- Animations for the parkour moves. Add Animations with any of these names to your folder.
-- Until you do, the moves still work, they just don't play an animation.
AnimationConfig.Moves = {
	Slide = { "Slide", "SlideAnim", "Sliding" },
	AirSlide = { "AirSlide", "Dive", "DiveAnim" },
	DoubleJump = { "DoubleJump", "AirJump", "Flip" },
	LedgeHang = { "LedgeHang", "Hang", "LedgeGrab", "LedgeIdle" },
	ClimbUp = { "ClimbUp", "LedgeClimb", "Mantle" },
	Roll = { "Roll", "LandingRoll", "RollAnim" },
}

-- Placeholder slots: paste an id here (e.g. "rbxassetid://123") to use it without the folder.
-- An id here wins over the folder.
AnimationConfig.MoveIds = {
	Slide = "",
	AirSlide = "",
	DoubleJump = "",
	LedgeHang = "",
	ClimbUp = "",
	Roll = "",
}

-- If a move has no animation, use this other move's animation instead.
AnimationConfig.MoveFallbacks = {
	AirSlide = "Slide",
}

-- Print which animations were found / missing in the Output window.
AnimationConfig.Verbose = true

return AnimationConfig
