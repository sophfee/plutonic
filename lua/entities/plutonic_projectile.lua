/**************************************************************************/
/*	plutonic_projectile.lua												  */
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
ENT.Type = "anim"
ENT.Spawnable = false
function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(true)

    self.m_fCreationTime = CurTime();
end

function ENT:GetCreationTime()
    return self.m_fCreationTime;
end

function ENT:DoFire(hit)
	if self.Fired then return end
	self.Fired = true
	if self.FireSound then
		self:EmitSound(self.FireSound)
	end

	self.OnFire(self, self:GetOwner(), hit or nil)
	timer.Simple(
		self.RemoveWait or 0,
		function()
			if IsValid(self) then
				if self.ProjRemove then
					self:ProjRemove()
				end

				self:Remove()
			end
		end
	)
end

function ENT:Think()
	if CLIENT then return end
	if self.Fired and self.ProjThink then
		self:ProjThink()
	end

	if self.Timer and self.Timer < CurTime() then
		self:DoFire()
	end
end

function ENT:PhysicsCollide(colData, phys)
	if self.ProjTouch then
		if colData and colData.HitEntity and IsValid(colData.HitEntity) then
			if colData.HitEntity:GetClass() == "plutonic_projectile" then return end
			self:DoFire(colData.HitEntity)
		else
			self:DoFire()
		end
	elseif self.HitSound then
		self:EmitSound(self.HitSound)
	end
end