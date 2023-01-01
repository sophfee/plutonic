function SWEP:ClipPercent()
	return self:Clip1() / self.Primary.ClipSize
end

LONGSWORD_SUBMACHINE_GUN = 1
LONGSWORD_AUTOMATIC_RIFLE = 2
LONGSWORD_MARKSMAN_RIFLE = 3
LONGSWORD_PISTOL = 5
LONGSWORD_SNIPER = 6
LONGSWORD_SHOTGUN = 7

local indicatorIO = {}

indicatorIO[LONGSWORD_SUBMACHINE_GUN] = {
	[1] = function(self)
		local cp = self:ClipPercent()
		return cp <= 0.4, cp * 2
	end,
	[2] = "Longsword.SMG_LowAmmo",
	[3] = "Longsword.SMG_Dry"
}

indicatorIO[LONGSWORD_PISTOL] = {
	[1] = function(self)
		local cp = self:ClipPercent()
		return cp <= 0.6, cp * 3
	end,
	[2] = "Longsword.Pistol_LowAmmo",
	[3] = "Longsword.Pistol_Dry"
}

indicatorIO[LONGSWORD_AUTOMATIC_RIFLE] = {
	[1] = function(self)
		local cp = self:ClipPercent()
		return cp <= 0.4, cp * 2
	end,
	[2] = "Longsword.Rifle_LowAmmo",
	[3] = "Longsword.Rifle_Dry"
}

function SWEP:ShouldPlayAmmoIndicator()
	return indicatorIO[self.WeaponType][1](self)
end

function SWEP:PlayAmmoIndicator()

	if not self.WeaponType then
		return
	end

	local bShouldPlay, fVolume = self:ShouldPlayAmmoIndicator()
	if bShouldPlay then
		local snd = indicatorIO[self.WeaponType][2]
		if self:Clip1() <= 0 then
			snd = indicatorIO[self.WeaponType][3]
			fVolume = 1
		end
		self:EmitSound(snd, nil, nil, fVolume )
	end
end