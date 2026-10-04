--[[
	AnimationConfig
	Points the game at YOUR animation folder. When you add or update animations, just replace
	the Animation objects inside that folder (keep the names) - no script changes needed.

	How it works: on every spawn the server finds your folder, looks up each slot's names below
	and writes the AnimationId into the character's default "Animate" script.
	Animations must be owned by you / the group that owns the game, or Roblox won't load them.
]]

local AnimationConfig = {}

-- Folder names to look for (first match wins, case-insensitive) ...
AnimationConfig.FolderNames = { "Animations", "Anims", "Animation" }

-- ... searched (recursively) inside these services, in this order.
AnimationConfig.SearchIn = { "ReplicatedStorage", "ServerStorage", "StarterPlayer", "Workspace" }

-- Animate-script slot -> Animation names to look for in your folder (case-insensitive,
-- searched recursively, first match wins). Missing ones keep Roblox's default animation.
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

-- R15's Animate blends "walk" at low speed and "run" at high speed. true = use the run
-- animation for walking too (so the mailman always runs), unless you have a "walk" anim.
AnimationConfig.UseRunForWalk = true

-- Print which animations were found / missing in the Output window.
AnimationConfig.Verbose = true

return AnimationConfig
