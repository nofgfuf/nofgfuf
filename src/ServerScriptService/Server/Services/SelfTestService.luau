--[[
	SelfTestService
	Studio-only health check. A few seconds after each spawn it inspects the character and
	prints one line per check to Output:  "[SelfTest] PASS ..." or a warning "[SelfTest] FAIL ...".
	Turn it off with GameConfig.SelfTestInStudio = false.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.Config.GameConfig)
local MailmanConfig = require(Shared.Config.MailmanConfig)

local AnimationService = require(script.Parent.AnimationService)

local SelfTestService = {}

local R6_JOINTS = {
	{ "HumanoidRootPart", "RootJoint" },
	{ "Torso", "Neck" },
	{ "Torso", "Right Shoulder" },
	{ "Torso", "Left Shoulder" },
	{ "Torso", "Right Hip" },
	{ "Torso", "Left Hip" },
}

local function findBodyAttachment(character: Model, name: string): Attachment?
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("Attachment") and descendant.Name == name
			and not descendant:FindFirstAncestorOfClass("Accessory") then
			return descendant
		end
	end
	return nil
end

-- Returns nil if fine, otherwise a description of what's wrong.
local function accessoryProblem(character: Model, root: BasePart, accessory: Accessory): string?
	local handle = accessory:FindFirstChild("Handle")
	if not (handle and handle:IsA("BasePart")) then
		return "no Handle"
	end
	for _, part in accessory:GetDescendants() do
		if part:IsA("BasePart") then
			if part.Anchored then
				return `{part.Name} is anchored`
			end
			if part.AssemblyRootPart ~= root then
				return `{part.Name} is not welded to the character`
			end
		end
	end
	local handleAttachment = handle:FindFirstChildWhichIsA("Attachment")
	local bodyAttachment = handleAttachment and findBodyAttachment(character, handleAttachment.Name)
	if not bodyAttachment then
		return "no matching body attachment"
	end
	local gap = (handleAttachment.WorldPosition - bodyAttachment.WorldPosition).Magnitude
	if gap > 0.05 then
		return string.format("sits %.2f studs away from %s", gap, bodyAttachment.Name)
	end
	return nil
end

function SelfTestService.run(player: Player, character: Model)
	local passed, failed = 0, 0
	local function check(ok: boolean, label: string, problem: string?)
		if ok then
			passed += 1
			print(`[SelfTest] PASS {label}`)
		else
			failed += 1
			warn(`[SelfTest] FAIL {label}{problem and (": " .. problem) or ""}`)
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	check(humanoid ~= nil and root ~= nil, "character has Humanoid + HumanoidRootPart")
	if not (humanoid and root) then
		return
	end

	check(humanoid.RigType == Enum.HumanoidRigType.R6, "rig is R6", tostring(humanoid.RigType))
	local missingJoints = {}
	for _, joint in R6_JOINTS do
		local parent = character:FindFirstChild(joint[1])
		local motor = parent and parent:FindFirstChild(joint[2])
		if not (motor and motor:IsA("Motor6D") and motor.Part0 and motor.Part1) then
			table.insert(missingJoints, joint[2])
		end
	end
	check(#missingJoints == 0, "all R6 joints connected", "missing " .. table.concat(missingJoints, ", "))

	local torso = character:FindFirstChild("Torso")
	check(torso ~= nil and torso.Color == MailmanConfig.BodyColors.Torso, "body colours from MailmanConfig")
	check(character:FindFirstChild("Animate") ~= nil, "Animate script present")

	for _, name in MailmanConfig.Uniform do
		local accessory = character:FindFirstChild(name)
		if accessory and accessory:IsA("Accessory") then
			local problem = accessoryProblem(character, root, accessory)
			check(problem == nil, `uniform {name} attached`, problem)
		else
			check(false, `uniform {name} attached`, "not on the character")
		end
	end

	local hats = {}
	for _, child in character:GetChildren() do
		if child:IsA("Accessory") and child:GetAttribute("Slot") == "Hat" then
			table.insert(hats, child)
		end
	end
	local wanted = player:GetAttribute("EquippedHat")
	if #hats == 1 then
		local problem = accessoryProblem(character, root, hats[1])
		if hats[1]:GetAttribute("HatId") ~= wanted then
			problem = `wearing {hats[1]:GetAttribute("HatId")}, expected {wanted}`
		end
		check(problem == nil, `hat {wanted} attached`, problem)
	else
		check(false, `hat {wanted} attached`, `{#hats} hats on the character`)
	end

	local ids = AnimationService.resolve()
	check(ids.run ~= nil, "Run animation found in your animation folder",
		"none found - Roblox default is used (see AnimationConfig)")

	local summary = `[SelfTest] {player.Name}: {passed} passed, {failed} failed`
	if failed == 0 then
		print(summary)
	else
		warn(summary)
	end
end

function SelfTestService.init()
	if not (GameConfig.SelfTestInStudio and RunService:IsStudio()) then
		return
	end
	local function watch(player: Player)
		player.CharacterAdded:Connect(function(character)
			task.delay(3, function()
				if character.Parent then
					SelfTestService.run(player, character)
				end
			end)
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
end

return SelfTestService
