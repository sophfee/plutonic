/**************************************************************************/
/*	cl_sway.lua															  */
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

local abs = math.abs
Plutonic.Hooks.Add(
	"StartCommand",
	function(ply, ucmd)
		if ply.GetActiveWeapon then
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) and wep.IsPlutonic then
				local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()
				local i = wep.SwayMultiplier or 0.0004
				local n = wep.SwayMultiplier or 0.0056
				local m = wep:GetIronsights() and i or n
				if abs(x) > 0 or abs(y) > 0 then
					wep.VMDeltaX = wep.VMDeltaX + ucmd:GetMouseX() * m
					wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * m
					wep.VMDeltaXWeighted = wep.VMDeltaXWeighted + ucmd:GetMouseX() * .01
					wep.VMDeltaYWeighted = wep.VMDeltaYWeighted + ucmd:GetMouseY() * .01
				end
			end
		end
	end
)

Plutonic.Hooks.Add(
	"RenderScreenspaceEffects",
	function()
		local lp = LocalPlayer()
		if not IsValid(lp) then return end
		local wep = lp:GetActiveWeapon()
		if not IsValid(wep) then return end
		if not wep.IsPlutonic then return end
		local ir = wep.VMIronsights or 0
		if ir <= 0 then return end
		//DrawToyTown(12 * ir, ScrH() / 2.2)
	end
)