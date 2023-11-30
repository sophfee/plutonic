/**************************************************************************/
/*	sv_falloff.lua											              */
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

Plutonic.Hooks.Add(
	"ScalePlayerDamage",
	function(ply, hitgroup, dmg)
		local attacker = dmg:GetAttacker()
		if IsValid(attacker) and attacker:IsPlayer() then
			local wep = attacker:GetActiveWeapon()
			if wep.IsPlutonic and wep.Primary and wep.Primary.Falloff then
				local dist = ply:GetPos():DistToSqr(attacker:GetPos())
				local falloff = wep.Primary.Falloff ^ 2
				local startFalloff = wep.Primary.StartFalloff ^ 2
				if dist > startFalloff then
					local v = math.Clamp((dist - startFalloff) / (falloff - startFalloff), 0, 1)
					dmg:ScaleDamage(1 - v)
				end
			end
		end
	end
)