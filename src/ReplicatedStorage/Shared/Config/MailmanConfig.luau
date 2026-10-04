--[[
	MailmanConfig
	How the mailman StarterCharacter is built. Change values here, press Play, done.

	The character is generated at server start from a HumanoidDescription (blocky R15 by
	default = the classic 2019 look) and then dressed with models from ReplicatedStorage.Assets.
]]

local MailmanConfig = {}

-- Build StarterPlayer.StarterCharacter from this config. Set to false if you'd rather drop
-- your own hand-made "StarterCharacter" model into StarterPlayer.
MailmanConfig.BuildStarterCharacter = true

-- R15 or R6. MUST match the rig your animations were made for, or they won't play.
MailmanConfig.RigType = Enum.HumanoidRigType.R15

-- Classic blocky body colours. Shirt/Pants textures below draw on top of these.
MailmanConfig.BodyColors = {
	Head = Color3.fromRGB(245, 205, 48), -- Bright yellow (classic skin)
	LeftArm = Color3.fromRGB(245, 205, 48),
	RightArm = Color3.fromRGB(245, 205, 48),
	Torso = Color3.fromRGB(13, 105, 172), -- Bright blue uniform
	LeftLeg = Color3.fromRGB(0, 32, 96), -- Navy blue trousers
	RightLeg = Color3.fromRGB(0, 32, 96),
}

-- Body proportions (1 = classic). Keep BodyType/Proportion at 0 for the blocky 2019 shape.
MailmanConfig.Scale = {
	Height = 1,
	Width = 1,
	Depth = 1,
	Head = 1,
	BodyType = 0,
	Proportion = 0,
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
