--[[
	HatService
	Which hat a player wears and what boosts it gives.

	Player attributes (server-set, readable by any script / UI):
	  EquippedHat       string  hat id from HatConfig
	  EquippedHatLevel  number  upgrade level (1..MaxLevel)
	  HatBoost_<Stat>   number  final boost, e.g. HatBoost_Speed = 0.06 (= +6%)

	Testing tip: in Play mode select your Player (server view) and change EquippedHat in the
	Attributes panel - the hat swaps instantly.
	Buying/owning/upgrading + saving is the shop step; it will call HatService.equip().
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local HatConfig = require(Shared.Config.HatConfig)
local MailmanConfig = require(Shared.Config.MailmanConfig)
local AssetUtil = require(Shared.Util.AssetUtil)
local AccessoryUtil = require(Shared.Util.AccessoryUtil)

local HatService = {}

local function applyBoosts(player: Player)
	local boosts = HatConfig.getBoosts(player:GetAttribute("EquippedHat"), player:GetAttribute("EquippedHatLevel"))
	for stat, value in boosts do
		player:SetAttribute(`HatBoost_{stat}`, value)
	end
end

-- Makes the character wear the player's equipped hat (no-op if it already does).
function HatService.applyTo(player: Player, character: Model)
	local hatId = player:GetAttribute("EquippedHat")
	local hat = HatConfig.get(hatId)
	if not hat then
		return
	end
	local current = AccessoryUtil.getBySlot(character, "Hat")
	if #current == 1 and current[1]:GetAttribute("HatId") == hat.Id then
		return
	end
	AccessoryUtil.removeSlot(character, "Hat")
	local accessory = AssetUtil.clone("Hats", hat.Model) :: Accessory
	accessory:SetAttribute("Slot", "Hat")
	accessory:SetAttribute("HatId", hat.Id)
	AccessoryUtil.attach(character, accessory)
end

function HatService.equip(player: Player, hatId: string, level: number?): boolean
	if not HatConfig.get(hatId) then
		warn(`[HatService] Unknown hat "{hatId}"`)
		return false
	end
	player:SetAttribute("EquippedHatLevel", math.clamp(level or 1, 1, HatConfig.Upgrades.MaxLevel))
	player:SetAttribute("EquippedHat", hatId) -- triggers the swap below
	return true
end

local function onPlayerAdded(player: Player)
	if player:GetAttribute("EquippedHat") == nil then
		player:SetAttribute("EquippedHat", MailmanConfig.DefaultHat)
	end
	if player:GetAttribute("EquippedHatLevel") == nil then
		player:SetAttribute("EquippedHatLevel", 1)
	end
	applyBoosts(player)

	local function refresh()
		applyBoosts(player)
		if player.Character then
			HatService.applyTo(player, player.Character)
		end
	end
	player:GetAttributeChangedSignal("EquippedHat"):Connect(refresh)
	player:GetAttributeChangedSignal("EquippedHatLevel"):Connect(refresh)
end

function HatService.init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
end

return HatService
