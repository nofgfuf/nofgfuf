--[[
	AssetUtil
	One place to fetch models from ReplicatedStorage.Assets.

		AssetUtil.clone("Hats", "TopHat")     --> a fresh copy (errors if missing)
		AssetUtil.find("Mail", "Parcel")      --> the template or nil (don't edit it!)
		AssetUtil.list("Hats")                --> { template, ... }
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetUtil = {}

local function getRoot(): Instance
	return ReplicatedStorage:WaitForChild("Assets")
end

function AssetUtil.find(category: string, name: string): Instance?
	local folder = getRoot():FindFirstChild(category)
	return folder and folder:FindFirstChild(name)
end

function AssetUtil.clone(category: string, name: string): Instance
	local template = AssetUtil.find(category, name)
	if not template then
		error(`[AssetUtil] Missing asset ReplicatedStorage.Assets.{category}.{name}`, 2)
	end
	return template:Clone()
end

function AssetUtil.list(category: string): { Instance }
	local folder = getRoot():FindFirstChild(category)
	return folder and folder:GetChildren() or {}
end

return AssetUtil
