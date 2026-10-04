--[[
	AnimationService
	Finds your animation folder (see Config/AnimationConfig) and plugs its animations into
	each character's default "Animate" script. The folder is re-read on every spawn, so
	updated animations apply on the next respawn without touching any code.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationConfig = require(ReplicatedStorage:WaitForChild("Shared").Config.AnimationConfig)

local AnimationService = {}

local warnedNoFolder = false
local lastReport = ""

local function lowerSet(list: { string }): { [string]: boolean }
	local set = {}
	for _, name in list do
		set[string.lower(name)] = true
	end
	return set
end

function AnimationService.findFolder(): Instance?
	local wanted = lowerSet(AnimationConfig.FolderNames)
	for _, serviceName in AnimationConfig.SearchIn do
		local ok, service = pcall(game.GetService, game, serviceName)
		if ok and service then
			for _, descendant in service:GetDescendants() do
				if wanted[string.lower(descendant.Name)] and not descendant:IsA("Animation") then
					return descendant
				end
			end
		end
	end
	return nil
end

local function findAnimation(folder: Instance, names: { string }): Animation?
	local animations = {}
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Animation") and descendant.AnimationId ~= "" then
			animations[string.lower(descendant.Name)] = animations[string.lower(descendant.Name)] or descendant
		end
	end
	for _, name in names do
		local found = animations[string.lower(name)]
		if found then
			return found
		end
	end
	return nil
end

-- Returns { [slot] = animationId } for every slot found in your folder.
function AnimationService.resolve(): { [string]: string }
	local ids = {}
	local folder = AnimationService.findFolder()
	if not folder then
		if not warnedNoFolder then
			warnedNoFolder = true
			warn("[AnimationService] No animation folder found (looked for "
				.. table.concat(AnimationConfig.FolderNames, "/") .. "). Using Roblox default animations.")
		end
		return ids
	end

	for slot, names in AnimationConfig.Slots do
		local animation = findAnimation(folder, names)
		if animation then
			ids[slot] = animation.AnimationId
		end
	end
	if AnimationConfig.UseRunForWalk and ids.run and not ids.walk then
		ids.walk = ids.run
	end

	if AnimationConfig.Verbose then
		local found, missing = {}, {}
		for slot in AnimationConfig.Slots do
			table.insert(ids[slot] and found or missing, slot)
		end
		table.sort(found)
		table.sort(missing)
		local report = `[AnimationService] Using {folder:GetFullName()} | found: {table.concat(found, ", ")}`
			.. ` | default: {table.concat(missing, ", ")}`
		if report ~= lastReport then
			lastReport = report
			print(report)
		end
	end
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
