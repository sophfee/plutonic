/**************************************************************************/
/*	plutonic_base_melee.lua                                               */
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

AddCSLuaFile()

SWEP.Base = "plutonic_base"
SWEP.IsMelee = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Sound = Sound("WeaponFrag.Roll")
SWEP.Primary.ImpactSound = Sound("Canister.ImpactHard")
function SWEP:PrimaryAttack()
	if self.PrePrimaryAttack then
		self.PrePrimaryAttack(self)
	end

	if self.Primary.HitDelay then
		timer.Simple(
			self.Primary.HitDelay,
			function()
				if IsValid(self) and IsValid(self:GetOwner()) then
					self:ClubAttack()
					self:ViewPunch()
				end
			end
		)
	else
		self:ClubAttack()
		self:ViewPunch()
	end

	self:EmitSound(self.Primary.Sound)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	--[[self:PlayAnim(self.HitAnim or ACT_VM_HITCENTER)
	if self.DoFireAnim then
		self:PlayAnim(ACT_VM_PRIMARYATTACK)
	else
		self:PlayAnim(ACT_VM_HITCENTER)
	end
	]]
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
end

function SWEP:Think()
	if CLIENT then
		self:ViewmodelThink()
	end

	self:IdleThink()
	if self.CustomThink then
		self.CustomThink(self)
	end
end

function SWEP:Reload()
	return
end

function SWEP:ClubAttack()
	local trace = {}
	trace.start = self:GetOwner():GetShootPos()
	trace.endpos = trace.start + self:GetOwner():GetAimVector() * (self.Primary.Range or 85)
	trace.filter = self:GetOwner()
	trace.mask = MASK_SHOT_HULL
	local boxSize = self.Primary.HullSize or 6
	trace.mins = Vector(-boxSize, -boxSize, -boxSize)
	trace.maxs = Vector(boxSize, boxSize, boxSize)
	self:GetOwner():LagCompensation(true)
	local tr = util.TraceHull(trace)
	self:GetOwner():LagCompensation(false)
	if CLIENT then
		debugoverlay.BoxAngles(tr.HitPos, trace.mins, trace.maxs, self:GetOwner():EyeAngles(), 5, Color(200, 0, 0, 100))
	end

	if SERVER and tr.Hit then
		self:PlayAnim(ACT_VM_HITCENTER)
		hook.Run("LongswordMeleeHit", self:GetOwner())
		if self.Primary.ImpactSound and not self.Primary.ImpactSoundWorldOnly then
			self:GetOwner():EmitSound(self.Primary.ImpactSound)
		end

		if self.Primary.ImpactEffect then
			local effect = EffectData()
			effect:SetStart(tr.HitPos)
			effect:SetNormal(tr.HitNormal)
			effect:SetOrigin(tr.HitPos)
			util.Effect(self.Primary.ImpactEffect, effect, true, true)
		end

		local ent = tr.Entity
		if IsValid(ent) then
			local newdmg = hook.Run("LongswordCalculateMeleeDamage", self:GetOwner(), self.Primary.Damage, ent)
			hook.Run("LongswordHitEntity", self:GetOwner(), ent)
			local dmg = DamageInfo()
			dmg:SetAttacker(self:GetOwner())
			dmg:SetInflictor(self)
			dmg:SetDamage(newdmg or self.Primary.Damage)
			dmg:SetDamageType(DMG_CLUB)
			dmg:SetDamagePosition(tr.HitPos)
			if ent:GetClass() ~= "prop_ragdoll" then
				dmg:SetDamageForce(self:GetOwner():GetAimVector() * 10000)
			end

			ent:DispatchTraceAttack(dmg, trace.start, trace.endpos)
			if SERVER and ent:IsPlayer() then
				if self.Primary.FlashTime then
					ent:ScreenFade(SCREENFADE.IN, self.Primary.FlashColor or color_white, self.Primary.FlashTime, 0)
					ent.StunTime = CurTime() + self.Primary.FlashTime
					ent.StunStartTime = CurTime()
				elseif self.Primary.StunTime then
					ent.StunTime = CurTime() + self.Primary.StunTime
					ent.StunStartTime = CurTime()
				end
			end

			if tr.MatType == MAT_FLESH then
				ent:EmitSound("Flesh.ImpactHard")
				local effect = EffectData()
				effect:SetStart(tr.HitPos)
				effect:SetNormal(tr.HitNormal)
				effect:SetOrigin(tr.HitPos)
				util.Effect("BloodImpact", effect, true, true)
			elseif tr.MatType == MAT_WOOD then
				ent:EmitSound("Wood.ImpactHard")
			elseif tr.MatType == MAT_CONCRETE then
				ent:EmitSound("Concrete.ImpactHard")
			elseif self.Primary.ImpactSoundWorldOnly then
				self:GetOwner():EmitSound(self.Primary.ImpactSound)
			end
		elseif self.MeleeHitFallback and self.MeleeHitFallback(self, tr) then
			return
		elseif self.Primary.ImpactSoundWorldOnly then
			self:GetOwner():EmitSound(self.Primary.ImpactSound)
		end
	elseif SERVER then
		self:PlayAnim(ACT_VM_MISSCENTER)
	end
end