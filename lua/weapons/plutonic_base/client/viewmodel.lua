--[[************************************************************************]]
--[[  viewmodel.lua                                                         ]]
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
SWEP.CustomEvents = SWEP.CustomEvents or {};
SWEP.ViewModelPos = Vector(0, 0, 0);
SWEP.ViewModelAngle = Angle(0, 0, 0);
SWEP.BarrelLength = 6;
SWEP.VMDeltaX = 0;
SWEP.VMDeltaY = 0;
SWEP.VMRoll = 0;
SWEP.VMRecoilPos = Vector(0, 0, 0);
SWEP.VMRecoilAng = Angle(0, 0, 0);
SWEP.VMOffsetPos = Vector(0, 0, 0);
SWEP.VMOffsetAng = Angle(0, 0, 0);
SWEP.Primary.FirePower = 1;
SWEP.c_alpha = 0;
SWEP.c_lang = Angle(0, 0, 0);
SWEP.c_lpos = Vector(0, 0, 0);
SWEP.c_oxc = 0;
SWEP.c_oxq = 0;
SWEP.c_oyq = 0;
local math = math;
local render = render;
local reticule = Material("models/weapons/insurgency_sandstorm/ins2_sandstorm/kobra_reticle");
local abs = math.abs;
local min = math.min;
local max = math.max;
local clamp = math.Clamp;
local sin = math.sin;
local cos = math.cos;
local deg = math.deg;
local Curtime = CurTime;
local Frametime = FrameTime;
local Realtime = CurTime;
local vec = Vector;
local lerp = Lerp;
local lerpAngle = LerpAngle;
local lerpVector = LerpVector;
local approach = math.Approach;
local easeOutQuad = Plutonic.Ease.OutQuad;
local easeOutCirc = Plutonic.Ease.OutCirc;
local easeInQuad = Plutonic.Ease.InQuad;
local easeInCirc = Plutonic.Ease.InSine;
local easeInBack = Plutonic.Ease.InBack;
local easeOutBack = Plutonic.Ease.OutBack;
local VECTOR_ZERO = vec(0, 0, 0);
local ANGLE_ZERO = Angle(0, 0, 0);
function SWEP:PreDrawViewModel(vm)
	if self.CustomMaterial and not self.CustomMatSetup then
		self:GetOwner():GetViewModel():SetMaterial(self.CustomMaterial);
		self.CustomMatSetup = true;
	end

	if Plutonic.Framework.Overdraw then return; end
	local drawnNames = {};
	self.EquippedAttachments = self.EquippedAttachments or {};
	self.AttachmentEntCache = self.AttachmentEntCache or {};
	for attName, _ in pairs(self.EquippedAttachments) do
		local attData = self.Attachments[attName];
		if not attData then continue; end
		local c = attData.Cosmetic;
		local att = self.AttachmentEntCache[attName];
		if not IsValid(att) then
			if Plutonic.Behaviors[attData.Behavior] and Plutonic.Behaviors[attData.Behavior].onCreate then
				att = Plutonic.Behaviors[attData.Behavior].onCreate(self, vm, attData);
				self.AttachmentEntCache[attName] = att;
			else
				att = ClientsideModel(c.Model, RENDERGROUP_VIEWMODEL);
				if c.ParentToAttachment then
					local attTo = self.AttachmentEntCache[c.ParentToAttachment];
					if not IsValid(attTo) then continue; end
					att:SetParent(attTo);
				else
					att:SetParent(vm);
				end
				att:SetNoDraw(true);
				att:AddEffects(EF_BONEMERGE);
				if c.Scale then
					if c.BoneScale then
						att:ManipulateBoneScale(0, Vector(c.Scale, c.Scale, c.Scale));
					else
						att:SetModelScale(c.Scale);
					end
				end

				self.AttachmentEntCache[attName] = att;
			end
		end

		local bone = vm:LookupBone(c.Bone);
		if not bone then continue; end
		local m = vm:GetBoneMatrix(bone);
		if not m then continue; end
		local pos = m:GetTranslation();
		local ang = m:GetAngles();
		pos = pos + ang:Forward() * c.Pos.x;
		pos = pos + ang:Right() * c.Pos.y;
		pos = pos + ang:Up() * c.Pos.z;
		att:SetPos(pos);
		ang:RotateAroundAxis(ang:Up(), c.Ang.y);
		ang:RotateAroundAxis(ang:Right(), c.Ang.p);
		ang:RotateAroundAxis(ang:Forward(), c.Ang.r);
		att:SetAngles(ang);
		if attData.RenderOverride then
			attData.RenderOverride(self, vm, att);
		end
		drawnNames[attName] = true;
		if Plutonic.Behaviors[attData.Behavior] and Plutonic.Behaviors[attData.Behavior].onFrame then Plutonic.Behaviors[attData.Behavior].onFrame(self, vm, attData, att); end
	end

	for name, csEnt in pairs(self.AttachmentEntCache) do
		if not drawnNames[name] then
			csEnt:Remove();
		end
	end
end

function SWEP:InitRT()
	self.ScopeTex = Material("ph_scope/ph_scope_lens3");
	self.ScopeRenderTarget = GetRenderTarget("plutonic_scope_rt", 512, 512, true);
	self.ScopeRenderMaterial = CreateMaterial(
		"plutonic_scope_hd",
		"UnlitGeneric",
		{
			["$model"] = 1,
			["$basetexture"] = self.ScopeRenderTarget:GetName(),
			["$phong"] = 1,
			["$phongexponent"] = 128,
			["$rimlight"] = 1,
			["$rimlightexponent"] = 32,
			["$rimlightboost"] = 128
		}
	);

	local material = Material("!plutonic_scope_hd");
	material:SetTexture("$basetexture", self.ScopeRenderTarget);
	material:SetInt("$phong", 1);
	material:SetFloat("$phongexponent", 128);
	material:SetFloat("$pp_colour_addr", 0);
	material:SetFloat("$pp_colour_addg", 0);
	material:SetFloat("$pp_colour_addb", 0);
	material:SetFloat("$pp_colour_mulr", 0);
	material:SetFloat("$pp_colour_mulg", 0);
	material:SetFloat("$pp_colour_mulb", 0);
	material:SetFloat("$pp_colour_brightness", 0);
	material:SetInt("$rimlight", 1);
	material:SetFloat("$rimlightexponent", 20);
	material:SetFloat("$rimlightboost", 100);
	material:SetFloat("$selfillum", 0);
	material:Recompute();
end

function SWEP:ViewModelDrawn(flags)
	self.Owner:GetHands():Draw();
	if Plutonic.Framework.Overdraw then return; end
	local vm = self:GetOwner():GetViewModel();
	if not IsValid(vm) then return; end
	if self.ExtraViewModelRender then
		self:ExtraViewModelRender(vm);
	end

	local drawnNames = {};
	self.EquippedAttachments = self.EquippedAttachments or {};
	self.AttachmentEntCache = self.AttachmentEntCache or {};
	for attName, _ in pairs(self.EquippedAttachments) do
		local attData = self.Attachments[attName];
		if not attData then continue; end
		local c = attData.Cosmetic;
		local att = self.AttachmentEntCache[attName];
		if not IsValid(att) then
			att = ClientsideModel(c.Model, RENDERGROUP_VIEWMODEL);
			att:SetParent(vm);
			att:SetNoDraw(true);
			att:AddEffects(EF_BONEMERGE);
			if c.Scale then
				if c.BoneScale then
					att:ManipulateBoneScale(0, Vector(c.Scale, c.Scale, c.Scale));
				else
					att:SetModelScale(c.Scale);
				end
			end

			self.AttachmentEntCache[attName] = att;
		end

		local bone = vm:LookupBone(c.Bone);
		if not bone then continue; end
		local m = vm:GetBoneMatrix(bone);
		if not m then continue; end
		local pos = m:GetTranslation();
		local ang = m:GetAngles();
		pos = pos + ang:Forward() * c.Pos.x;
		pos = pos + ang:Right() * c.Pos.y;
		pos = pos + ang:Up() * c.Pos.z;
		att:SetPos(pos);
		ang:RotateAroundAxis(ang:Up(), c.Ang.y);
		ang:RotateAroundAxis(ang:Right(), c.Ang.p);
		ang:RotateAroundAxis(ang:Forward(), c.Ang.r);
		att:SetAngles(ang);
		if attData.RenderOverride then
			attData.RenderOverride(self, vm, att);
		else
			att:DrawModel();
		end

		drawnNames[attName] = true;
		if Plutonic.Behaviors[attData.Behavior] and Plutonic.Behaviors[attData.Behavior].onFrame then
			Plutonic.Behaviors[attData.Behavior].onFrame(self, vm, attData, att);
		end
	end

	for name, csEnt in pairs(self.AttachmentEntCache) do
		if not drawnNames[name] then
			csEnt:Remove();
		end
	end
end

concommand.Add(
	"plutonic_client_debug_attachments",
	function()
		local lp = LocalPlayer();
		local wep = lp:GetActiveWeapon();
		print("Dumping Weapon.Attachments:");
		PrintTable(wep.Attachments);
		print("\nDumping Weapon.AttachmentEntCache:");
		PrintTable(wep.AttachmentEntCache);
		print("\nDumping Weapon.EquippedAttachments:");
		PrintTable(wep.EquippedAttachments);
	end
);

function SWEP:OnSprintStateChanged(sprinting)
	self.VMSprint = not sprinting and Plutonic.Ease.OutQuad(self.VMSprint or 0) or Plutonic.Ease.InQuad(self.VMSprint or 0);
end
local smoothdamp = function(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
	smoothTime = max(0.0001, smoothTime);
	local num = 2 / smoothTime;
	local num2 = num * deltaTime;
	local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2);
	local num4 = current - target;
	local num5 = target;
	local num6 = maxSpeed * smoothTime;
	num4 = clamp(num4, -num6, num6);
	target = current - num4;
	local num7 = (currentVelocity + num * num4) * deltaTime;
	currentVelocity = (currentVelocity - num * num7) * num3;
	local num8 = target + (num4 + num7) * num3;
	if (num5 - current > 0) == (num8 > num5) then
		num8 = num5;
		currentVelocity = (num8 - num5) / deltaTime;
	end

	return num8, currentVelocity;
end;

local smoothdampvec = function(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
	if isvector(currentVelocity) then
		local x = smoothdamp(current.x, target.x, currentVelocity.x, smoothTime, maxSpeed, deltaTime);
		local y = smoothdamp(current.y, target.y, currentVelocity.y, smoothTime, maxSpeed, deltaTime);
		local z = smoothdamp(current.z, target.z, currentVelocity.z, smoothTime, maxSpeed, deltaTime);
		return vec(x, y, z);
	else
		local x = smoothdamp(current.x, target.x, currentVelocity, smoothTime, maxSpeed, deltaTime);
		local y = smoothdamp(current.y, target.y, currentVelocity, smoothTime, maxSpeed, deltaTime);
		local z = smoothdamp(current.z, target.z, currentVelocity, smoothTime, maxSpeed, deltaTime);
		return vec(x, y, z);
	end
end;

function SWEP:PostRender()
	self:DoWallLeanThink();
	local dx = self.VMDeltaX or 0;
	local dy = self.VMDeltaY or 0;
	local oxc_a = min(abs(dx) / 8, 1);
	local oxc = easeOutQuad(oxc_a) * clamp(dx / -4, -.5, .5);
	self.c_oxc = lerp(Frametime() * 8, self.c_oxc or 0, oxc);
	local oxq_a = min(abs(dx) / 16, 1);
	local oxq = easeOutCirc(1 - oxq_a) * clamp(dx / 16, -.5, .5); -- Plutonic.Ease.OutQuad(min(abs(self.VMDeltaX) / 8, 1)) * clamp(self.VMDeltaX, -8, 8)
	self.c_oxq = lerp(Frametime() * 12, self.c_oxq or 0, oxq);
	local oyq_a = min(abs(dy) / 1, 1);
	local oyq = math.ease.OutCubic(oyq_a) * clamp(dy, -8, 8);
	self.c_oyq = lerp(Frametime() * 17, self.c_oyq or 0, oyq);
	self.Ironsights = self:GetIronsights();
	self._sprinting = self._sprinting or false;
	local sprinting = self:IsSprinting();
	if sprinting ~= self._sprinting then
		self._sprinting = sprinting;
		if self.OnSprintStateChanged then
			self:OnSprintStateChanged(sprinting);
		end
	end

	self.VMSprint = lerp(Frametime() * 2, self.VMSprint or 0, sprinting and 1 or 0);
	self.VMIronsights = approach(self.VMIronsights or 0, self:GetIronsights() and 1 or 0, FrameTime() * 1.7);
	local tr = util.TraceLine(
		{
			start = self:GetOwner():GetShootPos(),
			endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 32,
			filter = self:GetOwner()
		}
	);

	self.VMBlocked = self.VMBlocked or 0;
	self.VMBlocked = lerp(Frametime() * 13, self.VMBlocked, tr.Hit and tr.Fraction or 1);
	local isIronsights = self:GetIronsights();
	local isDuck = (self:GetOwner():KeyDown(IN_DUCK) or self:GetOwner():Crouching()) and not isIronsights;
	self.VMCrouch = approach(self.VMCrouch, isDuck and 1 or 0, Frametime() * 2.5);
	self.VMBobCycle = lerp(Frametime() * 6, self.VMBobCycle or 0, Plutonic.Framework.IsMoving() and 1 or 0);
	local l = self:IsSprinting() and 1 or 0;
	lerpSpeed = lerp(Frametime() * 5, lerpSpeed, l);
	local onvel = self:GetOwner():GetVelocity();
	local uvel = onvel.z;
	local vel = clamp(uvel / 80, -34, 34);
	self.VMVel = self.VMVel or 0;
	self.VMVel = Lerp(Frametime() * 5, self.VMVel, vel);
	local ft = Frametime();
	local ftM = self.SwaySpeed or 11;
	self.VMDeltaX = smoothdamp(self.VMDeltaX or 0, 0, 12, Frametime() * 2, 250, Frametime());
	self.VMDeltaY = smoothdamp(self.VMDeltaY or 0, 0, 12, Frametime() * 2, 250, Frametime());
	self.VMDeltaXWeighted = approach(self.VMDeltaXWeighted or 0, 0, ft * 32);
	self.VMDeltaYWeighted = approach(self.VMDeltaYWeighted or 0, 0, ft * 32);
	self.VMRecoilAmt = self.VMRecoilAmt or 0;
	self.VMRecoilAmt = lerp(ft * 2, self.VMRecoilAmt, 0);
	local alpha = isIronsights and Plutonic.Ease.OutExpo(self.VMIronsights) or Plutonic.Ease.InSine(self.VMIronsights);
	self.c_alpha = lerp(FrameTime() * 8, self.c_alpha or 0, alpha);
	if self.LoweredPos then
		local t = self:IsSprinting() and Plutonic.Ease.OutQuad(self.VMSprint or 0) or Plutonic.Ease.InQuad(self.VMSprint or 0);
		local loweredPos = Plutonic.Interpolation.VectorBezierCurve(t, VECTOR_ZERO, self.LoweredMidPos, self.LoweredPos);
		local loweredAng = Plutonic.Interpolation.AngleBezierCurve(t, ANGLE_ZERO, self.LoweredMidAng, self.LoweredAng);
		self.c_lpos = lerpVector(Frametime() * 4, self.c_lpos or VECTOR_ZERO, loweredPos);
		self.c_lang = lerpAngle(Frametime() * 9, self.c_lang or ANGLE_ZERO, loweredAng);
	end

	self.VMRecoilPos = lerpVector(ft * 9.8, self.VMRecoilPos, VECTOR_ZERO);
	self.VMRecoilAng = lerpAngle(ft * 9.8, self.VMRecoilAng, ANGLE_ZERO);

	Plutonic.ViewPunch.Pos = lerpVector(ft * 3.75, Plutonic.ViewPunch.Pos, VECTOR_ZERO);
	Plutonic.ViewPunch.Ang = lerpAngle(ft * 3.75, Plutonic.ViewPunch.Ang, ANGLE_ZERO);

	self.ViewPunchPlutonicP = lerpVector(ft * 16.8, self.ViewPunchPlutonicP or VECTOR_ZERO, Plutonic.ViewPunch.Pos or VECTOR_ZERO);
	self.ViewPunchPlutonicA = lerpAngle(ft * 16.8, self.ViewPunchPlutonicA or ANGLE_ZERO, Plutonic.ViewPunch.Ang or ANGLE_ZERO);


end

Plutonic.Hooks.Add(
	"PostRender",
	function()
		local me = LocalPlayer();
		if not IsValid(me) then return; end
		local wep = me:GetActiveWeapon();
		if not IsValid(wep) then return; end
		if not wep.IsPlutonic then return; end
		wep:PostRender();
	end
);

function Plutonic.Framework.IsMoving()
	return LocalPlayer():GetVelocity():Length2DSqr() > 40 ^ 2;
end

function SWEP:IsMoving()
	return self:GetOwner():GetVelocity():Length2DSqr() > 40 ^ 2;
end

function SWEP:IsDucked()
	local isIronsights = self:GetIronsights();

	return (self:GetOwner():KeyDown(IN_DUCK) or self:GetOwner():Crouching()) and not isIronsights;
end

SWEP.CrouchPos = Vector(.7, -0, -.4);
SWEP.CrouchAng = Angle(0, 0, -0);
function SWEP:DoCrouch(pos, ang)
	self.VMCrouch = self.VMCrouch or 0;
	local alpha;
	if self:IsDucked() then
		alpha = Plutonic.Ease.OutQuad(self.VMCrouch);
	else
		alpha = Plutonic.Ease.InQuad(self.VMCrouch);
	end
	--pos = pos + ang:Right() * self.CrouchPos.x * alpha
	--pos = pos + ang:Forward() * self.CrouchPos.y * alpha
	--pos = pos + ang:Up() * self.CrouchPos.z * alpha
	--ang:RotateAroundAxis(ang:Right(), self.CrouchAng.p * alpha)
	--ang:RotateAroundAxis(ang:Forward(), self.CrouchAng.r * alpha)
	--ang:RotateAroundAxis(ang:Up(), self.CrouchAng.y * alpha)

	return Plutonic.Framework.RotateAroundPoint(pos, ang, Vector(-9, -2, -3), self.CrouchPos * -alpha, self.CrouchAng * -alpha);
end

function SWEP:DoBlocked(pos, ang)
	if self:GetOwner() ~= LocalPlayer() then return pos, ang; end
	self.VMBlocked = self.VMBlocked or 1;
	local bl = -(self.VMBlocked - 1);

	return Plutonic.Framework.RotateAroundPoint(pos, ang, self.PointOrigin or Vector(0, 0, 0), Vector(bl * -11, bl * -1, -bl * 7), Angle(bl * 23, bl * -12, bl * 12));
end

SWEP.IronsightsMiddlePos = Vector(-3, -2, -1.6);
SWEP.IronsightsMiddleAng = Angle(3, 9, 4);

function SWEP:DoIronsights(pos, ang)
	self.VMIronsights = self.VMIronsights or 0;
	self.VMRattle = self.VMRattle or 0;
	PLUTONIC_SEED8 = PLUTONIC_SEED8 or math.random(1000000, 9999999);
	PLUTONIC_SEED9 = PLUTONIC_SEED9 or math.random(1000000, 9999999);
	-- Idle
	if self:GetIronsights() then
		ang:RotateAroundAxis(VECTOR_RIGHT, cos(Curtime() * .5) * 0.05);
		ang:RotateAroundAxis(VECTOR_UP, sin(Curtime() * 1) * 0.05);
	end

	local tome = self.VMRecoilSeed or 0;
	tome = tome + CurTime();
	ang:RotateAroundAxis(ang:Forward(), sin((tome * 8) * ((1 / self.Primary.Delay) / 4)) * (self.VMRecoilAmt or 0) * 24);
	-- fire bump
	self.lastshot = self.lastshot or 0;
	local ls = self.lastshot;
	local timeSince = math.min((ls + 1) - Curtime(), 1);
	local fireBump = Plutonic.Ease.InElastic(math.Clamp(timeSince, 0, 1));
	pos = pos + ang:Forward() * fireBump * -.4;
	local alpha = self.c_alpha or 0;
	local ironsightPos = Plutonic.Interpolation.VectorBezierCurve(alpha, VECTOR_ZERO, self.IronsightsMiddlePos, self.IronsightsPos);
	local ironsightAng = Plutonic.Interpolation.AngleBezierCurve(alpha, ANGLE_ZERO, self.IronsightsMiddleAng, self.IronsightsAng);
	pos = pos + ang:Up() * ironsightPos.z * alpha;
	pos = pos + ang:Right() * ironsightPos.x * alpha;
	pos = pos + ang:Forward() * ironsightPos.y * alpha;
	ang:RotateAroundAxis(ang:Right(), ironsightAng.p * alpha);
	ang:RotateAroundAxis(ang:Up(), ironsightAng.y * alpha);
	ang:RotateAroundAxis(ang:Forward(), ironsightAng.r * alpha);

	return pos, ang;
end

function SWEP:DoIdle(pos, ang)
	self.VMIdle = self.VMIdle or 0;
	local rt = Realtime();
	local breath0 = sin(rt * .495) * cos(rt * 1.6) * 1.0;
	local breath1 = cos(rt * 1.625) * 9.6;
	local breath2 = sin(rt * .95) * cos(rt * .6) * -3.4;
	local corp = self.CenterOfRotationPos or VECTOR_ZERO;

	return Plutonic.Framework.RotateAroundPoint(pos, ang, corp, Vector(0, 0, 0), Angle(breath0, breaht1, breath2) * (.95 - self.VMIronsights));
end

SWEP.LoweredMidPos = Vector(4, -3, 0.4);
SWEP.LoweredMidAng = Angle(-6, 7, -5);
function SWEP:ShouldDoSprint()
	return self.VMSprint and math.Round(self.VMSprint, 4) > 0;
end

function SWEP:DoSprint(pos, ang)
	if self.CustomSprint then return self:CustomSprint(pos, ang); end
	if not self.LoweredPos then return pos, ang; end
	local loweredPos = self.c_lpos or self.LoweredPos;
	local loweredAng = self.c_lang or self.LoweredAng;
	ang:RotateAroundAxis(ang:Right(), loweredAng.p);
	ang:RotateAroundAxis(ang:Up(), loweredAng.y);
	ang:RotateAroundAxis(ang:Forward(), loweredAng.r);
	pos = pos + ang:Up() * loweredPos.z;
	pos = pos + ang:Right() * loweredPos.x;
	pos = pos + ang:Forward() * loweredPos.y;

	return pos, ang;
end

lerpSpeed = 0;
local WalkingTime = 0;
local stepLunge = 0;
local stepLungeNext = 0;
local _2PI = math.pi * 2;
local theta = 0
local zeta = 0
local smoothPos0 = Vector();
local smoothPos1 = Vector();
local fart = false
function SWEP:DoWalkBob(pos, ang)
	if self.DoCustomWalkBob then return self:DoCustomWalkBob(pos, ang); end
	local rt = Realtime();
	local corp = self.CenterOfRotationPos or VECTOR_ZERO;
	local cora = self.CenterOfRotationAng or ANGLE_ZERO;
	if self:GetOwner():GetVelocity():Length2DSqr() > 60 ^ 2 then
		WalkingTime = WalkingTime + FrameTime() * 2;
	end

	local mv = clamp(self:GetOwner():GetVelocity():Length2D() / 200, 0, 1);
	if self:GetIronsights() then
		mv = mv * 0.4;
	end

	local pos0, ang0 = pos + Vector(), ang + Angle();
	do
		local modif = 1;
		if self.UseSprintSequence then
			modif = 0.1;
		end

		if not self.LoweredPos then
			modif = 0.7;
		end

		local rate = 11.2;
		local sn0 = sin(Realtime() * rate) * mv;
		sn0 = math.ease.InCirc(math.ease.OutSine(abs(sn0))) * (sn0 > 0 and 1 or -1);
		

		local cs0 = cos(Realtime() * rate) * mv;
		local m = cs0 > 0 and 1 or -1;
		local sweep = math.ease.InQuint(abs(cs0 / 8)) * m * 8;
		local d = sin(Realtime() * rate * 2) * mv;
		theta = smoothdamp(theta, d, 4, Frametime() * 1.1, 18, Frametime());
		d = theta;
		local l = cos(Realtime() * rate * 2) * mv;
		zeta = smoothdamp(zeta, l, 4, Frametime() * 1.1, 19, Frametime());
		l = zeta;
		local _n2PI = _2PI - Frametime();

		local desmos = 0

		--chat.AddText(d, l, desmos)
		--local desmos = sin(abs(cos(Realtime() * rate * 4) ^ 2) * math.pi) * 4 * sin(Realtime() * rate * 2);
		m = d > 0 and 1 or -1;
		local sweeph = math.ease.InQuint(abs(d)) * 1 * m;
		pos0, ang0 = Plutonic.Framework.RotateAroundPoint(pos, ang, corp, 
		Vector(((abs(sweeph) * -.3) + max(0, cs0) + l * .3535 + (sweep * .00150)) / 4, (cs0 * -.55) + (sweep * .00152), -(1 - d) * .42068), 
		Angle((d * 1.1 + l) / 1.5, (cs0 * .4 - sweep * .28 + (sn0 * 1.29)) * 2, (d * .4 + l) * 0.20 - ((sweeph ^ 3) * .3) + deg(desmos)/8 ));
	end

	local pos1, ang1 = pos + Vector(), ang + Angle();
	do
		local rate = 11.2 / 1.25;
		local sn0 = sin(rt * rate);
		local cs0 = cos(rt * rate);
		local m = cs0 > 0 and 1 or -1;
		local sweep = easeInCirc(abs(cs0)) * -1 * m;
		local d = -sin(rt * rate * 2);
		local l = cos(rt * rate * 2);
		m = sn0 > 0 and 1 or -1;
		local sweeph = easeInCirc(abs(sn0)) * 1 * m;
		pos1, ang1 = Plutonic.Framework.RotateAroundPoint(pos, ang, corp, Vector(d * .1, (sn0 * -.2) - (sweep * .1), -(abs(cs0) * .175) - 0.2) * mv, Angle(d * -1.25 + (abs(sn0) * 1.8) + (abs(sweeph) * .5), sn0 * 1.75 + (sweep * .125), l * 1.25) * mv);
	end

	local interp = Plutonic.Ease.InOutQuart(self.VMSprint);

	if not fart then
		fart = true
		smoothPos0 = pos0
		smoothPos1 = pos1
	end
	pos, ang = lerpVector(interp, pos1, pos0), lerpAngle(interp, ang1, ang0);
	if not self:IsSprinting() then
		ang:RotateAroundAxis(ang:Forward(), cos(rt * 16.8) * mv * .1);
	end

	return pos, ang;
end

-- THINK FOR WALL LEANING OUT
function SWEP:DoWallLeanThink()
	-- how far to left
	local left = 0;
	-- how far to right
	local right = 0;
	-- trace to left
	local tr = util.TraceLine(
		{
			start = self:GetOwner():GetPos(),
			endpos = self:GetOwner():GetPos() + self:GetOwner():GetRight() * -32 + self:GetOwner():GetForward() * 12 + Vector(0, 0, 48),
			filter = self:GetOwner()
		}
	);

	-- if we hit something
	if tr.Hit then
		-- add to left
		left = left + 1;
	end

	-- trace to right
	tr = util.TraceLine(
		{
			start = self:GetOwner():EyePos(),
			endpos = self:GetOwner():EyePos() + self:GetOwner():GetRight() * 32 + self:GetOwner():GetForward() * 12 + Vector(0, 0, 48),
			filter = self:GetOwner()
		}
	);

	-- if we hit something
	if tr.Hit then
		-- add to right
		right = right + 1;
	end
	--self.VMWallLean = Lerp(FrameTime() * 6.4, self.VMWallLean or 0, left - right)
end

function SWEP:ViewmodelThink()
	local flip = Plutonic.Framework.GetControl_Bool("vm_flip_lefty", true);
	self.ViewModelFlip = flip;
end

function SWEP:GetViewModelPosition(pos, ang)
	if self.PreGetViewModelPosition then
		pos, ang = self:PreGetViewModelPosition(pos, ang);
	end

	self.swag_angle = self.swag_angle or 0;
	self.swag_angle = Lerp(Frametime() * 5, self.swag_angle, self:GetIronsights() and 0 or math.rad(LocalPlayer():GetBodyYawDifference() * math.pi * -2));
	--ang:RotateAroundAxis(ang:Up(), self.swag_angle * math.pi * self.ViewModelFOV / 100);
	--pos = pos + ang:Right() * (math.rad(self.swag_angle) * (math.pi * (self.ViewModelFOV / 100)));
	local ply = self:GetOwner();
	--pos, ang = pos, ang + ply.offset_ang
	self.centeredMode = self.centeredMode or GetConVar("plutonic_centered");
	if self.centeredMode and self.centeredMode:GetBool() then
		self.VMCenter = self.VMCenter or 0;
		if not self:GetIronsights() then
			self.VMCenter = Lerp(FrameTime() * 4, self.VMCenter, 1);
		else
			self.VMCenter = Lerp(FrameTime() * 4, self.VMCenter, 0);
		end

		local cpos, cang = self.CenteredPos * self.VMCenter, self.CenteredAng * self.VMCenter;
		pos = pos + (cpos.y * ang:Forward());
		pos = pos + (cpos.x * ang:Right());
		pos = pos + (cpos.z * ang:Up());
		ang:RotateAroundAxis(ang:Right(), cang.p);
		ang:RotateAroundAxis(ang:Up(), cang.y);
		ang:RotateAroundAxis(ang:Forward(), cang.r);
	end

	local ft = Frametime();
	local ovel = self:GetOwner():GetVelocity();
	local move = vec(ovel.x, ovel.y, 0);
	local movement = move:LengthSqr();
	local movepercent = clamp(movement / self:GetOwner():GetRunSpeed() ^ 2, 0, 1);
	local vel = move:GetNormalized();
	local rd = self:GetOwner():GetRight():Dot(vel);
	local isIronsights = self:GetIronsights();
	self.VMSwayIronTransform = self.VMSwayIronTransform or 0;
	self.VMSwayIronTransform = approach(self.VMSwayIronTransform, isIronsights and 1 or 0.1, ft * 2);
	local brl = self.BarrelLength * 1;
	--local xsa = 1 - clamp(abs(Curtime()-self.VMDeltaXT) * .7, 0, 1)
	local xva = self.VMDeltaX; --(Plutonic.Ease.InElastic(xsa)) * self.VMDeltaX
	--self.xsa = xsa
	--self.xva = xva
	pos, ang = self:DoIronsights(pos, ang);
	pos, ang = self:DoSprint(pos, ang);
	local swayXv = xva * .5;
	local swayXa = -xva * 1;
	if isIronsights then
		rd = rd / 2;
	end

	self.VMRoll = lerp(ft * 3, self.VMRoll, rd * movepercent);
	self.VMSideStepYaw = lerp(ft * (abs(rd) * movepercent > 0.02 and .153 or 3), self.VMSideStepYaw or 0, rd * movepercent);
	local degRoll = deg(self.VMRoll) / 3;
	degRoll = degRoll + ((self.VMWallLean or 0) * 10.4);
	local degYaw = deg(self.VMSideStepYaw) / 3;
	local degPitch = lerp(Plutonic.Ease.OutQuint(min(abs(degRoll / 8), 1)), 0, cos(math.rad(degRoll * 2)));
	local flip = Plutonic.Framework.GetControl_Bool("vm_flip_lefty", false);
	if flip then
		swayXv = swayXv * -1;
		swayXa = swayXa * -1;
		degRoll = degRoll * -1;
	end

	local att = self:GetAttachment(self:LookupAttachment(self.MuzzleFlashAttachment or "muzzle"));
	local xsn;
	if att then
		att.Pos = att.Pos - (att.Ang:Forward() * brl);
		xsn = self:WorldToLocal(att.Pos);
	else
		xsn = Vector(0, 0, 0);
	end

	local oxc = -(self.c_oxc or 0) * 8;
	local oxq = -(self.c_oxq or 0) * 8;
	local oyq = self.c_oyq or 0;
	local offsetPos = Vector(0, (degRoll * -.065) - (oxc * .35 - oxq * .415) * .2 - (degYaw * .08), max(degRoll, 0) * .025); --[[FORWARD]] --[[RIGHT]] --oxq * -.05, --[[UP]] --oyq * -.05
	local offsetAng = Angle(oyq * 1.75, (oxq * 1.0) - (oxc * 2.65) + degYaw, (oxq * 2.15) + (oxc * .75) - (degRoll / 3));
	local yofof = lerp(self.VMIronsights, -3, 3);
	local corp = self.CenterOfRotationPos or VECTOR_ZERO;
	local cora = self.CenterOfRotationAng or ANGLE_ZERO;
	local vm = self:GetOwner():GetViewModel();
	--local bpn_weapon = vm:LookupBone("b_wpn");
	--local point = WorldToLocal(EyePos(), EyeAngles(), vm:GetBonePosition(bpn_weapon), EyeAngles());
	pos, ang = Plutonic.Framework.RotateAroundPoint(pos, ang, Vector(6, -1.5, yofof) + corp, offsetPos, offsetAng);
	self.PointOrigin = xsn;
	pos, ang = self:DoCrouch(pos, ang);
	pos, ang = self:DoBlocked(pos, ang);
	local diffp, diffa = pos + Vector(), ang + Angle();
	pos, ang = self:DoIdle(pos, ang);
	diffp, diffa = diffp - pos, diffa - ang;
	--print(impulse.PosToCode(point))
	if self.ViewModelOffsetAng then
		local offsetang = self.ViewModelOffsetAng;
		ang:RotateAroundAxis(ang:Right(), offsetang.p);
		ang:RotateAroundAxis(ang:Up(), offsetang.y);
		ang:RotateAroundAxis(ang:Forward(), offsetang.r);
	end

	if self.ViewModelOffset then
		local offset = self.ViewModelOffset;
		pos = pos + (ang:Right() * offset.x);
		pos = pos + (ang:Forward() * offset.y);
		pos = pos + (ang:Up() * offset.z);
	end

	ang:RotateAroundAxis(ang:Right(), self.VMRecoilAng.p);
	ang:RotateAroundAxis(ang:Up(), self.VMRecoilAng.y);
	ang:RotateAroundAxis(ang:Forward(), self.VMRecoilAng.r);
	pos = pos + (ang:Right() * self.VMRecoilPos.x);
	pos = pos + (ang:Forward() * self.VMRecoilPos.y);
	pos = pos + (ang:Up() * self.VMRecoilPos.z);
	--pos, ang = Plutonic.Framework.RotateAroundPoint(LocalToWorld(VECTOR_ZERO, ANGLE_ZERO, pos, ang), ang, VECTOR_ZERO, VECTOR_ZERO, -LocalPlayer():GetViewPunchAngles() - ANGLE_ZERO);
	att = self:GetAttachment(self:LookupAttachment(self.MuzzleFlashAttachment or "muzzle"));
	xsn = VECTOR_ZERO;
	if att then
		att.Pos = att.Pos - (att.Ang:Forward() * brl);
		xsn = self:WorldToLocal(att.Pos);
	else
		xsn = Vector(0, 0, 0);
	end

	self.PointOrigin = xsn;
	pos, ang = self:DoWalkBob(pos, ang);
	local lookDown = -1.725 * ang:Forward() + -.185 * ang:Up();
	local lookUp = 4 * ang:Forward() + .65 * ang:Up();
	pos = pos + lerpVector(EyeAngles().p / 180, lookDown, lookUp) * (1 - self.VMIronsights);

	return pos, ang;
end

Plutonic.GetViewModelPosition = SWEP.GetViewModelPosition;
Plutonic.DoIronSights = SWEP.DoIronSights;
Plutonic.DoWallLeanThink = SWEP.DoWallLeanThink;
Plutonic.DoSprint = SWEP.DoSprint;
Plutonic.DoCrouch = SWEP.DoCrouch;
Plutonic.DoBlocked = SWEP.DoBlocked;
Plutonic.DoIdle = SWEP.DoIdle;
Plutonic.DoWalkBob = SWEP.DoWalkBob;
Plutonic.DoIronsights = SWEP.DoIronsights;
Plutonic.PostRender = SWEP.PostRender;
function SWEP:DrawHoloSight(vm_pos, vm_ang, att)
	print("[Plutonic] DrawHoloSight is deprecated!");
end

SWEP.ViewPunchEffects = {
	{Pos = Vector(0, 0, 0), Ang = Angle(-1.7, 0, -0.11)},
	{Pos = Vector(0, 0, 0), Ang = Angle(-1.17, 0, -0.05)},
	{Pos = Vector(0, 0, 0), Ang = Angle(-1.46, 0, 0.07)},
	{Pos = Vector(0, 0, 0), Ang = Angle(-1.23, 0, 0.13)},
};

Plutonic.Hooks.Add("PostDrawPlayerHands", function() end);
function SWEP:ProceduralRecoil(force)
	self.lastshot = CurTime();
	if self:GetIronsights() then
		force = force * 0.08;
	end

	force = force;
	local rPos = self.BlowbackPos + Vector();
	local rAng = self.BlowbackAngle + Angle();
	local pitchKnock = math.Rand(1.1, 3.2) * force;
	rAng:RotateAroundAxis(rAng:Right(), -pitchKnock);
	rPos = rPos - (rAng:Up() * (pitchKnock / 2));
	local yawKnock = math.Rand(-0.6, 0.6) * force;
	rAng:RotateAroundAxis(rAng:Up(), yawKnock);
	rPos = rPos + (rAng:Right() * (yawKnock / 2));
	local rollKnock = math.Rand(-2, 2) * force;
	rAng:RotateAroundAxis(rAng:Forward(), rollKnock);
	rPos = rPos + (rAng:Right() * (rollKnock / 2));
	rPos = rPos - (rAng:Forward() * math.Rand(4, 6)) * force;
	self.VMRecoil = (self.VMRecoil or Vector()) + rPos;
	self.VMRecoilAng = (self.VMRecoilAng or Angle()) + rAng;
	self.VMRecoilAmt = force * (self:GetIronsights() and 1 or .01);
	self.VMRecoilSeed = math.Rand(1000000, 9999999);

	local pl = self.ViewPunchEffects[math.random(1, #self.ViewPunchEffects)];
	PrintTable(pl);
	print(type(pl))
	print(type(pl[2]))
	if isvector(pl.Pos) and isangle(pl.Ang) then
		self:PL_ViewPunch(pl.Pos, pl.Ang);
	end
end

SWEP.CAM_ReloadAlp = 0;
SWEP.CAM_ReloadAct = 0;

Plutonic.ViewPunch = {};
Plutonic.ViewPunch.Pos = Vector(0, 0, 0);
Plutonic.ViewPunch.Ang = Angle(0, 0, 0);

SWEP.ViewPunchPlutonicP = Vector();
SWEP.ViewPunchPlutonicA = Angle();

SWEP.PlutonicViewPunchIsAdditive = false;

function SWEP:PL_ViewPunch(pos, ang)
	local vp = Plutonic.ViewPunch;

	local current_pos = self.PlutonicViewPunchIsAdditive and vp.Pos or VECTOR_ZERO;
	local current_ang = self.PlutonicViewPunchIsAdditive and vp.Ang or ANGLE_ZERO;

	local m = Matrix();
	m:SetAngles(current_ang);
	m:SetTranslation(current_pos);
	local recoil = self:GetRecoil() * 1.50 + 1;
	if self:GetIronsights() then
		recoil = recoil * 0.5;
	end
	m:Rotate(ang * recoil);
	m:Translate(pos * recoil);

	-- set the shared vars
	Plutonic.ViewPunch.Pos = m:GetTranslation();
	Plutonic.ViewPunch.Ang = m:GetAngles();

	return pos, ang;
end

function SWEP:CalcView(ply, pos, ang, fov)

	local m = Matrix();
	m:SetAngles(ang);
	m:SetTranslation(pos);

	m:Translate(self.ViewPunchPlutonicP or VECTOR_ZERO);
	m:Rotate(self.ViewPunchPlutonicA or ANGLE_ZERO);

	pos = m:GetTranslation();
	ang = m:GetAngles();

	if Plutonic.Framework.GetControl_Bool("use_anim_cam", true) then
		if self:GetReloading() then
			local vm = self:GetOwner():GetViewModel();
			local n_ang = nil;
			-- aim
			if not self.GetReloadAnimation then
				local aim = vm:GetAttachment(self.ReloadAttach or 2);
				if aim then
					n_ang = (aim.Pos - pos):Angle();
				end
			else
				n_ang = self:GetReloadAnimation(pos, ang, self.CAM_ReloadAlp);
			end

			self.CAM_ReloadAlp = Lerp(Frametime(), self.CAM_ReloadAlp, self.ReloadProceduralCameraFrac or .1);

			return pos, lerpAngle(self.CAM_ReloadAlp * ((vm:SequenceDuration() - (Curtime() - self.CAM_ReloadAct)) / vm:SequenceDuration()), ang, n_ang), fov;
		else
			self.CAM_ReloadAlp = 0;
			self.CAM_ReloadAct = Curtime();

			return pos, ang, fov;
		end;
	end

	return pos, ang, fov;
end