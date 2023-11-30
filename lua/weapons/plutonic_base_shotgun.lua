/**************************************************************************/
/*	plutonic_base_shotgun.lua											      		  */
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

AddCSLuaFile()

SWEP.Base = "plutonic_base"
function SWEP:Reload()
	if not self:CanReload() then return end
	self:PlayAnim(ACT_SHOTGUN_RELOAD_START)
	self:GetOwner():DoReloadEvent()
	self:QueueIdle()
	self:SetReloading(true)
	self:SetReloadTime(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
	if self.ReloadSound then
		self:EmitSound(self.ReloadSound)
	end

	hook.Run("LongswordWeaponReload", self:GetOwner(), self)
end

function SWEP:InsertShell()
	self:SetClip1(self:Clip1() + 1)
	self:GetOwner():RemoveAmmo(1, self:GetPrimaryAmmoType())
	self:PlayAnim(ACT_VM_RELOAD)
	self:QueueIdle()
	self:SetReloadTime(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
	if self.ReloadShellSound then
		self:EmitSound(self.ReloadShellSound)
	end
end

function SWEP:ReloadThink()
	if self:GetReloadTime() > CurTime() then return end
	if self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) > 0 and not self:GetOwner():KeyDown(IN_ATTACK) then
		self:InsertShell()
	else
		self:FinishReload()
	end
end

function SWEP:FinishReload()
	self:SetReloading(false)
	self:PlayAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self:SetReloadTime(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
	self:QueueIdle()
	if self.PumpSound then
		self:EmitSound(self.PumpSound)
	end
end