Plutonic.Enum = Plutonic.Enum or {}
Plutonic.Enum.WeaponType = {
	SubmachineGun = 1,
	AutomaticRifle = 2,
	MarksmanRifle = 3,
	Pistol = 5,
	Sniper = 6,
	Shotgun = 7
}
Plutonic.Enum.BarrelLength = {
	Short = 5.04,
	Medium = 10.16,
	Long = 15.24,
	Custom = function( len )
		return len -- we do this cus it looks cool
	end
}