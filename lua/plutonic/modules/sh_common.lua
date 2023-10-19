/**************************************************************************/
/*	sh_common.lua											              */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)		  */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)		  */
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

Plutonic.Common = {}
Plutonic.Common.Category = "Landis: Guns"
Plutonic.Common.Tracer = "Tracer"
Plutonic.Common.MuzzleEffect = "muzzleflash_1"
Plutonic.WeaponSounds = Plutonic.WeaponSounds or {}
Plutonic.AddWeaponSound = function(name, path, type, volume, pitch)
	type = type or "Generic"
	volume = volume or 1
	pitch = pitch or 100
	sound.Add(
		{
			name = name,
			channel = CHAN_WEAPON,
			volume = volume,
			level = Plutonic.Enum.Sound[type],
			pitch = pitch,
			sound = path
		}
	)
end

Plutonic.LowQualityConvar = CreateClientConVar("plutonic_lowquality", 0, true, false, "Enable low quality mode for Plutonic weapons.")
Plutonic.IsLowQuality = function()
	return Plutonic.LowQualityConvar:GetBool()
end

Plutonic.NoBlurConVar = CreateClientConVar("plutonic_no_blur", 0, true, false, "Disables blurring on RT scopes.")
Plutonic.NoBlur = function()
	return Plutonic.NoBlurConVar:GetBool()
end