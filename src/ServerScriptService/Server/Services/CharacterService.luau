--[[
	CharacterService
	Sets up the mailman StarterCharacter (StarterPlayer.StarterCharacter, R6) from
	Config/MailmanConfig and handles spawning:
	  * colours + clothing are applied to the template once at server start
	  * the uniform, hat and animations are applied every time a player spawns

	Players.CharacterAutoLoads is off so nobody spawns before the template is ready; this
	service spawns and respawns players itself (MailmanConfig.RespawnTime).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MailmanConfig = require(Shared.Config.MailmanConfig)
local AssetUtil = require(Shared.Util.AssetUtil)
local AccessoryUtil = require(Shared.Util.AccessoryUtil)

local Services = script.Parent
local HatService = require(Services.HatService)
local AnimationService = require(Services.AnimationService)

local CharacterService = {}

local BODY_PARTS = {
	Head = "Head",
	Torso = "Torso",
	LeftArm = "Left Arm",
	RightArm = "Right Arm",
	LeftLeg = "Left Leg",
	RightLeg = "Right Leg",
}

local templateReady = false
local readyWaiters: { thread } = {}

local function setClothing(character: Model, className: string, name: string, property: string, template: string)
	local existing = character:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
	if template ~= "" then
		local clothing = Instance.new(className)
		clothing.Name = name
		clothing[property] = template
		clothing.Parent = character
	end
end

function CharacterService.prepareTemplate(template: Model)
	for key, partName in BODY_PARTS do
		local bodyPart = template:FindFirstChild(partName)
		if bodyPart and bodyPart:IsA("BasePart") and MailmanConfig.BodyColors[key] then
			bodyPart.Color = MailmanConfig.BodyColors[key]
		end
	end
	setClothing(template, "Shirt", "MailmanShirt", "ShirtTemplate", MailmanConfig.Clothing.ShirtTemplate)
	setClothing(template, "Pants", "MailmanPants", "PantsTemplate", MailmanConfig.Clothing.PantsTemplate)
end

-- Puts the uniform on a spawned character (hat is handled by HatService).
function CharacterService.dress(character: Model)
	AccessoryUtil.removeSlot(character, "Uniform")
	for _, name in MailmanConfig.Uniform do
		if AssetUtil.find("Accessories", name) then
			local accessory = AssetUtil.clone("Accessories", name) :: Accessory
			accessory:SetAttribute("Slot", "Uniform")
			AccessoryUtil.attach(character, accessory)
		end
	end
end

local function markReady()
	templateReady = true
	for _, thread in readyWaiters do
		task.spawn(thread)
	end
	table.clear(readyWaiters)
end

local function waitUntilReady()
	if not templateReady then
		table.insert(readyWaiters, coroutine.running())
		coroutine.yield()
	end
end

local function onCharacterAdded(player: Player, character: Model)
	-- Accessories must be added once the character is in Workspace.
	while not character:IsDescendantOf(workspace) do
		character.AncestryChanged:Wait()
	end
	CharacterService.dress(character)
	HatService.applyTo(player, character)
	task.spawn(AnimationService.applyTo, character)

	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoid.Died:Once(function()
		task.wait(MailmanConfig.RespawnTime)
		if player.Parent and player.Character == character then
			player:LoadCharacter()
		end
	end)
end

local function onPlayerAdded(player: Player)
	player.CanLoadCharacterAppearance = false -- don't put the player's own avatar items on the mailman
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	waitUntilReady()
	if player.Parent then
		player:LoadCharacter()
	end
end

function CharacterService.init()
	Players.CharacterAutoLoads = false
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

function CharacterService.start()
	local template = StarterPlayer:WaitForChild("StarterCharacter", 10)
	if template then
		CharacterService.prepareTemplate(template)
	else
		warn("[CharacterService] StarterPlayer.StarterCharacter is missing - players spawn as their own avatar")
	end
	markReady()
end

return CharacterService
