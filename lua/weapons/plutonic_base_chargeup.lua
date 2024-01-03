--[[************************************************************************]]
--[[	plutonic_base_chargeup.lua											  ]]
--[[************************************************************************]]
--[[                      This file is a part of PLUTONIC                   ]]
--[[                              (c) 2022-2023                             ]]
--[[                  Written by Sophie (github.com/sophfee)                ]]
--[[************************************************************************]]
--[[ Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)         ]]
--[[ Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)        ]]
--[[                                                                        ]]
--[[ Permission is hereby granted, free of charge, to any person obtaining  ]]
--[[ a copy of this software and associated documentation files (the        ]]
--[[ "Software"), to deal in the Software without restriction, including    ]]
--[[ without limitation the rights to use, copy, modify, merge, publish,    ]]
--[[ distribute, sublicense, and/or sell copies of the Software, and to     ]]
--[[ permit persons to whom the Software is furnished to do so, subject to  ]]
--[[ the following conditions:                                              ]]
--[[                                                                        ]]
--[[ The above copyright notice and this permission notice shall be         ]]
--[[ included in all copies or substantial portions of the Software.        ]]
--[[                                                                        ]]
--[[ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        ]]
--[[ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     ]]
--[[ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. ]]
--[[ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   ]]
--[[ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   ]]
--[[ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      ]]
--[[ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 ]]
--[[************************************************************************]]
AddCSLuaFile();
SWEP.Base = "plutonic_base";
SWEP.Charged = false;
function SWEP:CanShoot()
	return self:CanPrimaryAttack() and not self:GetBursting() and not self.LoweredPos and self:IsSprinting() and self:GetReloadTime() < CurTime() and self.Charged;
end

function SWEP:PrimaryAttack()
	if not self:CanShoot() then return; end
	local clip = self:Clip1();
	if self.Primary.Burst and clip >= 3 then
		self:SetBursting(true);
		self.Burst = 3;
		local delay = CurTime() + self.Primary.Delay * 3 + (self.Primary.BurstEndDelay or 0.3);
		self:SetNextPrimaryFire(delay);
		self:SetReloadTime(delay);
	elseif clip >= 1 then
		self:TakePrimaryAmmo(1);
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self:CalculateSpread());
		self:AddRecoil();
		self:ViewPunch();
		if self.Primary.Sound_World then
			if CLIENT then
				local owner = self:GetOwner();
				if owner == LocalPlayer() then
					local shouldPlay = impulse and impulse.GetSetting("view_thirdperson", false);
					if shouldPlay == false then
						self:EmitSound(self.Primary.Sound, nil, nil, nil, CHAN_STATIC, SND_NOFLAGS, 0);
					end
				end
			end

			if SERVER then
				self:EmitWorldSound(self.Primary.Sound_World);
			end
		else
			self:EmitSound(self.Primary.Sound, nil, nil, nil, CHAN_WEAPON, nil, 1);
		end

		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
		self:SetReloadTime(CurTime() + self.Primary.Delay);
	else
		self:EmitSound(self.EmptySound);
		self:Reload();
		self:SetNextPrimaryFire(CurTime() + 1);
	end
end

SWEP.IsChargeUp = true;
SWEP.ChargingShot = false;
SWEP.Primary.ChargeTime = 1;
SWEP.Primary.ChargeNoReturnTime = 0.95;
SWEP.Charge = 0;
function SWEP:OnChargeStateChanged(state)
end

hook.Add(
	"StartCommand",
	"Plutonic_StartCommand",
	function(ply, cmd)
		if not IsValid(ply) or not ply:Alive() then return; end
		local wep = ply:GetActiveWeapon();
		if not IsValid(wep) or not wep.IsPlutonic then return; end
		if wep.IsChargeUp then
			if cmd:KeyDown(IN_SPEED) then
				if (wep.Charge or 0) >= wep.Primary.ChargeNoReturnTime then
					-- no run & gun
					if wep.LoweredPos then
						cmd:RemoveKey(IN_SPEED);
					end

					cmd:AddKey(IN_ATTACK);
					--cmd:AD
				else
					wep.ChargeTime = 0;
					wep.ChargingShot = false;
				end

				return;
			end

			local charging = wep.ChargingShot;
			local chargeAlpha = charging and math.Clamp((CurTime() - wep.ChargeTime) / wep.Primary.ChargeTime, 0, 1) or 0;
			if wep.ChargingShot and (chargeAlpha or 0) >= wep.Primary.ChargeNoReturnTime and cmd:KeyDown(IN_ATTACK) and cmd:KeyDown(IN_ATTACK2) then
				if wep:CanPrimaryAttack() then
					cmd:AddKey(IN_ATTACK);
					wep:PrimaryAttack();
				end
			end

			if (cmd:KeyDown(IN_ATTACK2) or cmd:KeyDown(IN_ATTACK)) and not wep.ChargingShot then
				wep.ChargeTime = CurTime();
				wep.ChargingShot = true;
				wep:OnChargeStateChanged(true);
				if not wep.Primary.Automatic then
					cmd:RemoveKey(IN_ATTACK2);
				end
			elseif not (cmd:KeyDown(IN_ATTACK2) or cmd:KeyDown(IN_ATTACK)) and wep.ChargingShot then
				wep.ChargeTime = nil;
				wep.ChargingShot = false;
				wep:OnChargeStateChanged(false);
			end
		end
	end
);

function SWEP:ChargeThink()
	if not self.IsChargeUp then return; end
	if self.ChargingShot then
		local charge = math.Clamp((CurTime() - self.ChargeTime) / self.Primary.ChargeTime, 0, 1);
		self.Charged = charge >= 1;
		self.Charge = charge;
	end
end

function SWEP:Think()
	if CLIENT then
		self:ViewmodelThink();
	end

	self:ChargeThink();
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

	if not CLIENT then return; end
end

print("loaded!");