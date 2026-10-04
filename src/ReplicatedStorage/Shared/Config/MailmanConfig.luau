--[[
	MailmanConfig
	How the mailman looks. Change values here, press Play, done.

	The character itself is the R6 model at StarterPlayer.StarterCharacter (you can see and edit
	it in Studio). At server start its colours/clothing are set from this config, and the
	uniform + hat below are put on every time a player spawns.
]]

local MailmanConfig = {}

-- Classic blocky body colours. Shirt/Pants textures below draw on top of these.
MailmanConfig.BodyColors = {
	Head = Color3.fromRGB(245, 205, 48), -- Bright yellow (classic skin)
	LeftArm = Color3.fromRGB(245, 205, 48),
	RightArm = Color3.fromRGB(245, 205, 48),
	Torso = Color3.fromRGB(13, 105, 172), -- Bright blue uniform
	LeftLeg = Color3.fromRGB(0, 32, 96), -- Navy blue trousers
	RightLeg = Color3.fromRGB(0, 32, 96),
}

-- Classic clothing. Upload assets/clothing/MailmanShirt.png & MailmanPants.png (or your own
-- 585x559 templates) and paste the IMAGE ids here, e.g. "rbxassetid://1234567890".
-- Leave empty to just use the body colours above.
MailmanConfig.Clothing = {
	ShirtTemplate = "",
	PantsTemplate = "",
}

-- Uniform pieces from ReplicatedStorage.Assets.Accessories (file names without .rbxmx).
MailmanConfig.Uniform = {
	"MailSatchel",
	"NameBadge",
	"MailmanTie",
}

-- Hat every new player starts with (an id from HatConfig.Hats).
MailmanConfig.DefaultHat = "MailmanCap"

-- Seconds before respawning after death.
MailmanConfig.RespawnTime = 3

return MailmanConfig
