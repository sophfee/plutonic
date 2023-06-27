--      Copyright (c) 2022-2023, sophie S. All rights reserved      --
-- Plutonic is a project built for Landis Games. --
SWEP.CustomEvents = SWEP.CustomEvents or {}
SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAngle = Angle(0, 0, 0)
SWEP.BarrelLength = 6
SWEP.c_alpha = 0
SWEP.c_lang = Angle(0, 0, 0)
SWEP.c_lpos = Vector(0, 0, 0)
SWEP.c_oxc = 0
SWEP.c_oxq = 0
SWEP.c_oyq = 0

local math = math
local render = render
local surface = surface
local draw = draw
local cam = cam

local dofmat = Material("pp/dof")
local grad = Material("vgui/gradient-d")
local blur = Material("pp/blurscreen")
local reticule = Material("models/weapons/insurgency_sandstorm/ins2_sandstorm/kobra_reticle")
local abs = math.abs
local min = math.min
local max = math.max
local clamp = math.Clamp
local sin = math.sin
local cos = math.cos
local rad = math.rad
local deg = math.deg
local pi = math.pi
local pi2 = math.pi * 2
local round = math.Round
local Curtime = UnPredictedCurTime
local Frametime = RealFrameTime
local Realtime = RealTime
local vec = Vector
local ang = Angle
local lerp = Lerp
local lerpAngle = LerpAngle
local lerpVector = LerpVector
local approach = math.Approach

local easeInQuad = math.ease.InQuad
local easeOutQuad = math.ease.OutQuad
local easeInOutQuad = math.ease.InOutQuad

local easeInElastic = math.ease.InElastic
local easeOutElastic = math.ease.OutElastic
local easeInOutElastic = math.ease.InOutElastic

local easeInQuint = math.ease.InQuint
local easeOutQuint = math.ease.OutQuint
local easeInOutQuint = math.ease.InOutQuint

local easeInSine = math.ease.InSine
local easeOutSine = math.ease.OutSine
local easeInOutSine = math.ease.InOutSine

local easeInCirc = math.ease.InCirc
local easeOutCirc = math.ease.OutCirc
local easeInOutCirc = math.ease.InOutCirc

local easeInExpo = math.ease.InExpo
local easeOutExpo = math.ease.OutExpo
local easeInOutExpo = math.ease.InOutExpo

local VECTOR_ZERO = vec(0, 0, 0)
local ANGLE_ZERO = ang(0, 0, 0)

function SWEP:PreDrawViewModel(vm)
	if self.CustomMaterial and not self.CustomMatSetup then
		self.Owner:GetViewModel():SetMaterial(self.CustomMaterial)
		self.CustomMatSetup = true
	end
	if self.scopedIn then
		return self.scopedIn
	end
end



function SWEP:ViewModelDrawn()
	if Plutonic.Framework.Overdraw then return end

	local vm = self.Owner:GetViewModel()

	if not IsValid(vm) then
		return
	end

	if self.ExtraViewModelRender then
		self:ExtraViewModelRender(vm)
	end

	local boneMatrices = {}

	local drawnNames = {}

	self.EquippedAttachments = self.EquippedAttachments or {}
	self.AttachmentEntCache = self.AttachmentEntCache or {}
	
	for attName, _ in pairs(self.EquippedAttachments) do

		local attData = self.Attachments[attName]

		if not attData then
			continue
		end

		local c = attData.Cosmetic
		

		local att = self.AttachmentEntCache[attName]
		if (not IsValid(att)) then
			att = ClientsideModel(c.Model, RENDERGROUP_VIEWMODEL)
			att:SetParent(vm)
			att:SetNoDraw(true)
			att:AddEffects(EF_BONEMERGE)

			if c.Scale then
				if c.BoneScale then
					att:ManipulateBoneScale(0, Vector(c.Scale,c.Scale,c.Scale))
				else
					att:SetModelScale(c.Scale)
				end
			end
			self.AttachmentEntCache[attName] = att
		end
		local bone = vm:LookupBone(c.Bone)

		if not bone then
			continue
		end

		local m = vm:GetBoneMatrix(bone)

		if not m then
			continue
		end

		local pos, ang = m:GetTranslation(), m:GetAngles()

		pos = pos + ang:Forward() * c.Pos.x
		pos = pos + ang:Right() * c.Pos.y
		pos = pos + ang:Up() * c.Pos.z

		att:SetPos(pos)
		ang:RotateAroundAxis(ang:Up(), c.Ang.y)
		ang:RotateAroundAxis(ang:Right(), c.Ang.p)
		ang:RotateAroundAxis(ang:Forward(), c.Ang.r)
		att:SetAngles(ang)

		if attData.RenderOverride then
			attData.RenderOverride(self, vm, att)
		else
			att:DrawModel()
		end

		drawnNames[attName] = true

		if attData.Behavior == "1x_Sight" then
			Plutonic.Framework.Mask(att)

			local rpos = attData.Reticule.Pos
			local pos, ang = att:GetPos(), att:GetAngles()

			ang:RotateAroundAxis(ang:Forward(), -0)
			ang:RotateAroundAxis(ang:Up(), -90)

			pos = pos + ang:Forward() * -rpos.x
			pos = pos + ang:Right() * rpos.y
			pos = pos + ang:Up() * rpos.z
			local size = attData.Reticule.Size or 32
			
			render.SetMaterial(attData.Reticule.Material or reticule)
			render.DrawQuadEasy(pos, ang:Forward(), size, size, attData.Reticule.Color or color_white, ang.r)
			--render.DrawSprite(pos, size, size, color_white)

			Plutonic.Framework.UnMask()
		end
	end

	for name, csEnt in pairs(self.AttachmentEntCache) do
		if (not drawnNames[name]) then
			csEnt:Remove()
		end
	end
end

concommand.Add("plutonic_client_debug_attachments", function()
	local lp = LocalPlayer()
	local wep = lp:GetActiveWeapon()

	print("Dumping Weapon.Attachments:")
	PrintTable(wep.Attachments)

	print("\nDumping Weapon.AttachmentEntCache:")
	PrintTable(wep.AttachmentEntCache)

	print("\nDumping Weapon.EquippedAttachments:")
	PrintTable(wep.EquippedAttachments)

end)

function SWEP:PostDrawViewModel(vm, ply, wep)
end

local function LerpC(t, a, b, powa)
	return a + (b - a) * math.pow(t, powa)
end


function SWEP:OnSprintStateChanged(sprinting)
	self.VMSprint = !sprinting and math.ease.OutQuad(self.VMSprint or 0) or math.ease.InQuad(self.VMSprint or 0)
end


function SWEP:PostRender()
	self:DoWallLeanThink()

	local dx = self.VMDeltaX or 0
	local dy = self.VMDeltaY or 0

	local oxc_a = min(abs(dx) / 8, 1)
	local oxc = easeOutQuad(oxc_a) * clamp(dx / -4, -.5, .5)
	self.c_oxc = lerp(Frametime() * 8, self.c_oxc or 0, oxc)

	local oxq_a = min(abs(dx) / 16, 1)
	local oxq = easeOutCirc(1- oxq_a) * clamp(dx / 16, -.5,.5) -- math.ease.OutQuad(min(abs(self.VMDeltaX) / 8, 1)) * clamp(self.VMDeltaX, -8, 8)
	self.c_oxq = lerp(Frametime() * 12, self.c_oxq or 0, oxq)

	local oyq_a = min(abs(dy) / 1, 1)
	local oyq = easeOutQuad(oyq_a) * clamp(dy, -1, 1)
	self.c_oyq = lerp(Frametime() * 8, self.c_oyq or 0, oyq)

	self.Ironsights = self:GetIronsights()
	self._sprinting = self._sprinting or false
	local sprinting = self:IsSprinting()
	if (sprinting != self._sprinting) then
		self._sprinting = sprinting
		if self.OnSprintStateChanged then
			self:OnSprintStateChanged(sprinting)
		end
	end

	self.VMSprint = lerp(Frametime() * 4, self.VMSprint or 0, sprinting and 1 or 0 ) 

	self.VMIronsights = approach(self.VMIronsights or 0, self:GetIronsights() and 1 or 0, FrameTime() * 1.7 )
	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 32,
		filter = self.Owner
	})
	self.VMBlocked = self.VMBlocked or 0
	self.VMBlocked = lerp(Frametime() * 13, self.VMBlocked, tr.Hit and tr.Fraction or 1) 
	local isIronsights = self:GetIronsights()
	local isDuck = (self.Owner:KeyDown(IN_DUCK) or self.Owner:Crouching()) and not isIronsights
	self.VMCrouch = approach( self.VMCrouch, isDuck and 1 or 0, Frametime() * 2.5 )
	local ovel = self.Owner:GetVelocity()
	local move = vec(ovel.x, ovel.y, 0)
	self.VMBobCycle = lerp(Frametime() * 6, self.VMBobCycle, Plutonic.Framework.IsMoving() and 1 or 0)
	local mul = self:IsSprinting() and 1 or 1
	local l = self:IsSprinting() and 1 or 0
	lerpSpeed = lerp(Frametime() * 5, lerpSpeed, l)
	local onvel = self.Owner:GetVelocity()
	local uvel = onvel.z
	local vel = clamp((uvel) / 80, -34, 34)
	self.VMVel = self.VMVel or 0
	self.VMVel = Lerp(Frametime() * 5, self.VMVel, vel)

	local ft = Frametime()
	local ftM = self.SwaySpeed or 11
	self.VMDeltaX = lerp(ft * ftM, self.VMDeltaX or 0, 0)
	self.VMDeltaY = lerp(ft * ftM, self.VMDeltaY or 0, 0)


	self.VMDeltaXWeighted = approach(self.VMDeltaXWeighted or 0, 0, ft * 32)
	self.VMDeltaYWeighted = approach(self.VMDeltaYWeighted or 0, 0, ft * 32)

	self.VMRecoilAmt = self.VMRecoilAmt or 0
	self.VMRecoilAmt = lerp(ft * 2, self.VMRecoilAmt, 0)

	local alpha = isIronsights and math.ease.OutExpo( self.VMIronsights ) or math.ease.InSine( self.VMIronsights)
	self.c_alpha = lerp(FrameTime() * 8, self.c_alpha or 0, alpha)

	if (self.LoweredPos) then
		local t = self:IsSprinting() and math.ease.OutQuad(self.VMSprint or 0) or math.ease.InQuad(self.VMSprint or 0)
		local loweredPos = Plutonic.Interpolation.VectorBezierCurve( t, VECTOR_ZERO, self.LoweredMidPos, self.LoweredPos)
		local loweredAng = Plutonic.Interpolation.AngleBezierCurve( t, ANGLE_ZERO, self.LoweredMidAng, self.LoweredAng)
		self.c_lpos = lerpVector(Frametime() * 16, self.c_lpos or VECTOR_ZERO, loweredPos)
		self.c_lang = lerpAngle(Frametime() * 16, self.c_lang or ANGLE_ZERO, loweredAng)
	end
end

Plutonic.Hooks.Add("PostRender", function()

	local me = LocalPlayer()

	if not IsValid(me) then return end

	local wep = me:GetActiveWeapon()

	if not IsValid(wep) then return end
	if not wep.IsPlutonic then return end

	wep:PostRender()
end)

SWEP.VMDeltaX = 0
SWEP.VMDeltaY = 0
SWEP.VMRoll = 0
SWEP.VMRecoilPos = Vector(0, 0, 0)
SWEP.VMRecoilAng = Angle(0, 0, 0)
SWEP.VMOffsetPos = Vector(0, 0, 0)
SWEP.VMOffsetAng = Angle(0, 0, 0)
SWEP.Primary.FirePower = 1


function Plutonic.Framework.IsMoving()
	return LocalPlayer():GetVelocity():Length2DSqr() > 40^2
end

function SWEP:IsMoving()
	return self:GetOwner():GetVelocity():Length2DSqr() > 40^2
end

function SWEP:IsDucked()
	local isIronsights = self:GetIronsights()
	return ((self.Owner:KeyDown(IN_DUCK) or self.Owner:Crouching()) and not isIronsights)
end

SWEP.CrouchPos = Vector(.7, -0, -.4)
SWEP.CrouchAng = Angle(0, 0, -0)

function SWEP:DoCrouch(pos, ang)
	self.VMCrouch = self.VMCrouch or 0
	local alpha
	if self:IsDucked() then
		alpha = math.ease.OutQuad(self.VMCrouch)
	else
		alpha = math.ease.InQuad(self.VMCrouch)
	end
	
	--pos = pos + ang:Right() * self.CrouchPos.x * alpha
	--pos = pos + ang:Forward() * self.CrouchPos.y * alpha
	--pos = pos + ang:Up() * self.CrouchPos.z * alpha
	--ang:RotateAroundAxis(ang:Right(), self.CrouchAng.p * alpha)
	--ang:RotateAroundAxis(ang:Forward(), self.CrouchAng.r * alpha)
	--ang:RotateAroundAxis(ang:Up(), self.CrouchAng.y * alpha)
	return Plutonic.Framework.RotateAroundPoint(
		pos,
		ang,
		Vector(-9, -2, -3),
		self.CrouchPos * -alpha,
		self.CrouchAng * -alpha
	)
end

function SWEP:DoBlocked(pos, ang)
	if self.Owner != LocalPlayer() then return pos, ang end
	self.VMBlocked = self.VMBlocked or 1
	local bl = -(self.VMBlocked - 1)
	return Plutonic.Framework.RotateAroundPoint(pos, ang, self.PointOrigin or Vector(0, 0, 0), Vector(bl * -11, bl * -1, -bl *7), Angle(bl * 23, bl * -12,bl * 12))
end

SWEP.IronsightsMiddlePos = Vector(-3,-2,-1.6)
SWEP.IronsightsMiddleAng = Angle(3, 9, 4)

function SWEP:DoIronsights(pos, ang)
	self.VMIronsights = self.VMIronsights or 0
	self.VMRattle = self.VMRattle or 0
	local dir = false
	if self:GetIronsights() then
		dir = true
	end

	PLUTONIC_SEED8 = PLUTONIC_SEED8 or math.random(1000000, 9999999)
	PLUTONIC_SEED9 = PLUTONIC_SEED9 or math.random(1000000, 9999999)
	local n1 = Plutonic.Noise.Perlin(Realtime() * .2 + PLUTONIC_SEED8, (cos(Curtime() * 1.9) * 5) - PLUTONIC_SEED9, 17)
	-- Idle
	if (self:GetIronsights()) then
		ang:RotateAroundAxis(VECTOR_RIGHT, cos(Curtime() * .5) * 0.05 )
		ang:RotateAroundAxis(VECTOR_UP, sin(Curtime() * 1) * 0.05)
		
	end

	local tome = self.VMRecoilSeed or 0
	tome = tome + CurTime()

	ang:RotateAroundAxis(ang:Forward(), sin((tome * 8) * ((1/self.Primary.Delay)/4)) * (self.VMRecoilAmt or 0) * 24)

	-- fire bump
	self.lastshot = self.lastshot or 0
	local ls = self.lastshot
	local timeSince = math.min((ls + 1)- Curtime(), 1)
	local fireBump = math.ease.InElastic(math.Clamp(timeSince , 0, 1))

	local timeSince = math.min((ls + 2)- Curtime(), 2) / 2
	local fireBump2 = math.ease.InBack(math.Clamp(timeSince , 0, 1))
	pos = pos + ang:Forward() * fireBump * -.4

	

	local alpha = self.c_alpha or 0
	local ironsightPos = Plutonic.Interpolation.VectorBezierCurve( alpha, VECTOR_ZERO, self.IronsightsMiddlePos, self.IronsightsPos)
	local ironsightAng = Plutonic.Interpolation.AngleBezierCurve( alpha, ANGLE_ZERO, self.IronsightsMiddleAng, self.IronsightsAng)
	pos = pos + ang:Up() * ironsightPos.z * alpha
	pos = pos + ang:Right() * ironsightPos.x * alpha
	pos = pos + ang:Forward() * ironsightPos.y * alpha
	ang:RotateAroundAxis(ang:Right(), ironsightAng.p * alpha)
	ang:RotateAroundAxis(ang:Up(), ironsightAng.y * alpha)
	ang:RotateAroundAxis(ang:Forward(), ironsightAng.r * alpha)

	

	return pos, ang
end

function SWEP:DoIdle(pos, ang)
	self.VMIdle = self.VMIdle or 0
	local rt = Realtime()

	local breath = sin(rt * .625) * .6
	local breath2 = cos(rt * .625) * 1.6

	return Plutonic.Framework.RotateAroundPoint(
		pos,
		ang,
		Vector(-1, -2, -3),
		Vector(0,breath2 * -.35,0) * (1- self.VMIronsights),
		Angle(breath2, 0, 0) * (1- self.VMIronsights)
	)
end

SWEP.LoweredMidPos = Vector(4,-3,0.4)
SWEP.LoweredMidAng = Angle(-6,7,-5)
function SWEP:ShouldDoSprint()
	return (self.VMSprint and math.Round(self.VMSprint, 4) > 0)
end

local ANGLE_ZERO = Angle(0, 0, 0)
local VECTOR_ZERO = Vector(0, 0, 0)

function SWEP:DoSprint(pos, ang)
	if self.CustomSprint then return self:CustomSprint(pos, ang) end
	if not self.LoweredPos then return pos, ang end
	local t = self:IsSprinting() and math.ease.OutQuad(self.VMSprint or 0) or math.ease.InQuad(self.VMSprint or 0)
	local loweredPos = self.c_lpos or self.LoweredPos
	local loweredAng = self.c_lang or self.LoweredAng
	ang:RotateAroundAxis(ang:Right(), loweredAng.p)
	ang:RotateAroundAxis(ang:Up(), loweredAng.y)
	ang:RotateAroundAxis(ang:Forward(), loweredAng.r)
	pos = pos + ang:Up() * loweredPos.z
	pos = pos + ang:Right() * loweredPos.x
	pos = pos + ang:Forward() * loweredPos.y

	return pos, ang
end
lerpSpeed = 0

local walkBobOffsetPos = Vector(0, 0, 0)
local walkBobOffsetAng = Angle(0, 0, 0)
local hastickedthiscycle = false
local WalkingTime = 0
function SWEP:DoWalkBob(pos, ang)
	if self.DoCustomWalkBob then
		return self:DoCustomWalkBob(pos, ang);
	end;
	local rt = Realtime();
	if self.Owner:GetVelocity():Length2DSqr() > 60^2 then
		WalkingTime = WalkingTime + FrameTime() * 2;
	end

	local mv = clamp(self.Owner:GetVelocity():Length2D() / 200, 0, 1);

	if self:GetIronsights() then
		mv = mv * 0.25;
	end

	local pos0, ang0 = pos + Vector(), ang + Angle();
	do
		local modif = 1;
		if (self.UseSprintSequence) then
			modif = 0.1
		end
		if (not self.LoweredPos) then
			modif = 0.7
		end
		local sn0 = (sin(rt * 12.6) ) * mv ;
		local cs0 = (cos(rt * 12.6) ) * mv;
		local zc0 = sin(rt * 6.3) * cs0;

		local d = -sin(rt * 25.2)

		local ب = sin(rt * 25.2) * cos(rt * 6.3)*-5.6

		

		pos0, ang0 = Plutonic.Framework.RotateAroundPoint(
			pos,
			ang,
			Vector(-9, -2, -3), 
			Vector(d * -.1 , sn0 * -.6, -(abs(cs0) * .7145 )- 0.2) * modif,
			Angle(d * -1 + (abs(sn0) * -.8), sn0 * -2.8, ب) * modif
		);
	end


	local pos1, ang1 = pos + Vector(), ang + Angle();
	do
		local sn1 = sin(rt * 8.4) * mv;
		local cs1 = cos(rt * 12.6) * mv;
		local sn2 = sin(rt * 4.2)
		local sz3 = cos(rt * 8.4) * cos(rt * 12.6) * .079
		local cs2 = abs(cos(rt * 4.2))
		local ب = sin(rt * 25.2) * cos(rt * 6.3)*(3*mv)
		pos1, ang1 = Plutonic.Framework.RotateAroundPoint(
			pos, 
			ang, 
			Vector(-9, -2, -3), 
			Vector(-0, sn1 * -.39 + (sn2*-1.2*mv), sz3 * mv - (mv*.5)), 
			Angle((cs2 * 2.75 * mv) + (cs2 * -3.39 * mv), sn2 * -5.2 * mv, ب)
		);
	end


	local interp = math.ease.InOutQuart(self.VMSprint);
	
	pos, ang = lerpVector(interp, pos1, pos0), lerpAngle(interp, ang1, ang0);

	if self:IsSprinting() then
		--ang:RotateAroundAxis(ang:Right(), sin(rt * 25.2) * mv  *-.3 )
	else
		ang:RotateAroundAxis(ang:Forward(), cos(rt * 16.8) * mv * .1)
	end

	return pos, ang;
end

-- THINK FOR WALL LEANING OUT
function SWEP:DoWallLeanThink()

	-- how far to left
	local left = 0
	-- how far to right
	local right = 0

	-- trace to left
	local tr = util.TraceLine({
		start = self.Owner:GetPos(),
		endpos = self.Owner:GetPos() + self.Owner:GetRight() * -32 + self.Owner:GetForward() * 12 + Vector(0, 0, 48),
		filter = self.Owner
	})
	-- if we hit something
	if tr.Hit then
		-- add to left
		left = left + 1
	end

	-- trace to right
	local tr = util.TraceLine({
		start = self.Owner:EyePos(),
		endpos = self.Owner:EyePos() + self.Owner:GetRight() * 32+ self.Owner:GetForward() * 12 + Vector(0, 0, 48),
		filter = self.Owner
	})

	-- if we hit something
	if tr.Hit then
		-- add to right
		right = right + 1
	end
	--self.VMWallLean = Lerp(FrameTime() * 6.4, self.VMWallLean or 0, left - right)
end

function SWEP:ViewmodelThink()
	local flip = Plutonic.Framework.GetControl_Bool( "vm_flip_lefty", true )
	self.ViewModelFlip = flip
end

function SWEP:GetViewModelPosition(pos, ang)

	if self.PreGetViewModelPosition then
		pos, ang = self:PreGetViewModelPosition(pos, ang)
	end

	local start_pos = pos + Vector()
	local start_ang = ang + Angle(0,0,0)
	local ironsightPos = self.IronsightsPos
	local ironsightAng = self.IronsightsAng

	self.centeredMode = self.centeredMode or GetConVar("plutonic_centered")

	if self.centeredMode and self.centeredMode:GetBool() then

		self.VMCenter = self.VMCenter or 0

		if !self:GetIronsights() then
			self.VMCenter = Lerp(FrameTime() * 4, self.VMCenter, 1)
		else
			self.VMCenter = Lerp(FrameTime() * 4, self.VMCenter, 0)
		end

		local cpos, cang = self.CenteredPos * self.VMCenter, self.CenteredAng * self.VMCenter

		pos = pos + (cpos.y * ang:Forward())
		pos = pos + (cpos.x * ang:Right())
		pos = pos + (cpos.z * ang:Up())
		
		ang:RotateAroundAxis(ang:Right(), cang.p)
		ang:RotateAroundAxis(ang:Up(), cang.y)
		ang:RotateAroundAxis(ang:Forward(), cang.r)
	end

	local ft = Frametime()
	local fet = Frametime() * .1
	local ft3 = ft * 3
	local ft8 = ft * 8
	local ct = Curtime()
	local rt = Realtime()
	local ovel = self.Owner:GetVelocity()
	local move = vec(ovel.x, ovel.y, 0)
	local movement = move:LengthSqr()
	local movepercent = clamp(movement / self.Owner:GetRunSpeed() ^ 2, 0, 1)
	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)
	local changeX = self.VMDeltaX + 0
	
	local isIronsights = self:GetIronsights()
	self.VMSwayIronTransform = self.VMSwayIronTransform or 0
	self.VMSwayIronTransform = approach(self.VMSwayIronTransform, isIronsights and 1 or 0.1, ft * 2)
	local brl = self.BarrelLength * 1

	--local xsa = 1 - clamp(abs(Curtime()-self.VMDeltaXT) * .7, 0, 1)
	local xva =self.VMDeltaX --(math.ease.InElastic(xsa)) * self.VMDeltaX

	--self.xsa = xsa
	--self.xva = xva

	pos, ang = self:DoIronsights(pos, ang)
	pos, ang = self:DoSprint(pos, ang)
	local swayXv = -(xva * .25)
	
	local swayXa = -(xva)* 1

	

	local swayY = self.VMDeltaY * .25
	if isIronsights then
		rd = rd / 2
	end
	self.VMRoll = lerp(ft * 3, self.VMRoll, rd * movepercent)
	local degRoll = deg(self.VMRoll) / 3
	degRoll = degRoll + ((self.VMWallLean or 0) * 24.4)
	local degPitch = lerp( math.ease.OutQuint(min(abs(degRoll / 8 ),1)), 0, cos(math.rad(degRoll * 2)))

	local flip = Plutonic.Framework.GetControl_Bool( "vm_flip_lefty", false ) 
	if flip then
		swayXv = swayXv * -1
		swayXa = swayXa * -1
		degRoll = degRoll * -1
	end
	
	local att = self:GetAttachment(self:LookupAttachment(self.MuzzleFlashAttachment or "muzzle"))
	local xsn
	if att then
		att.Pos = att.Pos - (att.Ang:Forward() * brl)
		xsn = self:WorldToLocal(att.Pos)
	else
		xsn = Vector(0,0,0)
	end

	local oxc = (self.c_oxc or 0) * 8
	local oxq = (self.c_oxq or 0) * 8
	local oyq = self.c_oyq or 0
	local offsetPos = Vector(
		--[[FORWARD]] 0,
		--[[RIGHT]]   oxc * -.8 - oxq * 1- degRoll  *.0625,--oxq * -.05,
		--[[UP]]      oyq * .25 - abs(degRoll)  *.0925 + (abs(oxq) * -.1 + abs(oxc) * .07)--oyq * -.05
	)

	local s0 = (sin(rt * 25.2) * self.VMDeltaXWeighted * .1)
	local s1 = (cos(rt * 8.4) * self.VMDeltaXWeighted * .2)
	local x0 = lerp(abs(self.VMDeltaXWeighted / 12) * abs(self.VMDeltaXWeighted), s1, s0)

	local offsetAng = Angle(
		-oyq  + degPitch,
		(oxq)-(oxc * 2.164),
		(oxq*-2.4) - degRoll + (oxc * 1.1)
	)

	local yofof = lerp(self.VMIronsights, -3, 0)

	pos, ang = Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		Vector(9, -2.5, yofof), 
		offsetPos,
		offsetAng
	)

	

	self.PointOrigin = xsn
	
	
	

	
	pos, ang = self:DoCrouch(pos, ang)
	pos, ang = self:DoBlocked(pos, ang)
	
	pos, ang = self:DoIdle(pos, ang)
	if self.ViewModelOffsetAng then
		local offsetang = self.ViewModelOffsetAng
		ang:RotateAroundAxis(ang:Right(), offsetang.p)
		ang:RotateAroundAxis(ang:Up(), offsetang.y)
		ang:RotateAroundAxis(ang:Forward(), offsetang.r)
	end
	if self.ViewModelOffset then
		local offset = self.ViewModelOffset
		pos = pos + (ang:Right() * offset.x)
		pos = pos + (ang:Forward() * offset.y)
		pos = pos + (ang:Up() * offset.z)
	end

	ang:RotateAroundAxis(ang:Right(), self.VMRecoilAng.p)
	ang:RotateAroundAxis(ang:Up(), self.VMRecoilAng.y)
	ang:RotateAroundAxis(ang:Forward(), self.VMRecoilAng.r)
	
	pos = pos + (ang:Right() * self.VMRecoilPos.x)
	pos = pos + (ang:Forward() * self.VMRecoilPos.y)
	pos = pos + (ang:Up() * self.VMRecoilPos.z)
	self.VMRecoilPos = lerpVector(ft * 2, self.VMRecoilPos, Vector(0, 0, 0))
	self.VMRecoilAng = lerpAngle(ft * 2, self.VMRecoilAng, Angle(0, 0, 0))

	local att2 = self:GetAttachment(self:LookupAttachment(self.MuzzleFlashAttachment or "muzzle"))

	pos, ang = Plutonic.Framework.RotateAroundPoint(
		LocalToWorld(Vector(), Angle(), pos, ang),
		ang, 
		Vector(), 
		Vector(0, 0, 0), 
		-LocalPlayer():GetViewPunchAngles() - Angle(0, 0, 0)
	)

	local att = self:GetAttachment(self:LookupAttachment(self.MuzzleFlashAttachment or "muzzle"))
	local xsn
	if att then
		att.Pos = att.Pos - (att.Ang:Forward() * brl)
		xsn = self:WorldToLocal(att.Pos)
	else
		xsn = Vector(0,0,0)
	end
	self.PointOrigin = xsn

	pos, ang = self:DoWalkBob(pos, ang)

	return pos, ang
end

Plutonic.GetViewModelPosition = SWEP.GetViewModelPosition
Plutonic.DoIronSights = SWEP.DoIronSights
Plutonic.DoWallLeanThink = SWEP.DoWallLeanThink
Plutonic.DoSprint = SWEP.DoSprint
Plutonic.DoCrouch = SWEP.DoCrouch
Plutonic.DoBlocked = SWEP.DoBlocked
Plutonic.DoIdle = SWEP.DoIdle
Plutonic.DoWalkBob = SWEP.DoWalkBob
Plutonic.DoIronsights = SWEP.DoIronsights
Plutonic.PostRender = SWEP.PostRender

local aimdot = Material("models/weapons/tfa_ins2/optics/po4x_reticule")
local aimdot2 = Material("models/weapons/tfa_ins2/optics/aimpoint_reticule_sc")
local bl = Material("pp/blurscreen")
function SWEP:DrawHoloSight(vm_pos, vm_ang, att)
	print("[Plutonic] DrawHoloSight is deprecated!")
end
Plutonic.Hooks.Add("PostDrawPlayerHands", function()
end)
function SWEP:ProceduralRecoil(force)
	self.lastshot = CurTime()
	if self:GetIronsights() then force = force * 0.08 end
	force = force 
	local rPos = self.BlowbackPos + Vector()
	local rAng = self.BlowbackAngle + Angle()
	local pitchKnock = math.Rand(1.1, 3.2) * force
	rAng:RotateAroundAxis(rAng:Right(), -pitchKnock )
	rPos = rPos - (rAng:Up() * (pitchKnock / 2))
	local yawKnock = math.Rand(-0.6, 0.6) * force
	rAng:RotateAroundAxis(rAng:Up(), yawKnock )
	rPos = rPos + (rAng:Right() * (yawKnock / 2))
	local rollKnock = math.Rand(-2, 2) * force
	rAng:RotateAroundAxis(rAng:Forward(), rollKnock )
	rPos = rPos + (rAng:Right() * (rollKnock / 2))
	rPos = rPos - (rAng:Forward() * (math.Rand(4,6)) ) * force
	self.VMRecoil = (self.VMRecoil or Vector()) + (rPos)
	self.VMRecoilAng = (self.VMRecoilAng or Angle()) + (rAng)
	self.VMRecoilAmt =  (force * (self:GetIronsights() and 1 or .01))
	self.VMRecoilSeed = math.Rand(1000000, 9999999)
end

SWEP.CAM_ReloadAlp = 0
SWEP.CAM_ReloadAct = 0

function SWEP:CalcView(ply, pos, ang, fov)

	if ( !Plutonic.Framework.GetControl_Bool("use_anim_cam", true) ) then
		return
	end

	if self:GetReloading() then
		local vm = self.Owner:GetViewModel()
		local n_ang = nil

		
		-- aim
		if not self.GetReloadAnimation then

			local aim = vm:GetAttachment(self.ReloadAttach or 2)
			if aim then
				n_ang = (aim.Pos - pos):Angle()
			end
		else
			n_ang = self:GetReloadAnimation(pos, ang, self.CAM_ReloadAlp)
		end

		self.CAM_ReloadAlp = Lerp(Frametime(), self.CAM_ReloadAlp, self.ReloadProceduralCameraFrac or .1)

		return pos, lerpAngle(self.CAM_ReloadAlp * ((vm:SequenceDuration() - (Curtime() - self.CAM_ReloadAct))/vm:SequenceDuration()), ang, n_ang), fov

		
	else
		
		self.CAM_ReloadAlp =0
		self.CAM_ReloadAct = Curtime()

		return pos, ang, fov
	end
end