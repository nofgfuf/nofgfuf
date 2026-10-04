--[[
	AccessoryUtil
	Puts Accessories on characters (works on models that aren't in Workspace yet, e.g. the
	StarterCharacter template) and swaps them by "Slot" attribute ("Hat", "Uniform", ...).
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

-- Attaches `accessory` to `character` using matching attachment names (like Humanoid:AddAccessory).
function AccessoryUtil.attach(character: Model, accessory: Accessory): boolean
	local handle = accessory:FindFirstChild("Handle")
	if not (handle and handle:IsA("BasePart")) then
		warn(`[AccessoryUtil] {accessory.Name} has no Handle part`)
		return false
	end

	local handleAttachment = handle:FindFirstChildWhichIsA("Attachment")
	local target = handleAttachment and findCharacterAttachment(character, handleAttachment.Name)
	if not (handleAttachment and target) then
		warn(`[AccessoryUtil] No matching attachment on {character.Name} for {accessory.Name}`)
		return false
	end

	local old = handle:FindFirstChild("AccessoryWeld")
	if old then
		old:Destroy()
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
