--[[
	AnimationFinder
	Finds your animation folder and Animation objects by name (see Config/AnimationConfig).
	Shared by the server (character animations) and the client (movement animations).
]]

local AnimationConfig = require(script.Parent.Parent.Config.AnimationConfig)

local AnimationFinder = {}

local function lowerSet(list: { string }): { [string]: boolean }
	local set = {}
	for _, name in list do
		set[string.lower(name)] = true
	end
	return set
end

-- First folder named like AnimationConfig.FolderNames inside the given services.
function AnimationFinder.findFolder(searchIn: { string }): Instance?
	local wanted = lowerSet(AnimationConfig.FolderNames)
	for _, serviceName in searchIn do
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

-- { [lowercase name] = Animation } for every Animation (with an id) under `folder`.
function AnimationFinder.index(folder: Instance?): { [string]: Animation }
	local animations = {}
	if folder then
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("Animation") and descendant.AnimationId ~= "" then
				local key = string.lower(descendant.Name)
				animations[key] = animations[key] or descendant
			end
		end
	end
	return animations
end

-- AnimationId of the first name in `names` that exists in `index`, or nil.
function AnimationFinder.pick(index: { [string]: Animation }, names: { string }): string?
	for _, name in names do
		local animation = index[string.lower(name)]
		if animation then
			return animation.AnimationId
		end
	end
	return nil
end

return AnimationFinder
