--[[
	AnimPlayer
	Plays the parkour move animations (AnimationConfig.Moves) on the local character.
	Moves without an animation are placeholders: play()/stop() simply do nothing for them.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AnimationConfig = require(Shared.Config.AnimationConfig)
local AnimationFinder = require(Shared.Util.AnimationFinder)

local AnimPlayer = {}
AnimPlayer.__index = AnimPlayer

function AnimPlayer.new(humanoid: Humanoid)
	local self = setmetatable({}, AnimPlayer)
	self.animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 5)
	self.tracks = {}
	self.ids = {}

	local folder = AnimationFinder.findFolder(AnimationConfig.SearchIn)
	local index = AnimationFinder.index(folder)
	for move, names in AnimationConfig.Moves do
		local override = AnimationConfig.MoveIds[move]
		self.ids[move] = if override and override ~= "" then override else AnimationFinder.pick(index, names)
	end
	for move, fallback in AnimationConfig.MoveFallbacks do
		self.ids[move] = self.ids[move] or self.ids[fallback]
	end
	return self
end

function AnimPlayer:getTrack(move: string): AnimationTrack?
	local cached = self.tracks[move]
	if cached ~= nil then
		return cached or nil
	end
	local track = false
	local id = self.ids[move]
	if id and self.animator then
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		local ok, result = pcall(self.animator.LoadAnimation, self.animator, animation)
		if ok then
			result.Priority = Enum.AnimationPriority.Action
			track = result
		else
			warn(`[Movement] Couldn't load {move} animation {id}: {result}`)
		end
	end
	self.tracks[move] = track
	return track or nil
end

function AnimPlayer:play(move: string, fadeTime: number?, speed: number?)
	local track = self:getTrack(move)
	if track then
		track:Play(fadeTime or 0.1, 1, speed or 1)
	end
end

function AnimPlayer:stop(move: string, fadeTime: number?)
	local track = self.tracks[move]
	if track then
		track:Stop(fadeTime or 0.15)
	end
end

function AnimPlayer:stopMoves()
	for _, track in self.tracks do
		if track then
			track:Stop(0.15)
		end
	end
end

-- Lists of move names with / without an animation (for the Output report).
function AnimPlayer:report(): ({ string }, { string })
	local found, missing = {}, {}
	for move in AnimationConfig.Moves do
		table.insert(self.ids[move] and found or missing, move)
	end
	table.sort(found)
	table.sort(missing)
	return found, missing
end

return AnimPlayer
