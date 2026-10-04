--[[
	HatConfig
	Every hat in the game: price, rarity, boosts and upgrades.

	Adding a hat:
	  1. Put an Accessory in ReplicatedStorage.Assets.Hats (it needs a Handle with a
	     "HatAttachment" inside; extra parts are welded automatically).
	  2. Add an entry below whose key matches the model name (or set Model = "...").

	Boosts are fractions: 0.10 = +10%. Each upgrade level adds Upgrades.BoostPerLevel of the
	base boost, so a +10% hat at level 5 (with 0.25 per level) gives +20%.
	Systems read the final numbers from player attributes "HatBoost_<Stat>" (see HatService).
]]

local HatConfig = {}

HatConfig.Stats = {
	Speed = { DisplayName = "Run Speed", Icon = "👟" },
	Jump = { DisplayName = "Jump Power", Icon = "⬆️" },
	Cash = { DisplayName = "Delivery Cash", Icon = "💵" },
	XP = { DisplayName = "XP", Icon = "⭐" },
}

HatConfig.Rarities = {
	Starter = { Order = 0, Color = Color3.fromRGB(163, 162, 165) },
	Common = { Order = 1, Color = Color3.fromRGB(242, 243, 243) },
	Uncommon = { Order = 2, Color = Color3.fromRGB(75, 151, 75) },
	Rare = { Order = 3, Color = Color3.fromRGB(13, 105, 172) },
	Epic = { Order = 4, Color = Color3.fromRGB(98, 37, 209) },
	Legendary = { Order = 5, Color = Color3.fromRGB(245, 205, 48) },
	Mythic = { Order = 6, Color = Color3.fromRGB(255, 0, 191) },
}

HatConfig.Upgrades = {
	MaxLevel = 5,
	BoostPerLevel = 0.25, -- each level adds 25% of the hat's base boosts
	CostMultiplier = 0.5, -- upgrade to level N costs Price * CostMultiplier * CostGrowth^(N-2)
	CostGrowth = 1.6,
	MinUpgradeCost = 50, -- used for free hats (Price = 0)
}

HatConfig.Hats = {
	MailmanCap = {
		DisplayName = "Mailman Cap",
		Rarity = "Starter",
		Price = 0,
		Boosts = { Cash = 0.05 },
		Description = "Standard issue. Smells like stamps.",
	},
	NewspaperHat = {
		DisplayName = "Newspaper Hat",
		Rarity = "Common",
		Price = 250,
		Boosts = { XP = 0.10 },
		Description = "Folded from today's headlines.",
	},
	PropellerBeanie = {
		DisplayName = "Propeller Beanie",
		Rarity = "Common",
		Price = 400,
		Boosts = { Jump = 0.08 },
		Description = "Almost lets you fly. Almost.",
	},
	TrafficCone = {
		DisplayName = "Traffic Cone",
		Rarity = "Uncommon",
		Price = 1200,
		Boosts = { Speed = 0.06 },
		Description = "Cars will finally see you coming.",
	},
	CowboyHat = {
		DisplayName = "Rodeo Courier",
		Rarity = "Uncommon",
		Price = 1800,
		Boosts = { Speed = 0.04, Cash = 0.06 },
		Description = "Yeehaw, special delivery!",
	},
	TopHat = {
		DisplayName = "Postmaster's Top Hat",
		Rarity = "Rare",
		Price = 5000,
		Boosts = { Cash = 0.20 },
		Description = "Very fancy. Very rich.",
	},
	VikingHelmet = {
		DisplayName = "Viking Helmet",
		Rarity = "Rare",
		Price = 6500,
		Boosts = { Jump = 0.12, Speed = 0.05 },
		Description = "Raid every mailbox on the street.",
	},
	WizardHat = {
		DisplayName = "Stamp Wizard",
		Rarity = "Epic",
		Price = 15000,
		Boosts = { XP = 0.25, Jump = 0.10 },
		Description = "Abra-ca-delivery.",
	},
	RoyalCrown = {
		DisplayName = "Royal Mail Crown",
		Rarity = "Epic",
		Price = 25000,
		Boosts = { Cash = 0.30, XP = 0.10 },
		Description = "By royal appointment.",
	},
	MailboxHat = {
		DisplayName = "Mailbox Head",
		Rarity = "Legendary",
		Price = 60000,
		Boosts = { Cash = 0.35, Speed = 0.10, XP = 0.15 },
		Description = "You ARE the mail now.",
	},
	GoldenMailmanCap = {
		DisplayName = "Golden Mailman Cap",
		Rarity = "Mythic",
		Price = 150000,
		Boosts = { Cash = 0.50, Speed = 0.15, Jump = 0.15, XP = 0.25 },
		Description = "Only for the greatest mailman of all time.",
	},
}

-- Fill in defaults so every entry has Id + Model.
for id, hat in HatConfig.Hats do
	hat.Id = id
	hat.Model = hat.Model or id
	hat.Boosts = hat.Boosts or {}
end

function HatConfig.get(hatId: string)
	return HatConfig.Hats[hatId]
end

-- Final boosts for a hat at an upgrade level (1 = not upgraded).
function HatConfig.getBoosts(hatId: string, level: number?): { [string]: number }
	local hat = HatConfig.Hats[hatId]
	local result = {}
	for stat in HatConfig.Stats do
		result[stat] = 0
	end
	if not hat then
		return result
	end
	local lvl = math.clamp(level or 1, 1, HatConfig.Upgrades.MaxLevel)
	local multiplier = 1 + (lvl - 1) * HatConfig.Upgrades.BoostPerLevel
	for stat, value in hat.Boosts do
		result[stat] = value * multiplier
	end
	return result
end

-- Cost to upgrade from (level - 1) to level. Returns nil when already maxed / invalid.
function HatConfig.getUpgradeCost(hatId: string, level: number): number?
	local hat = HatConfig.Hats[hatId]
	local cfg = HatConfig.Upgrades
	if not hat or level < 2 or level > cfg.MaxLevel then
		return nil
	end
	local base = math.max(hat.Price * cfg.CostMultiplier, cfg.MinUpgradeCost)
	return math.floor(base * cfg.CostGrowth ^ (level - 2) + 0.5)
end

-- All hats sorted by rarity then price (handy for the shop UI).
function HatConfig.getSorted()
	local list = {}
	for _, hat in HatConfig.Hats do
		table.insert(list, hat)
	end
	table.sort(list, function(a, b)
		local ra, rb = HatConfig.Rarities[a.Rarity].Order, HatConfig.Rarities[b.Rarity].Order
		if ra ~= rb then
			return ra < rb
		end
		return a.Price < b.Price
	end)
	return list
end

return HatConfig
