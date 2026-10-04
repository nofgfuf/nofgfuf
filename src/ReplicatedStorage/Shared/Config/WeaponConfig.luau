--[[
	WeaponConfig
	Fun weapons for later. The models are ready in ReplicatedStorage.Assets.Weapons; combat
	scripts come in a future update, so everything is disabled for now.
]]

local WeaponConfig = {}

WeaponConfig.Weapons = {
	NewspaperBat = {
		DisplayName = "The Daily Whack",
		Enabled = false,
		Type = "Melee",
		Damage = 15,
		Cooldown = 0.6,
		Knockback = 40,
		Price = 2500,
	},
	ParcelLauncher = {
		DisplayName = "Parcel Launcher",
		Enabled = false,
		Type = "Projectile",
		Damage = 25,
		Cooldown = 1.5,
		ProjectileSpeed = 90,
		ProjectileModel = "Parcel", -- from Assets.Mail
		Price = 12000,
	},
}

for id, weapon in WeaponConfig.Weapons do
	weapon.Id = id
	weapon.Model = weapon.Model or id
end

return WeaponConfig
