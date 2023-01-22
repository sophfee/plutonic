--      Copyright (c) 2022-2023, Nick S. All rights reserved      --
-- Plutonic is a project built for Landis Games. --
SWEP.CustomEvents = SWEP.CustomEvents or {}
SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAngle = Angle(0, 0, 0)

local rtx =
	GetRenderTargetEx(
	"ls2_rt",
	512,
	512,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_SHARED,
	65536,
	CREATERENDERTARGETFLAGS_HDR,
	IMAGE_FORMAT_DEFAULT
)

SWEP.VMRenderTarget =
	CreateMaterial(
	"ls2_sight_rt",
	"UnlitGeneric",
	{
		["$model"] = 1,
		["$basetexture"] = rtx:GetName(),
		["$phong"] = 1,
		["$phongexponent"] = 2,
		["$phongboost"] = 1,
		["$phongfresnelranges"] = "[0 0.5 1]",
		["$phongalbedotint"] = "[1 1 1]",
		["$phongtint"] = "[1 1 1]",
		["$ignorez"] = 1,
		["$transparent"] = 1
	}
)
function SWEP:GetOffset()
end

SWEP.VMOffsetPos = Vector(0, 0, 0)
SWEP.VMOffsetAng = Angle(0, 0, 0)

function SWEP:OffsetThink()
end

function SWEP:PlayAnim(act)
	if self.CustomEvents[act] then
		act = self.CustomEvents[act]
	end

	local vmodel = self.Owner:GetViewModel()
	local seq = vmodel:SelectWeightedSequence(act)

	vmodel:SendViewModelMatchingSequence(seq)
end
local dofmat = Material("pp/dof")
local grad = Material("vgui/gradient-d")
function SWEP:PreDrawViewModel(vm)
	if CLIENT and self.CustomMaterial and not self.CustomMatSetup then
		self.Owner:GetViewModel():SetMaterial(self.CustomMaterial)
		self.CustomMatSetup = true
	end

	self:OffsetThink()

	

	if self.scopedIn then
		return self.scopedIn
	end
end

local mat = Material("!ls2_sight_rt")
mat:SetTexture("$basetexture", rtx:GetName())
mat:SetInt("$translucent", 1)
mat:Recompute()

function SWEP:ViewModelDrawn()
	if Plutonic.Framework.Overdraw then return end

	local vm = self.Owner:GetViewModel()

	if not IsValid(vm) then
		return
	end

	local attachment = self:GetCurAttachment()

	if not self.Attachments or not self.Attachments[attachment] or not self.Attachments[attachment].Cosmetic then
		return
	end

	local attData = self.Attachments[attachment]

	if attData.PlayerParent then
		vm = self.Owner
	end

	if not IsValid(self.AttachedCosmetic) then
		self.AttachedCosmetic = ClientsideModel(attData.Cosmetic.Model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
		self.AttachedCosmetic:SetParent(vm)
		self.AttachedCosmetic:SetNoDraw(true)
		self.AttachedCosmetic:AddEffects(EF_BONEMERGE)

		if attData.Cosmetic.Scale then
			self.AttachedCosmetic:SetModelScale(attData.Cosmetic.Scale)
		end
	end

	local att = self.AttachedCosmetic
	local c = attData.Cosmetic
	local bone = vm:LookupBone(c.Bone)

	if not bone then
		return
	end

	local m = vm:GetBoneMatrix(bone)

	local pos, ang = m:GetTranslation(), m:GetAngles()

	att:SetPos(pos + ang:Forward() * c.Pos.x + ang:Right() * c.Pos.y + ang:Up() * c.Pos.z)
	ang:RotateAroundAxis(ang:Up(), c.Ang.y)
	ang:RotateAroundAxis(ang:Right(), c.Ang.p)
	ang:RotateAroundAxis(ang:Forward(), c.Ang.r)
	att:SetAngles(ang)
	att:DrawModel()
	if self:GetAttachmentBehavior() == "holosight" then
		-- Deprecated until at least 1.12.1
	end
end
function SWEP:PostDrawViewModel(vm, ply, wep)
end
SWEP.BarrelLength = 6
local function LerpC(t, a, b, powa)
	return a + (b - a) * math.pow(t, powa)
end
local abs,min,max,clamp,sin,cos,rad,deg,pi,pi2,round,Curtime,Frametime,Realtime,vec,ang,lerp,lerpAngle,lerpVector,approach=math.abs,math.min,math.max,math.Clamp,math.sin,math.cos,math.rad,math.deg,math.pi,math.pi * 2,math.Round,CurTime,FrameTime,RealTime,Vector,Angle,Lerp,LerpAngle,LerpVector,math.Approach
local easeInOutQuad, easeOutElastic, easeInOutQuint = math.ease.InOutQuad, math.ease.OutElastic, math.ease.InOutQuint
SWEP.VMDeltaX = 0
SWEP.VMDeltaY = 0
SWEP.VMRoll = 0
SWEP.VMRecoilPos = Vector(0, 0, 0)
SWEP.VMRecoilAng = Angle(0, 0, 0)
SWEP.VMOffsetPos = Vector(0, 0, 0)
SWEP.VMOffsetAng = Angle(0, 0, 0)
SWEP.Primary.FirePower = 1
sound.Add(
	{
		name = "Plutonic.Sprint",
		channel = CHAN_AUTO,
		volume = 0.7,
		level = 45,
		pitch = {95, 110},
		sound = {
			"weapons/movement/weapon_movement_sprint1.wav",
			"weapons/movement/weapon_movement_sprint2.wav",
			"weapons/movement/weapon_movement_sprint3.wav",
			"weapons/movement/weapon_movement_sprint4.wav",
			"weapons/movement/weapon_movement_sprint5.wav",
			"weapons/movement/weapon_movement_sprint6.wav",
			"weapons/movement/weapon_movement_sprint7.wav",
			"weapons/movement/weapon_movement_sprint8.wav",
			"weapons/movement/weapon_movement_sprint9.wav"
		}
	}
)
sound.Add(
	{
		name = "Plutonic.Walk",
		channel = CHAN_AUTO,
		volume = 0.2,
		level = 45,
		pitch = {95, 110},
		sound = {
			"weapons/movement/weapon_movement_walk1.wav",
			"weapons/movement/weapon_movement_walk2.wav",
			"weapons/movement/weapon_movement_walk3.wav",
			"weapons/movement/weapon_movement_walk4.wav",
			"weapons/movement/weapon_movement_walk5.wav",
			"weapons/movement/weapon_movement_walk6.wav",
			"weapons/movement/weapon_movement_walk7.wav",
			"weapons/movement/weapon_movement_walk8.wav",
			"weapons/movement/weapon_movement_walk9.wav"
		}
	}
)
SWEP.vBobIn = Vector(1.26, -0.267, -0.1) * .5
SWEP.vBobMid = Vector(-0.3, -.4, -3.94) * .5
SWEP.vBobOut = Vector(-1.2126, -0.2, -0.1 ) * .5
SWEP.aBobIn = Angle(2, -1, -4) * .5
SWEP.aBobMid = Angle(-1.2, 0.7, 1) * .5
SWEP.aBobOut = Angle(3, 1.4, 4) * .5
function Plutonic.Framework.IsMoving()
	return LocalPlayer():GetVelocity():Length2DSqr() > 40^2
end
SWEP.CrouchPos = Vector(-1.5, -2.7, -1.4)
SWEP.CrouchAng = Angle(0, 0, -12)
function Plutonic.Framework.ViewModelCrouch(self, pos, ang)
	self.VMCrouch = self.VMCrouch or 0
	local alpha = math.ease.InOutQuad(self.VMCrouch)
	pos = pos + ang:Right() * self.CrouchPos.x * alpha
	pos = pos + ang:Forward() * self.CrouchPos.y * alpha
	pos = pos + ang:Up() * self.CrouchPos.z * alpha
	ang:RotateAroundAxis(ang:Right(), self.CrouchAng.p * alpha)
	ang:RotateAroundAxis(ang:Forward(), self.CrouchAng.r * alpha)
	ang:RotateAroundAxis(ang:Up(), self.CrouchAng.y * alpha)
	return pos, ang
end
function Plutonic.Framework.ViewModelBlocked(self, pos, ang)
	if self.Owner != LocalPlayer() then return pos, ang end
	self.VMBlocked = self.VMBlocked or 1
	pos = pos + ang:Forward() * (1 - self.VMBlocked) * -12
	ang:RotateAroundAxis(ang:Forward(), (1 - self.VMBlocked) * -11)
	pos = pos + ang:Right() * (1 - self.VMBlocked) * -2
	return pos, ang
end
SWEP.IronsightsMiddlePos = Vector(-8,-7,-7)
SWEP.IronsightsMiddleAng = Angle(12, -18, 48)
function Plutonic.Framework.ViewModelIronsights(self, pos, ang)
	self.VMIronsights = self.VMIronsights or 0
	self.VMRattle = self.VMRattle or 0
	local dir = false
	if self:GetIronsights() then
		dir = true
	end
	local alpha = dir and math.ease.OutExpo( self.VMIronsights ) or math.ease.InSine( self.VMIronsights )
	local ironsightPos = Plutonic.Interpolation.VectorBezierCurve( alpha, Vector(), self.IronsightsMiddlePos, self.IronsightsPos)
	local ironsightAng = Plutonic.Interpolation.AngleBezierCurve( alpha, Angle(), self.IronsightsMiddleAng, self.IronsightsAng)
	pos = pos + ang:Up() * ironsightPos.z * alpha
	pos = pos + ang:Right() * ironsightPos.x * alpha
	pos = pos + ang:Forward() * ironsightPos.y * alpha
	ang:RotateAroundAxis(ang:Right(), ironsightAng.p * alpha)
	ang:RotateAroundAxis(ang:Up(), ironsightAng.y * alpha)
	ang:RotateAroundAxis(ang:Forward(), ironsightAng.r * alpha)
	return pos, ang
end
function Plutonic.Framework.ViewModelIdle(self, pos, ang)
	self.VMIdle = self.VMIdle or 0
	if self:GetIronsights() then
		return pos, ang
	end
	local rt = Realtime()
	local alpha = math.ease.InBack(abs(sin(rt * .4)))
	ang:RotateAroundAxis(ang:Right(), alpha * .5)
	ang:RotateAroundAxis(ang:Up(), sin(alpha * math.pi * 2) * -.2)
	pos = pos + ang:Up() * alpha * -.175
	pos = pos + ang:Right() * alpha * .07
	pos = pos + ang:Forward() * sin(rt*.3) * -.4
	pos = pos + ang:Right() * sin(rt * -.9) * -.3
	pos = pos + ang:Up() * cos(rt * 1.17) * .2^2
	ang:RotateAroundAxis(ang:Right(), sin(rt * 2.67) * .23)
	ang:RotateAroundAxis(ang:Up(), cos(rt * .87) * .23)
	ang:RotateAroundAxis(ang:Forward(), cos(rt * .97) * 3.23)
	self.VMVel = self.VMVel or 0
	ang:RotateAroundAxis(ang:Forward(), self.VMVel * 1.5)
	pos = pos + ang:Right() * self.VMVel * .125
	local uvel = min(self.VMVel / pi, 12)
	ang:RotateAroundAxis(ang:Right(), uvel * 2.5)
	pos = pos + ang:Up() * uvel * -1.25
	return pos, ang
end
SWEP.LoweredMidPos = Vector(4,-3,-3)
SWEP.LoweredMidAng = Angle(-6,7,5)
function Plutonic.Framework.ViewModelSprint(self, pos, ang)
	if self.CustomSprint then return self:CustomSprint(pos, ang) end
	if not self.LoweredPos then return pos, ang end
	local t = math.ease.InOutQuad(self.VMSprint or 0)
	local loweredPos = Plutonic.Interpolation.VectorBezierCurve( t, Vector(), self.LoweredMidPos, self.LoweredPos)
	local loweredAng = Plutonic.Interpolation.AngleBezierCurve( t, Angle(), self.LoweredMidAng, self.LoweredAng)
	ang:RotateAroundAxis(ang:Right(), loweredAng.p)
	ang:RotateAroundAxis(ang:Up(), loweredAng.y)
	ang:RotateAroundAxis(ang:Forward(), loweredAng.r)
	pos = pos + ang:Up() * loweredPos.z
	pos = pos + ang:Right() * loweredPos.x
	pos = pos + ang:Forward() * loweredPos.y
	return pos, ang
end
function SWEP:ViewmodelThink()
	if not IsFirstTimePredicted() then return end
	self.VMSprint = approach(self.VMSprint or 0, self:IsSprinting() and 1 or 0, FrameTime() * 1.6)
	self.VMIronsights = approach(self.VMIronsights or 0, self:GetIronsights() and 1 or 0, FrameTime() * 2.4 )
	self.VMIronsights = self.VMIronsights or 0
	self.VMIronsightsFinishRattle = self.VMIronsightsFinishRattle or 0
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
	self.VMBobCycle = approach(self.VMBobCycle, Plutonic.Framework.IsMoving() and 1 or 0, Frametime() * 9)
	local mul = self:IsSprinting() and 1.7 or 1
	local l = self:IsSprinting() and 1 or 0
	lerpSpeed = lerp(Frametime() * 5, lerpSpeed, l)
	local onvel = self.Owner:GetVelocity()
	local uvel = onvel.z
	local vel = clamp((uvel) / 80, -34, 34)
	self.VMVel = self.VMVel or 0
	self.VMVel = Lerp(Frametime() * 5, self.VMVel, vel)
end
function SWEP:GetViewModelPosition(pos, ang)
	local start_pos = pos + Vector()
	local start_ang = ang + Angle(0,0,0)
	local ironsightPos = self.IronsightsPos
	local ironsightAng = self.IronsightsAng
	ang:RotateAroundAxis(ang:Right(), ironsightAng.p)
	ang:RotateAroundAxis(ang:Up(), -ironsightAng.y)
	ang:RotateAroundAxis(ang:Forward(), ironsightAng.r)
	pos = pos + (start_ang:Forward() * ironsightPos.y)
	pos = pos + (start_ang:Right() * (ironsightPos.x))
	pos = pos + (start_ang:Up() * ironsightPos.z)
	pos = pos + (start_ang:Up() * -1.5)
	pos = pos + (start_ang:Forward() * self.BarrelLength)
	self.VMDeltaX = self.VMDeltaX or 0
	self.VMDeltaY = self.VMDeltaY or 0
	self.VMRoll = self.VMRoll or 0
	self.VMSwayX = self.VMSwayX or 0
	self.VMSwayY = self.VMSwayY or 0
	self.VMWiggly = self.VMWiggly or 0
	self.LastInput = self.LastInput or Curtime()
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
	self.VMDeltaX = lerp(ft * 4, self.VMDeltaX, 0)
	self.VMDeltaY = lerp(ft * 4, self.VMDeltaY, 0)
	self.VMDeltaX = clamp(self.VMDeltaX, -16,16)
	self.VMDeltaY = clamp(self.VMDeltaY, -16, 16)
	local isIronsights = self:GetIronsights()
	self.VMSwayIronTransform = self.VMSwayIronTransform or 0
	self.VMSwayIronTransform = approach(self.VMSwayIronTransform, isIronsights and 1 or 0.1, ft * 2)
	local brl = self.VMSwayIronTransform * self.BarrelLength
	local swayX = self.VMDeltaX * .25
	local swayY = self.VMDeltaY * .25
	if isIronsights then
		rd = rd / 2
	end
	self.VMRoll = lerp(ft * 3, self.VMRoll, rd * movepercent)
	local degRoll = deg(sin(self.VMRoll * pi)) / 4
	pos, ang = Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		Vector(brl, 0, 0), 
		Vector(0, -swayX, -swayY), 
		Angle(self.VMDeltaY, -self.VMDeltaX , -degRoll)
	)
	pos, ang = Plutonic.Framework.ViewModelIronsights(self, pos, ang)
	pos, ang = Plutonic.Framework.ViewModelBob(self, pos, ang)
	pos, ang = Plutonic.Framework.ViewModelCrouch(self, pos, ang)
	pos, ang = Plutonic.Framework.ViewModelBlocked(self, pos, ang)
	pos, ang = Plutonic.Framework.ViewModelSprint(self, pos, ang)
	pos, ang = Plutonic.Framework.ViewModelIdle(self, pos, ang)
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
	ang:RotateAroundAxis(ang:Right(), -ironsightAng.p)
	ang:RotateAroundAxis(ang:Up(), ironsightAng.y)
	ang:RotateAroundAxis(ang:Forward(), -ironsightAng.r)
	pos = pos + (start_ang:Forward() * -ironsightPos.y)
	pos = pos + (start_ang:Right() * -ironsightPos.x)
	pos = pos + (start_ang:Up() * -ironsightPos.z)
	pos = pos + (start_ang:Up() *1.5)
	pos = pos + (start_ang:Forward() * -self.BarrelLength)
	ang:RotateAroundAxis(ang:Right(), self.VMRecoilAng.p)
	ang:RotateAroundAxis(ang:Up(), self.VMRecoilAng.y)
	ang:RotateAroundAxis(ang:Forward(), self.VMRecoilAng.r)
	pos = pos + (ang:Right() * self.VMRecoilPos.x)
	pos = pos + (ang:Forward() * self.VMRecoilPos.y)
	pos = pos + (ang:Up() * self.VMRecoilPos.z)
	self.VMRecoilPos = lerpVector(ft * 6, self.VMRecoilPos, Vector(0, 0, 0))
	self.VMRecoilAng = lerpAngle(ft * 6, self.VMRecoilAng, Angle(0, 0, 0))
	return pos, ang
end
local aimdot = Material("models/weapons/tfa_ins2/optics/po4x_reticule")
local aimdot2 = Material("models/weapons/tfa_ins2/optics/aimpoint_reticule_sc")
local bl = Material("pp/blurscreen")
function SWEP:DrawHoloSight(vm_pos, vm_ang, att)
	print("[Plutonic] DrawHoloSight is deprecated!")
end
Plutonic.Hooks.Add("PostDrawPlayerHands", function()
	if LocalPlayer():Alive() and LocalPlayer():GetActiveWeapon():IsValid() then
		local wep = LocalPlayer():GetActiveWeapon()
		if wep.IsPlutonic then
			if wep.VMIronsights < 0.1 then
				return
			end
			render.UpdateRefractTexture()
			DrawToyTown(4 * wep.VMIronsights, ScrH()*.47)
		end
	end
end)
function SWEP:ProceduralRecoil(force)
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
end