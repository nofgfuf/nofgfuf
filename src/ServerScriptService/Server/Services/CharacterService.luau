--[[
	CharacterService
	Builds the mailman StarterCharacter from Config/MailmanConfig and handles spawning.

	Players.CharacterAutoLoads is turned off so nobody spawns before the mailman exists;
	this service spawns and respawns players itself (MailmanConfig.RespawnTime).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MailmanConfig = require(Shared.Config.MailmanConfig)
local HatConfig = require(Shared.Config.HatConfig)
local AssetUtil = require(Shared.Util.AssetUtil)
local AccessoryUtil = require(Shared.Util.AccessoryUtil)

local Services = script.Parent
local HatService = require(Services.HatService)
local AnimationService = require(Services.AnimationService)

local CharacterService = {}

local starterReady = false
local readyWaiters: { thread } = {}

local function makeDescription(): HumanoidDescription
	local description = Instance.new("HumanoidDescription")
	local colors = MailmanConfig.BodyColors
	description.HeadColor = colors.Head
	description.LeftArmColor = colors.LeftArm
	description.RightArmColor = colors.RightArm
	description.TorsoColor = colors.Torso
	description.LeftLegColor = colors.LeftLeg
	description.RightLegColor = colors.RightLeg

	local scale = MailmanConfig.Scale
	description.HeightScale = scale.Height
	description.WidthScale = scale.Width
	description.DepthScale = scale.Depth
	description.HeadScale = scale.Head
	description.BodyTypeScale = scale.BodyType
	description.ProportionScale = scale.Proportion
	return description
end

local function addClothing(character: Model)
	local clothing = MailmanConfig.Clothing
	if clothing.ShirtTemplate ~= "" then
		local shirt = Instance.new("Shirt")
		shirt.Name = "MailmanShirt"
		shirt.ShirtTemplate = clothing.ShirtTemplate
		shirt.Parent = character
	end
	if clothing.PantsTemplate ~= "" then
		local pants = Instance.new("Pants")
		pants.Name = "MailmanPants"
		pants.PantsTemplate = clothing.PantsTemplate
		pants.Parent = character
	end
end

local function dress(character: Model)
	for _, name in MailmanConfig.Uniform do
		if AssetUtil.find("Accessories", name) then
			local accessory = AssetUtil.clone("Accessories", name) :: Accessory
			accessory:SetAttribute("Slot", "Uniform")
			AccessoryUtil.attach(character, accessory)
		end
	end
	local hat = HatConfig.get(MailmanConfig.DefaultHat)
	if hat and AssetUtil.find("Hats", hat.Model) then
		local accessory = AssetUtil.clone("Hats", hat.Model) :: Accessory
		accessory:SetAttribute("Slot", "Hat")
		accessory:SetAttribute("HatId", hat.Id)
		AccessoryUtil.attach(character, accessory)
	end
end

function CharacterService.buildMailman(): Model
	local character
	for attempt = 1, 5 do
		local ok, result = pcall(function()
			return Players:CreateHumanoidModelFromDescription(makeDescription(), MailmanConfig.RigType)
		end)
		if ok then
			character = result
			break
		end
		warn(`[CharacterService] Building mailman failed (attempt {attempt}): {result}`)
		task.wait(attempt)
	end
	assert(character, "[CharacterService] Could not build the mailman character")

	character.Name = "StarterCharacter"
	addClothing(character)
	dress(character)
	character:SetAttribute("GeneratedMailman", true)
	return character
end

local function markReady()
	starterReady = true
	for _, thread in readyWaiters do
		task.spawn(thread)
	end
	table.clear(readyWaiters)
end

local function waitUntilReady()
	if not starterReady then
		table.insert(readyWaiters, coroutine.running())
		coroutine.yield()
	end
end

local function onCharacterAdded(player: Player, character: Model)
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
	if MailmanConfig.BuildStarterCharacter then
		local mailman = CharacterService.buildMailman()
		local old = StarterPlayer:FindFirstChild("StarterCharacter")
		if old then
			old:Destroy()
		end
		mailman.Parent = StarterPlayer
	elseif not StarterPlayer:FindFirstChild("StarterCharacter") then
		warn("[CharacterService] BuildStarterCharacter is off and StarterPlayer has no StarterCharacter")
	end
	markReady()
end

return CharacterService
