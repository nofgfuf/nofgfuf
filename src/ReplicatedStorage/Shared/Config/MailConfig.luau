--[[
	MailConfig
	Mail types and the props they're delivered to. Values are placeholders for the delivery
	system (next step) - tune freely.
	Model = name of the model in ReplicatedStorage.Assets.Mail
]]

local MailConfig = {}

MailConfig.Types = {
	Letter = {
		DisplayName = "Letter",
		Model = "Letter",
		Payout = 5,
		XP = 2,
		BagSpace = 1, -- how much satchel space it takes
		SpawnWeight = 60, -- relative chance when handing out mail
	},
	MailBundle = {
		DisplayName = "Bundle of Letters",
		Model = "MailBundle",
		Payout = 15,
		XP = 5,
		BagSpace = 2,
		SpawnWeight = 25,
	},
	Parcel = {
		DisplayName = "Parcel",
		Model = "Parcel",
		Payout = 30,
		XP = 10,
		BagSpace = 4,
		SpawnWeight = 12,
	},
	BigPackage = {
		DisplayName = "Big Package",
		Model = "BigPackage",
		Payout = 100,
		XP = 30,
		BagSpace = 10,
		SpawnWeight = 3,
		CarryWithBothHands = true,
	},
}

MailConfig.Props = {
	Mailbox = "Mailbox", -- delivery target at each house
	PickupBox = "PostBox", -- where mail is collected
	MailSack = "MailSack",
}

-- How much the satchel holds before you need to refill (upgradeable later).
MailConfig.StartingBagSize = 10

return MailConfig
