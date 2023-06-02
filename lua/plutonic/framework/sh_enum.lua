--- Enumerations used throughout Plutonic.
-- @module Enum

Plutonic.Enum = Plutonic.Enum or {}
Plutonic.Enum.WeaponType = {
	SubmachineGun = 1,
	AutomaticRifle = 2,
	MarksmanRifle = 3,
	Pistol = 5,
	Sniper = 6,
	Shotgun = 7
}

--- The different types of weaponry.
-- @realm shared
-- @field SubmachineGun
-- @field AutomaticRifle
-- @field MarksmanRifle
-- @field Pistol
-- @field Sniper
-- @field Shotgun
-- @table WeaponType

Plutonic.Enum.BarrelLength = {
	Short = 5.04,
	Medium = 10.16,
	Long = 15.24,
	Custom = function( len )
		return len -- we do this cus it looks cool
	end
}

--- The different barrel lengths. Generally use Custom.
-- @realm shared
-- @field Short
-- @field Medium
-- @field Long
-- @field Custom
-- @table BarrelLength

Plutonic.Enum.Modification = {
	BarrelExtension = "barrel_ext",
	Barrel = "barrel",
	Stock = "stock",
	Optic = "sight",
	Handguard = "handguard",
	Foregrip = "grip",
	Rail = "att",
	Trigger = "trigger"
}

--- The different types of modifications.
-- @realm shared
-- @field BarrelExtension
-- @field Barrel
-- @field Stock
-- @field Optic
-- @field Handguard
-- @field Foregrip
-- @field Rail
-- @field Trigger
-- @table Modification


Plutonic.Enum.Sound = {
	GunShot = 140,
	GunShotSilence = 85,
	Generic = 60
}

Plutonic.Enum.FireMode = {
	Safety,
	Semi,
	Burst,
	Auto
}