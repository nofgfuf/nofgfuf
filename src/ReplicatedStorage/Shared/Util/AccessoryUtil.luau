--[[
	AccessoryUtil
	Puts Accessories on characters and swaps them by "Slot" attribute ("Hat", "Uniform", ...).
	Characters in Workspace use Roblox's own Humanoid:AddAccessory. Models outside Workspace
	(e.g. previews) get the same weld built by hand.
]]

local AccessoryUtil = {}

local function findCharacterAttachment(character: Model, name: string): Attachment?
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("Attachment") and descendant.Name == name then
			local part = descendant.Parent
			-- Skip attachments that belong to other accessories.
			if part and part:IsA("BasePart") and not part:FindFirstAncestorOfClass("Accessory") then
				return descendant
			end
		end
	end
	return nil
end

local function weldByHand(character: Model, accessory: Accessory, handle: BasePart): boolean
	local handleAttachment = handle:FindFirstChildWhichIsA("Attachment")
	local target = handleAttachment and findCharacterAttachment(character, handleAttachment.Name)
	if not (handleAttachment and target) then
		warn(`[AccessoryUtil] No matching attachment on {character.Name} for {accessory.Name}`)
		return false
	end
	accessory.Parent = character
	local weld = Instance.new("Weld")
	weld.Name = "AccessoryWeld"
	weld.Part0 = handle
	weld.Part1 = target.Parent :: BasePart
	weld.C0 = handleAttachment.CFrame
	weld.C1 = target.CFrame
	weld.Parent = handle
	return true
end

-- Attaches `accessory` to `character` using matching attachment names.
function AccessoryUtil.attach(character: Model, accessory: Accessory): boolean
	local handle = accessory:FindFirstChild("Handle")
	if not (handle and handle:IsA("BasePart")) then
		warn(`[AccessoryUtil] {accessory.Name} has no Handle part`)
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and character:IsDescendantOf(workspace) then
		humanoid:AddAccessory(accessory)
		return accessory.Parent == character
	end
	return weldByHand(character, accessory, handle)
end

function AccessoryUtil.getBySlot(character: Model, slot: string): { Accessory }
	local found = {}
	for _, child in character:GetChildren() do
		if child:IsA("Accessory") and child:GetAttribute("Slot") == slot then
			table.insert(found, child)
		end
	end
	return found
end

function AccessoryUtil.removeSlot(character: Model, slot: string)
	for _, accessory in AccessoryUtil.getBySlot(character, slot) do
		accessory:Destroy()
	end
end

return AccessoryUtil
