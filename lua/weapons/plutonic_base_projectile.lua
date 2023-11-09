/**************************************************************************/
/*	plutonic_base_projectile.lua											      		  */
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
SWEP.Projectile = {}
SWEP.IsChargeUp = true
SWEP.ChargingShot = false
SWEP.Primary.ChargeTime = 0
SWEP.PlayedAnimCharge = false;
SWEP.Primary.ChargeNoReturnTime = 0.95;
SWEP.Primary.EmptySound = ""

function SWEP:CanShoot()
	return self:CanPrimaryAttack() and 
	not self:GetBursting() and 
	not (self.LoweredPos and self:IsSprinting()) and 
	self:GetReloadTime() < CurTime() and 
	self.Charged
end

function SWEP:ChargeThink()
	if not self.IsChargeUp then return end

	if self.ChargingShot then
		local charge = math.Clamp((CurTime() - self.ChargeTime) / self.Primary.ChargeTime, 0, 1)
		self.Charged = charge >= 1
		self.Charge = charge
    end
end

function SWEP:OnStartCharging()
    local vm = self.Owner:GetViewModel();
    if not IsValid(vm) or not self.Primary.ChargeAnimation then return end

    local chargeAnim = self.Primary.ChargeAnimation;
    local abortAnim = self.Primary.AbortAnimation;

    if isstring(self.Primary.ChargeAnimation) then
        local seqidCharge = vm:LookupSequence(chargeAnim);
        local seqidAbort = vm:LookupSequence(abortAnim)

        if vm:GetSequence() == seqidAbort then
            local cycle = vm:GetCycle();
            vm:SetSequence(seqidCharge);
            vm:SetCycle(1 - cycle);
        else
            vm:SetSequence(seqidCharge);
        end
    end
end

function SWEP:OnAbortCharging()
    local vm = self.Owner:GetViewModel();
    if not IsValid(vm) or not self.Primary.ChargeAnimation then return end

    local chargeAnim = self.Primary.ChargeAnimation;
    local abortAnim = self.Primary.AbortAnimation;

    if isstring(self.Primary.ChargeAnimation) then
        local seqidCharge = vm:LookupSequence(chargeAnim);
        local seqidAbort = vm:LookupSequence(abortAnim)

        if vm:GetSequence() == seqidCharge then
            local cycle = vm:GetCycle();
            vm:SetSequence(seqidAbort);
            vm:SetCycle(1 - cycle);
        else
            vm:SetSequence(seqidAbort);
        end
    end
end

function SWEP:OnChargeStateChanged(state)
    if state then
        self:OnStartCharging();
    else
        self:OnAbortCharging();
    end;
end;

function SWEP:PrimaryAttack()
    if not self:CanShoot() then return end
	if self:Clip1() < 1 then
		self:SetNextPrimaryFire(CurTime() + 1)

		return
	end

	if self.Primary.ThrowDelay then
        self:PlayAnim(self.Primary.ThrowAnimation or ACT_VM_THROW)
		timer.Simple(
			self.Primary.ThrowDelay,
			function()
				if IsValid(self) and self:CanShoot() then
					self:ThrowAttack()
					self:ViewPunch()
					if self:Clip1() < 1 then
						local time_left = self:SequenceDuration() * (1 - self:GetCycle())
						timer.Simple(time_left, function()
							if IsValid(self) and IsValid(self:GetOwner()) then
								self:GetOwner():StripWeapon(self:GetClass())		
							end
						end)
					end
				end
			end
		)
	else
		self:ThrowAttack()
		self:ViewPunch()
	end

	if self.Primary.Sound ~= "" then
		self:EmitSound(self.Primary.Sound)
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self.DoFireAnim then
		self:PlayAnim(ACT_VM_PRIMARYATTACK)
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	else
		self:SendWeaponAnim(ACT_VM_THROW)
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		self:SendWeaponAnim(ACT_VM_DRAW)
	end

	if self:Clip1() < 1 then
		if self.PairedItem then
			if self:GetOwner():HasInventoryItemSpecific(self.PairedItem) then
				self:GetOwner():TakeInventoryItem(self.PairedItem)
			end
		else
			local time_left = self:SequenceDuration() * (1 - self:GetCycle())
			timer.Simple(time_left, function()
				if IsValid(self) and IsValid(self:GetOwner()) then
					self:GetOwner():StripWeapon(self:GetClass())		
				end
			end)
			--self:GetOwner():StripWeapon(self:GetClass())
		end
	end
end

function SWEP:Think()
	if CLIENT then
		self:ViewmodelThink()
	end

	self:IdleThink()
    self:ChargeThink()
end

function SWEP:Reload()
	return
end

function SWEP:ThrowAttack()
	if CLIENT then return end
	self:TakePrimaryAmmo(1)
	local projectile = ents.Create("plutonic_projectile")
	projectile:SetModel(self.Projectile.Model)
	projectile.Owner = self:GetOwner()
	local pos = self:GetOwner():GetShootPos()
	pos = pos + self:GetOwner():GetForward() * 2
	pos = pos + self:GetOwner():GetRight() * 3
	pos = pos + self:GetOwner():GetUp() * -3
	projectile:SetPos(pos)
	if self.Projectile.Timer then
		projectile.Timer = CurTime() + self.Projectile.Timer
	end

	if self.Projectile.Touch then
		projectile.ProjTouch = self.Projectile.Touch
	end

	if self.ProjectileFire then
		projectile.OnFire = self.ProjectileFire
	end

	if self.ProjectileThink then
		projectile.ProjThink = self.ProjectileThink
	end

	if self.ProjectileRemove then
		projectile.ProjRemove = self.ProjectileRemove
	end

	if self.Projectile.FireSound then
		projectile.FireSound = self.Projectile.FireSound
	end

	if self.Projectile.HitSound then
		projectile.HitSound = self.Projectile.HitSound
	end

	if self.Projectile.RemoveWait then
		projectile.RemoveWait = self.Projectile.RemoveWait
	end

	projectile:SetOwner(self:GetOwner())
	projectile:Spawn()
	local force = 700
	if self:GetOwner():KeyDown(IN_FORWARD) then
		force = 1000
	elseif self:GetOwner():KeyDown(IN_BACK) then
		force = 600
	end

	if self.Projectile.ForceMod then
		force = force * self.Projectile.ForceMod
	end

	local phys = projectile:GetPhysicsObject()
	if not IsValid(phys) then return end
	if self.Projectile.Mass then
		phys:SetMass(self.Projectile.Mass)
	end

	phys:ApplyForceCenter(self:GetOwner():GetAimVector() * force * 2 + Vector(0, 0, 0))
	phys:AddAngleVelocity(Vector(math.Rand(-500, 500), math.Rand(-500, 500), math.Rand(-500, 500)))
end