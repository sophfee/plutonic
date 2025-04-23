/**************************************************************************/
/*	shared/reload.lua											      	  */
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

function SWEP:CanReload()
	if self:GetOwner():IsNPC() then return self:Clip1() < self.Primary.ClipSize and not self:GetReloading() and self:GetNextPrimaryFire() < CurTime() end
	if self:GetReloading() then return end
	if self:IsSprinting() then return false end
	if self:GetNextPrimaryFire() > CurTime() then return end
	if self:Ammo1() == 0 then return false end
	-- Chambering
	if self.CannotChamber then
		return self:Clip1() < self.Primary.ClipSize
	else
		if self:Clip1() == 0 then return self:Clip1() < self.Primary.ClipSize + 1 end

		return self:Clip1() < self.Primary.ClipSize + 1
	end
end

function SWEP:Reload()
	if not self:CanReload() then return end
	self:GetOwner():DoReloadEvent()
	if not self.DoEmptyReloadAnim or self:Clip1() ~= 0 then
		self:PlayAnim(ACT_VM_RELOAD)
	else
		self:PlayAnim(ACT_VM_RELOAD_EMPTY)
	end

	self:QueueIdle()
	if self.ReloadSound then
		self:EmitSound(Sound(self.ReloadSound))
	elseif self.OnReload then
		self.OnReload(self)
	end

	if self.ReloadWorldSound and SERVER then
		self:EmitWorldSound(self.ReloadWorldSound)
	end

	self:SetReloading(true)
	self:SetReloadTime(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
    if CLIENT then gui.AddCaption("<I><clr:100,160,170>[Reloading]</clr></I>", 3.0, true) end
	hook.Run("LongswordWeaponReload", self:GetOwner(), self)
end

function SWEP:FinishReload()
	self:SetReloading(false)
	self.m_bDryFired = false;
	local amount
	-- one in the chamber
	if self.CannotChamber then
		amount = math.min(self:GetMaxClip1() - self:Clip1(), self:Ammo1())
	else
		if self:Clip1() == 0 then
			amount = math.min(self:GetMaxClip1() - self:Clip1(), self:Ammo1())
		else
			amount = math.min((self:GetMaxClip1() + 1) - self:Clip1(), self:Ammo1())
		end
	end

    if CLIENT then gui.AddCaption("<I><clr:100,160,170>[Finished reload]</clr></I>", 3.0, true) end
	self:SetClip1(self:Clip1() + amount)
	self:GetOwner():RemoveAmmo(amount, self:GetPrimaryAmmoType())
end