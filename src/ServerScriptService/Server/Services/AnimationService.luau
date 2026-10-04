--[[
	AnimationService
	Plugs your animations (see Config/AnimationConfig) into each character's default "Animate"
	script. The folder is re-read on every spawn, so updated animations apply on the next
	respawn without touching any code.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AnimationConfig = require(Shared.Config.AnimationConfig)
local AnimationFinder = require(Shared.Util.AnimationFinder)

local AnimationService = {}

local lastReport = ""

local function report(message: string, isWarning: boolean?)
	if message ~= lastReport then
		lastReport = message
		if isWarning then
			warn(message)
		elseif AnimationConfig.Verbose then
			print(message)
		end
	end
end

-- Returns { [slot] = animationId } for every Animate slot found in your folder.
function AnimationService.resolve(): { [string]: string }
	local ids = {}
	local folder = AnimationFinder.findFolder(AnimationConfig.SearchIn)
	if not folder then
		report("[AnimationService] No animation folder found (looked for "
			.. table.concat(AnimationConfig.FolderNames, "/") .. "). Using Roblox default animations.", true)
		return ids
	end

	local index = AnimationFinder.index(folder)
	for slot, names in AnimationConfig.Slots do
		ids[slot] = AnimationFinder.pick(index, names)
	end
	if AnimationConfig.UseRunForWalk and ids.run then
		ids.walk = ids.run
	end

	local found, missing = {}, {}
	for slot in AnimationConfig.Slots do
		table.insert(ids[slot] and found or missing, slot)
	end
	table.sort(found)
	table.sort(missing)
	report(`[AnimationService] Using {folder:GetFullName()} | found: {table.concat(found, ", ")}`
		.. ` | default: {table.concat(missing, ", ")}`)
	return ids
end

-- Writes the ids into the character's Animate script (it reloads them automatically).
function AnimationService.applyTo(character: Model)
	local ids = AnimationService.resolve()
	if next(ids) == nil then
		return
	end
	local animate = character:WaitForChild("Animate", 10)
	if not animate then
		warn(`[AnimationService] {character.Name} has no Animate script`)
		return
	end
	for slot, id in ids do
		local slotValue = animate:FindFirstChild(slot)
		if slotValue then
			for _, animation in slotValue:GetChildren() do
				if animation:IsA("Animation") then
					animation.AnimationId = id
				end
			end
		end
	end
end

return AnimationService
