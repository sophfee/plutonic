/**************************************************************************/
/*	shared/think.lua											      	  */
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

function SWEP:IdleThink()
	if self:GetNextIdle() == 0 then return; end
	if CurTime() > self:GetNextIdle() then
		self:SetNextIdle(0);
		if self.IdleSequence then
			local vm = self:GetOwner():GetViewModel();
			local transition = vm:FindTransitionSequence(vm:GetSequence(), vm:LookupSequence(self.IdleSequence));
			if transition ~= -1 then
				vm:SetSequence(transition);
			else
				vm:SetSequence(self.IdleSequence);
			end
		else
			self:PlayAnim(self:Clip1() > 0 and ACT_VM_IDLE or ACT_VM_IDLE_EMPTY);
		end
	end
end

function SWEP:SprintChanged(is_sprinting)

	self.__cpyHoldType = self.__cpyHoldType or self.HoldType;

	if is_sprinting then
		self:SetHoldType("passive");
	else
		self:SetHoldType(self.__cpyHoldType);
	end

	if not self.UseSprintSequence then return; end
	local vm = self:GetOwner():GetViewModel();
	if is_sprinting then
		local transition = vm:FindTransitionSequence(vm:GetSequence(), vm:LookupSequence(self.SprintSequence));
		--print(transition, vm:GetSequence(), vm:LookupSequence(self.SprintSequence));
		if transition ~= -1 then
			self:PlaySequence(transition);
		else
			self:PlaySequence(self.SprintSequence);
		end
	else
		self:PlayAnim(ACT_VM_IDLE);
	end
end

SWEP.__sprinting = false;
function SWEP:SprintThink()
	local sprinting = self:IsSprinting();
	if sprinting ~= self.__sprinting then
		self:SprintChanged(sprinting);
		self.__sprinting = sprinting;
	end
end

function SWEP:Think()
	self.EquippedAttachments = self.EquippedAttachments or {};
	self.AttachmentEntCache = self.AttachmentEntCache or {};
	if Plutonic.IsClient then
		self:ViewmodelThink();
		//self.ViewModelFOV = LocalPlayer():GetFOV();
	end

	if SERVER then
		self:HolsterThink();
		self:SprintThink();
	end

	self:IronsightsThink();
	self:RecoilThink();
	self:IdleThink();
	if self.CustomThink then
		self.CustomThink(self);
	end

	if self:GetBursting() then
		self:BurstThink();
	end

	if self:GetReloading() then
		self:ReloadThink();
	end

	if not Plutonic.IsClient then return; end
end

function SWEP:RecoilThink()
	self:SetRecoil(math.Clamp(self:GetRecoil() - FrameTime() * (self.Primary.RecoilRecoveryRate or 1.4), 0, self.Primary.MaxRecoil or 1));
end

function SWEP:BurstThink()
	if self.Burst and (self.nextBurst or 0) < CurTime() then
		self:TakePrimaryAmmo(1);
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self:CalculateSpread());
		self:AddRecoil();
		self:ViewPunch();
		self:EmitSound(self.Primary.Sound);
		self.Burst = self.Burst - 1;
		if self.Burst < 1 then
			self:SetBursting(false);
			self.Burst = nil;
		else
			self.nextBurst = CurTime() + self.Primary.Delay;
		end
	end
end

-- ADS noises
sound.Add(
	{
		name = "Plutonic.ADS.In",
		sound = {"weapons/ins2/uni/uni_ads_in_01.wav", "weapons/ins2/uni/uni_ads_in_02.wav", "weapons/ins2/uni/uni_ads_in_03.wav", "weapons/ins2/uni/uni_ads_in_04.wav", "weapons/ins2/uni/uni_ads_in_05.wav", "weapons/ins2/uni/uni_ads_in_06.wav"},
		level = 60,
		channel = CHAN_AUTO,
		pitch = {95, 105}
	}
);

sound.Add(
	{
		name = "Plutonic.ADS.Out",
		sound = {"weapons/ins2/uni/uni_ads_out_01.wav"},
		level = 60,
		channel = CHAN_AUTO,
		pitch = {95, 105}
	}
);

function SWEP:IronsightsThink()
	if (self.CanDecreaseBlowback or 0) < CurTime() then
		self:SetIronsightsRecoil(math.Clamp(self:GetIronsightsRecoil() - (FrameTime() * 600), 0, 1));
	end

	if not self:CanIronsight() then
		self:SetIronsights(false);

		return;
	end

	if self:GetOwner():KeyDown(IN_ATTACK2) and not self:GetIronsights() then
		self:SetIronsights(true);
		self:EmitSound("Plutonic.ADS.In");
		--self:SetHoldType( IronsightsIO[self.HoldType] or "ar2" )
		if CLIENT then
			self.VMIronsights = math.ease.InSine(self.VMIronsights or 0);
		end
	elseif not self:GetOwner():KeyDown(IN_ATTACK2) and self:GetIronsights() then
		self:SetIronsights(false);
		self:EmitSound("Plutonic.ADS.Out");
		--self:SetHoldType( self.HoldType )
		if CLIENT then
			self.VMIronsights = math.ease.OutExpo(self.VMIronsights or 0);
		end
	end
end

function SWEP:ReloadThink()
	if self:GetReloadTime() < CurTime() then
		self:FinishReload();
	end
end