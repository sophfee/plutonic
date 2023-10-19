--      Copyright (c) 2022-2023, sophie S. All rights reserved      --
-- Plutonic is a project built for Landis Games. --
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
local Curtime = UnPredictedCurTime;
local Frametime = RealFrameTime;
local Realtime = RealTime;
local vec = Vector;
local lerp = Lerp;
local lerpAngle = LerpAngle;
local lerpVector = LerpVector;
local approach = math.Approach;
local easeOutQuad = Plutonic.Ease.OutQuad;
local easeOutCirc = Plutonic.Ease.OutCirc;
local easeInQuad = Plutonic.Ease.InQuad;
local easeInCirc = Plutonic.Ease.InSine;
local VECTOR_ZERO = vec(0, 0, 0);
local ANGLE_ZERO = Angle(0, 0, 0);
function SWEP:PreDrawViewModel(vm)
	if self.CustomMaterial and not self.CustomMatSetup then
		self:GetOwner():GetViewModel():SetMaterial(self.CustomMaterial);
		self.CustomMatSetup = true;
	end

	if self.scopedIn then return self.scopedIn; end
end

function SWEP:InitRT()
	self.ScopeTex = Material("ph_scope/ph_scope_lens3")
	self.ScopeRenderTarget = GetRenderTarget( "plutonic_scope_rt", 512, 512, true )
	self.ScopeRenderMaterial = CreateMaterial("plutonic_scope_hd", "UnlitGeneric", {
		["$model"] = 1,
		["$basetexture"] = self.ScopeRenderTarget:GetName(),
		["$phong"] = 1,
		["$phongexponent"] = 128,
		["$rimlight"] = 1,
		["$rimlightexponent"] = 32,
		["$rimlightboost"] = 128
	})

	local material = Material("!plutonic_scope_hd")
	material:SetTexture("$basetexture", self.ScopeRenderTarget)
	material:SetInt("$phong", 1)
	material:SetFloat("$phongexponent", 128)
	material:SetFloat( "$pp_colour_addr", 0 )
	material:SetFloat( "$pp_colour_addg", 0 )
	material:SetFloat( "$pp_colour_addb", 0 )
	material:SetFloat( "$pp_colour_mulr", 0 )
	material:SetFloat( "$pp_colour_mulg", 0 )
	material:SetFloat( "$pp_colour_mulb", 0 )
	material:SetFloat( "$pp_colour_brightness", 0 )
	material:SetInt( "$rimlight", 1 )
	material:SetFloat( "$rimlightexponent", 20 )
	material:SetFloat( "$rimlightboost", 100 )
	material:SetFloat( "$selfillum", 0 )
	material:Recompute()
end
local pp_ca_base, pp_ca_r, pp_ca_g, pp_ca_b = Material("pp/arccw/ca_base"), Material("pp/arccw/ca_r"), Material("pp/arccw/ca_g"), Material("pp/arccw/ca_b")
local pp_ca_r_thermal, pp_ca_g_thermal, pp_ca_b_thermal = Material("pp/arccw/ca_r_thermal"), Material("pp/arccw/ca_g_thermal"), Material("pp/arccw/ca_b_thermal")

pp_ca_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_b:SetTexture("$basetexture", render.GetScreenEffectTexture())

pp_ca_r_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_g_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_b_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())

local greenColor = Color(0, 255, 0)  -- optimized +10000fps
local whiteColor = Color(255, 255, 255)
local blackColor = Color(0, 0, 0)

local tex_black = Material("arccw/hud/black.png")

local white_base = Material("models/debug/debugwhite")
function SWEP:ViewModelDrawn(flags)
	self.Owner:GetHands():Draw()
	
	if Plutonic.Framework.Overdraw then
		for attName, _ in pairs(self.EquippedAttachments or {}) do
			local attData = self.Attachments[attName];
			if not attData then continue; end
			local c = attData.Cosmetic;
			local att = self.AttachmentEntCache[attName];
			if not IsValid(att) then continue; end
			local ang = att:GetAngles()

			local up = ang:Up()
			local fw = ang:Forward()

			ang:RotateAroundAxis(up, -180);
			ang:RotateAroundAxis(ang:Forward(), 180);
			--ang:RotateAroundAxis(ang:Forward(), -180);
			local pos = att:GetPos() + (att:GetAngles():Forward() *  1)
			
			render.UpdateScreenEffectTexture()
			--DrawMaterialOverlay("models/props_c17/fisheyelens", -0.1 )

			local scopeTex = attData.ScopeTexture or Material("models/debug/debugwhite")																			;
			local fw = att:GetAngles():Forward()

			render.SetMaterial(scopeTex)
			local w = 1024 / 16/9
			--render.DrawQuadEasy(pos, fw, .16, .16, color_white, -ang.r);
		end
		return;
	end
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
		if attData.Behavior == "1x_Sight" then
			Plutonic.Framework.Mask(att);
			local rpos = attData.Reticule.Pos;
			pos, ang = att:GetPos(), att:GetAngles();
			ang:RotateAroundAxis(ang:Forward(), -0);
			ang:RotateAroundAxis(ang:Up(), -90);
			ang:RotateAroundAxis(ang:Forward(), 180);
			
			pos = pos + ang:Forward() * rpos.x;
			pos = pos + ang:Right() * rpos.y;
			pos = pos + ang:Up() * rpos.z;
			local size = attData.Reticule.Size or 32;
			render.SetMaterial(attData.Reticule.Material or reticule);
			render.DrawQuadEasy(pos, ang:Forward(), size, size, attData.Reticule.Color or color_white, -ang.r);
			render.DrawSprite(pos, size, size, color_white)
			Plutonic.Framework.UnMask();
		end

		if attData.Behavior == "rt_scope" then

			if att.ProjTexture then
				att.ProjTexture:Remove()
			end
			if not att.RenderTargetSetup then
				att:SetSubMaterial(0, "")
				att:SetSubMaterial(1, "!plutonic_scope_hd")
				att.RTSetup = true
			end

			local ang = att:GetAngles()
			ang:RotateAroundAxis(ang:Right(), 180)
			ang:RotateAroundAxis(ang:Forward(), 180)

			local pos = att:GetPos() + (ang:Forward() *  24)
			--render.PushRenderTarget(self.ScopeRenderTarget, 0, 0, 512, 512)
			cam.Start3D(pos, ang, 90, 0, 0, 512, 512, 5, 4096)
			
			render.Clear( 50, 50, 50, 255, true, true)
			if (self.VMIronsights <= 0.05) then 
				render.UpdateRefractTexture()
				render.UpdateFullScreenDepthTexture()
				render.UpdatePowerOfTwoTexture()
				render.UpdateScreenEffectTexture()
				--DrawMaterialOverlay("arc9/shadow.png", -.25)
				
				cam.End3D()
				render.PopRenderTarget()
				return 
			end
			Plutonic.Framework.Overdraw = true

			render.SetBlend(1)

			local oang = ang

			local ang = att:GetAngles()

			local up = ang:Up()
			local fw = ang:Forward()

			ang:RotateAroundAxis(up, -180);
			ang:RotateAroundAxis(ang:Forward(), 180);
			--ang:RotateAroundAxis(ang:Forward(), -180);
			local pos = att:GetPos() + (ang:Forward() *  24)
			
			render.UpdateScreenEffectTexture()
			--DrawMaterialOverlay("models/props_c17/fisheyelens", -0.1 )

			if attData.ScopeTexture then
				local scopeTex = attData.ScopeTexture;
				local fw = att:GetAngles():Forward()

				render.SetMaterial(scopeTex)
				render.DrawQuadEasy(att:GetPos() - pos, att:GetAngles():Forward() - fw, 48, 48, color_white, -ang.r);

				render.DrawScreenQuad()
			end
				
			render.RenderView({
				origin = pos,
				angles = oang,
				fov = 90 / (attData.Magnification or 4),
				x = 0,
				y = 0,
				w = ScrW(),
				h = ScrH(),
				drawviewmodel = false,
				drawhud = false,
				aspectratio = 1
			})

			local ang = att:GetAngles()

			local up = ang:Up()
			local fw = ang:Forward()

			ang:RotateAroundAxis(up, -180);
			ang:RotateAroundAxis(ang:Forward(), 180);
			--ang:RotateAroundAxis(ang:Forward(), -180);
			local pos = att:GetPos() + (ang:Forward() *  24)
			
			render.UpdateScreenEffectTexture()
			--DrawMaterialOverlay("models/props_c17/fisheyelens", -0.1 )

			if attData.ScopeTexture then
				local scopeTex = attData.ScopeTexture;
				local fw = att:GetAngles():Forward()

				render.SetMaterial(scopeTex)
				render.DrawQuadEasy(VECTOR_ZERO + fw * 8, fw, 4, 4, color_white,-ang.r);

				--render.DrawScreenQuad()
			end
			local overlay = attData.Overlay;
			render.SetMaterial(overlay)
			render.DrawScreenQuad()
			if attData.Vignette then
				
			end
			cam.End3D()
			--render.PopRenderTarget()
			

			--surface.SetMaterial(self.ScopeRenderMaterial)
			--surface.SetDrawColor(255, 255, 255, 255)
			--surface.DrawTexturedRect(0, 0, 512, 512)
			
			Plutonic.Framework.Overdraw = false
			Plutonic.Framework.Halfdraw = false

			render.SetStencilReferenceValue(0)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.ClearStencil()
			render.SetStencilEnable(true)
			render.SetStencilWriteMask(0xF0)
			render.ClearStencilBufferRectangle(0, 0, ScrW(), ScrH(), 0x0F)
			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilTestMask(0x00)
			render.SetStencilFailOperation(STENCIL_DECR)

			att:DrawModel()

			render.SetStencilTestMask(0xFF)
			render.SetStencilReferenceValue(0x1F)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilTestMask(0xFF)
			render.SetStencilReferenceValue(0x1F)
			render.SetStencilCompareFunction(STENCIL_LESSEQUAL)
			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
			
			render.UpdateScreenEffectTexture()
			DrawBokehDOF(self.VMIronsights * 6, 0, 0)

			render.SetStencilCompareFunction(STENCIL_ALWAYS)

			local scopeTex = attData.ScopeTexture;
				local fw = att:GetAngles():Forward()

				render.SetMaterial(scopeTex)
				local size = attData.Reticule.Size or 32;
				local w = 1024 / 16/9
				render.DrawQuadEasy(pos, fw, 1, 1, color_white, -ang.r);

			Plutonic.Framework.UnMask(att);
			
			
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
	local oyq = easeOutQuad(oyq_a) * clamp(dy, -1, 1);
	self.c_oyq = lerp(Frametime() * 7, self.c_oyq or 0, oyq);
	self.Ironsights = self:GetIronsights();
	self._sprinting = self._sprinting or false;
	local sprinting = self:IsSprinting();
	if sprinting ~= self._sprinting then
		self._sprinting = sprinting;
		if self.OnSprintStateChanged then
			self:OnSprintStateChanged(sprinting);
		end
	end

	self.VMSprint = lerp(Frametime() * 4, self.VMSprint or 0, sprinting and 1 or 0);
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
	self.VMBobCycle = lerp(Frametime() * 6, self.VMBobCycle, Plutonic.Framework.IsMoving() and 1 or 0);
	local l = self:IsSprinting() and 1 or 0;
	lerpSpeed = lerp(Frametime() * 5, lerpSpeed, l);
	local onvel = self:GetOwner():GetVelocity();
	local uvel = onvel.z;
	local vel = clamp(uvel / 80, -34, 34);
	self.VMVel = self.VMVel or 0;
	self.VMVel = Lerp(Frametime() * 5, self.VMVel, vel);
	local ft = Frametime();
	local ftM = self.SwaySpeed or 11;
	self.VMDeltaX = lerp(ft * ftM, self.VMDeltaX or 0, 0);
	self.VMDeltaY = lerp(ft * ftM, self.VMDeltaY or 0, 0);
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
		self.c_lpos = lerpVector(Frametime() * 16, self.c_lpos or VECTOR_ZERO, loweredPos);
		self.c_lang = lerpAngle(Frametime() * 16, self.c_lang or ANGLE_ZERO, loweredAng);
	end
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
	local breath2 = cos(rt * .625) * 1.6;

	return Plutonic.Framework.RotateAroundPoint(pos, ang, Vector(-1, -2, -3), Vector(0, breath2 * -.35, 0) * (1 - self.VMIronsights), Angle(breath2, 0, 0) * (1 - self.VMIronsights));
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
function SWEP:DoWalkBob(pos, ang)
	if self.DoCustomWalkBob then return self:DoCustomWalkBob(pos, ang); end
	local rt = Realtime();
	if self:GetOwner():GetVelocity():Length2DSqr() > 60 ^ 2 then
		WalkingTime = WalkingTime + FrameTime() * 2;
	end

	local mv = clamp(self:GetOwner():GetVelocity():Length2D() / 200, 0, 1);
	if self:GetIronsights() then
		mv = mv * 0.25;
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
		local rate = 11.2

		local sn0 = sin(rt * rate) * mv;
		local cs0 = cos(rt * rate) * mv;
		local m = cs0 > 0 and 1 or -1;
		local sweep = easeInCirc(abs(cs0)) * -1 * m;
		
		
		local d = -sin(rt * rate * 2);
		m = sn0 > 0 and 1 or -1;
		local sweeph = easeInCirc(abs(sn0)) * 1 * m;
		local xcz = sin(rt * rate * 2) * cos(rt * rate * .5) * -2.6;
		pos0, ang0 = Plutonic.Framework.RotateAroundPoint(
			pos,
			ang,
			Vector(-9, -2, -3),
			Vector(
				d * -.1, 
				(sn0 * -.6) - (sweep * .4), 
				-(abs(cs0) * .175) - 0.2
			), 
			Angle(
				d * -1 + (abs(sn0) * -.8) + (abs(sweeph) * .5),
				sn0 * -2.8 + (sweep * -.4),
				0
			)
		);
	end

	local pos1, ang1 = pos + Vector(), ang + Angle();
	do
		local sn1 = sin(rt * 8.4) * mv;
		local sn2 = sin(rt * 4.2);
		local sz3 = cos(rt * 8.4) * cos(rt * 12.6) * .079;
		local cs2 = abs(cos(rt * 4.2));
		local xcz = sin(rt * 25.2) * cos(rt * 6.3) * (3 * mv);
		local stride = sin(rt * 7.5) * mv;
		pos1, ang1 = Plutonic.Framework.RotateAroundPoint(
			pos, 
			ang, 
			Vector(-9, -2, -3), 
			Vector(
				-0, 
				sn1 * -.39 + (sn2 * -1.2 * mv) + (stride), 
				sz3 * mv - (mv * .5)
			), 
			Angle(
				(cs2 * 2.75 * mv) + (cs2 * -3.39 * mv), 
				sn2 * -5.2 * mv, 
				0
			)
		);
	end

	local interp = Plutonic.Ease.InOutQuart(self.VMSprint);
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
	local swayXv = (xva * .25);
	local swayXa = -xva * 1;
	if isIronsights then
		rd = rd / 2;
	end

	self.VMRoll = lerp(ft * 3, self.VMRoll, rd * movepercent);
	local degRoll = deg(self.VMRoll) / 3;
	degRoll = degRoll + ((self.VMWallLean or 0) * 24.4);
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
	local oyq = -self.c_oyq or 0;
	local offsetPos = Vector(0, (degRoll * -.25) - (oxc * .35 - oxq * -.415) * .2 + degRoll * .2, oyq * .25 + (abs(oxq) * -.0908 -abs(oxc) * .17)); --[[FORWARD]] --[[RIGHT]] --oxq * -.05, --[[UP]] --oyq * -.05
	local offsetAng = Angle(oyq * -3 + degPitch, oxq + (oxc * .7), (oxq * .5) - (degRoll * 1.6) + (oxc * -3.1));
	local yofof = lerp(self.VMIronsights, -3, 0);
	local corp = self.CenterOfRotationPos or Vector()
	local cora = self.CenterOfRotationAng or Angle()
	pos, ang = Plutonic.Framework.RotateAroundPoint(pos, ang, Vector(6, -1.5, yofof) + corp, offsetPos, offsetAng);
	self.PointOrigin = xsn;
	pos, ang = self:DoCrouch(pos, ang);
	pos, ang = self:DoBlocked(pos, ang);
	pos, ang = self:DoIdle(pos, ang);
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
	self.VMRecoilPos = lerpVector(ft * 2, self.VMRecoilPos, VECTOR_ZERO);
	self.VMRecoilAng = lerpAngle(ft * 2, self.VMRecoilAng, ANGLE_ZERO);
	pos, ang = Plutonic.Framework.RotateAroundPoint(LocalToWorld(VECTOR_ZERO, ANGLE_ZERO, pos, ang), ang, VECTOR_ZERO, VECTOR_ZERO, -LocalPlayer():GetViewPunchAngles() - ANGLE_ZERO);
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
end

SWEP.CAM_ReloadAlp = 0;
SWEP.CAM_ReloadAct = 0;
function SWEP:CalcView(ply, pos, ang, fov)
	if not Plutonic.Framework.GetControl_Bool("use_anim_cam", true) then return; end
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
	end
end