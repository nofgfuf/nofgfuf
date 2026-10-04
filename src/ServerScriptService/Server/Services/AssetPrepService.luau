--[[
	AssetPrepService
	Runs once at server start. Welds every hat, uniform piece and weapon in
	ReplicatedStorage.Assets to its Handle and unanchors it, so the files can stay simple
	anchored parts that are easy to edit in Studio. Also warns about config/model mismatches.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AssetUtil = require(Shared.Util.AssetUtil)
local WeldUtil = require(Shared.Util.WeldUtil)
local HatConfig = require(Shared.Config.HatConfig)
local MailConfig = require(Shared.Config.MailConfig)
local WeaponConfig = require(Shared.Config.WeaponConfig)
local MailmanConfig = require(Shared.Config.MailmanConfig)

local AssetPrepService = {}

local function prepHandled(category: string)
	for _, item in AssetUtil.list(category) do
		local handle = item:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			WeldUtil.clear(item)
			WeldUtil.weldTo(item, handle, true)
		else
			warn(`[AssetPrep] Assets.{category}.{item.Name} has no Handle part`)
		end
	end
end

local function checkExists(category: string, name: string, usedBy: string)
	if not AssetUtil.find(category, name) then
		warn(`[AssetPrep] {usedBy} wants Assets.{category}.{name}, but it doesn't exist`)
	end
end

function AssetPrepService.init()
	prepHandled("Hats")
	prepHandled("Accessories")
	prepHandled("Weapons")

	for id, hat in HatConfig.Hats do
		checkExists("Hats", hat.Model, `HatConfig.{id}`)
	end
	for id, mail in MailConfig.Types do
		checkExists("Mail", mail.Model, `MailConfig.{id}`)
	end
	for id, weapon in WeaponConfig.Weapons do
		checkExists("Weapons", weapon.Model, `WeaponConfig.{id}`)
	end
	for _, name in MailmanConfig.Uniform do
		checkExists("Accessories", name, "MailmanConfig.Uniform")
	end
end

return AssetPrepService
