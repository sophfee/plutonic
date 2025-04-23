/**************************************************************************/
/*  client/ammoindicator.lua                                              */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)         */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)        */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

function SWEP:ClipPercent()
	return self:Clip1() / self.Primary.ClipSize
end

Plutonic.Enum.WeaponType = {
	SubmachineGun = 1,
	AutomaticRifle = 2,
	MarksmanRifle = 3,
	Pistol = 5,
	Sniper = 6,
	Shotgun = 7
}

local indicatorIO = {}
indicatorIO[Plutonic.Enum.WeaponType.SubmachineGun] = {
	[1] = function(self)
		local cp = self:ClipPercent()

		return cp <= 0.4, 1 - (cp / 0.4)
	end,
	[2] = "Plutonic.SMG_LowAmmo",
	[3] = "Plutonic.SMG_Dry"
}

indicatorIO[Plutonic.Enum.WeaponType.Pistol] = {
	[1] = function(self)
		local cp = self:ClipPercent()

		return cp <= 0.6, 1 - (cp / 0.6)
	end,
	[2] = "Plutonic.Pistol_LowAmmo",
	[3] = "Plutonic.Pistol_Dry"
}

indicatorIO[Plutonic.Enum.WeaponType.AutomaticRifle] = {
	[1] = function(self)
		local cp = self:ClipPercent()

		return cp <= 0.4, 1 - (cp / 0.4)
	end,
	[2] = "Plutonic.Rifle_LowAmmo",
	[3] = "Plutonic.Rifle_Dry"
}

function SWEP:ShouldPlayAmmoIndicator()
	return false
end

--indicatorIO[self.Enum.WeaponType][1](self)
function SWEP:PlayAmmoIndicator()
	if not self.Enum then return end
	if not self.Enum.WeaponType then return end
	local bShouldPlay, fVolume = self:ShouldPlayAmmoIndicator()
	if bShouldPlay then
		local snd = indicatorIO[self.Enum.WeaponType][2]
		if self:Clip1() <= 0 then
			snd = indicatorIO[self.Enum.WeaponType][3]
			fVolume = 1
		end

		self.GonnaAdjustVol = true
		self.RequiredVolume = fVolume
		self:EmitSound(snd, nil, nil, fVolume, SND_CHANGE_VOL)
	end
end