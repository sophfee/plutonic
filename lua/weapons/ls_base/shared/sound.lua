sound.Add({
	name = "Longsword.SMG_LowAmmo",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 60,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_indicator_smg.wav"
})

sound.Add({
	name = "Longsword.SMG_Dry",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 88,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_dry_smg.wav"
})
sound.Add({
	name = "Longsword.Pistol_LowAmmo",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 60,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_indicator_handgun.wav"
})

sound.Add({
	name = "Longsword.Pistol_Dry",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 88,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_dry_handgun.wav"
})

sound.Add({
	name = "Longsword.Shotgun_LowAmmo",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 60,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_indicator_shotgun.wav"
})

sound.Add({
	name = "Longsword.Shotgun_Dry",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 88,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_dry_shotgun.wav"
})

sound.Add({
	name = "Longsword.Rifle_LowAmmo",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 60,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_indicator_ar.wav"
})

sound.Add({
	name = "Longsword.Rifle_Dry",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 88,
	pitch = {95, 105},
	sound = "weapons/tfa/lowammo_dry_ar.wav"
})

-- based off of TFA base
hook.Add("EntityEmitSound", "Longsword2Sounddata", function(soundData)
	local ent = soundData.Entity
	local modified
	local weapon

	if ent:IsWeapon() then
		weapon = ent
	elseif ent:IsNPC() or ent:IsPlayer() then
		weapon = ent:GetActiveWeapon()
	end

	if IsValid(weapon) and weapon.IsLongsword then
		if weapon.GonnaAdjuctPitch then
			soundData.Pitch = soundData.Pitch * weapon.RequiredPitch
			weapon.GonnaAdjuctPitch = false
			modified = true
		end

		if weapon.GonnaAdjustVol then
			soundData.Volume = soundData.Volume * weapon.RequiredVolume
			weapon.GonnaAdjustVol = false
			modified = true
		end
	end

	return modified
end)
