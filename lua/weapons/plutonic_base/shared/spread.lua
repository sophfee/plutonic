/**************************************************************************/
/*	shared/spread.lua											      	  */
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

function SWEP:CalculateSpread()
	local spread = self.Primary.Cone
	if self:GetOwner():IsNPC() then return spread end
	local maxSpeed = self.LoweredPos and self:GetOwner():GetWalkSpeed() or self:GetOwner():GetRunSpeed()
	spread = spread + self.Primary.Cone * math.Clamp(self:GetOwner():GetVelocity():Length2D() / maxSpeed, 0, self.Spread.VelocityMod)
	spread = spread + self:GetRecoil() * self.Spread.RecoilMod
	if not self:GetOwner():IsOnGround() then
		spread = spread * self.Spread.AirMod
	end

	if self:GetOwner():IsOnGround() and self:GetOwner():Crouching() then
		spread = spread * self.Spread.CrouchMod
	end

	if self:GetIronsights() then
		spread = spread * (self.Spread.IronsightsMod or 1)
	end

	spread = math.Clamp(spread, self.Spread.Min, self.Spread.Max)
	if Plutonic.IsClient then
		self.LastSpread = Lerp(FrameTime() * 8, self.LastSpread or 0, spread)
	end

	return spread
end

function SWEP:AddRecoil()
	self:SetRecoil(math.Clamp(self:GetRecoil() + self.Primary.Recoil * 0.4, 0, self.Primary.MaxRecoil or 1))
	self:DoRecoil()
end

SWEP.Primary.RecoilSide = 1
SWEP.Primary.RecoilUp = 1
SWEP.Primary.RecoilDown = 1
function SWEP:DoRecoil()
	local recoil = self:GetRecoil()
	local maxDown = self.Primary.RecoilDown * recoil
	local maxSide = self.Primary.RecoilSide * recoil
	local side = math.Rand(-maxSide, maxSide)
	local up = math.Rand(-maxDown, maxDown)
	self:GetOwner():ViewPunch(Angle(up, side, side * .34))
end