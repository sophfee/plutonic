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

function SWEP:IsMoving()
	return self:GetOwner():GetVelocity():Length2DSqr() > 40^2
end

function SWEP:IsDucked()
	local isIronsights = self:GetIronsights()
	return ((self.Owner:KeyDown(IN_DUCK) or self.Owner:Crouching()) and not isIronsights)
end

SWEP.CrouchPos = Vector(1.5, -2.7, 1.4)
SWEP.CrouchAng = Angle(0, 0, -12)

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
		Vector(self.BarrelLength, 0, 0),
		self.CrouchPos * -alpha,
		self.CrouchAng * -alpha
	)
end

function SWEP:DoBlocked(pos, ang)
	if self.Owner != LocalPlayer() then return pos, ang end
	self.VMBlocked = self.VMBlocked or 1
	local bl = -(self.VMBlocked - 1)
	return Plutonic.Framework.RotateAroundPoint(pos, ang, Vector(self.BarrelLength, 0, 0), Vector(bl * -11, bl * -1, -bl *7), Angle(bl * 23, bl * -12,bl * 12))
end

SWEP.IronsightsMiddlePos = Vector(-3,-2,-9)
SWEP.IronsightsMiddleAng = Angle(12, -9, -24)

function SWEP:DoIronsights(pos, ang)
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

function SWEP:DoIdle(pos, ang)
	self.VMIdle = self.VMIdle or 0
	if self:GetIronsights() then
		return pos, ang
	end
	local rt = Realtime()
	local idle = sin(rt * 1.03) * 0.1
	local idle2 = cos(rt * .84) * 0.1
	local fidget = sin(rt * 1.03) * cos(rt * .84) * 2


	return Plutonic.Framework.RotateAroundPoint(pos, ang, Vector(self.BarrelLength, 0, 0), Vector(idle * -1, idle2 * -1, idle * -1), Angle(idle * 1, idle2 * 1, fidget * 1))
end

SWEP.LoweredMidPos = Vector(4,-3,-3)
SWEP.LoweredMidAng = Angle(-6,7,5)
function SWEP:ShouldDoSprint()
	return (self.VMSprint and math.Round(self.VMSprint, 4) > 0)
end
function SWEP:DoSprint(pos, ang)
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

	local rt = Realtime()

	local sn0 = sin(rt * 16.8) * t
	local cs0 = cos(rt * 16.8) * t
	local sn1 = sin(rt * 8.4)  * t
	local cs1 = cos(rt * 8.4)  * t

	return pos, ang --[[ Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		Vector(self.BarrelLength, -4, 16),
		Vector(cs0, sn1, 0),
		Angle(cs0 * 1.1, sn1 * 5, 0)
	) ]]
end
lerpSpeed = 0
function SWEP:DoWalkBob(pos, ang)
	if self.DoCustomWalkBob then
		return self:DoCustomWalkBob(pos, ang)
	end
	local rt = Realtime()
	self.VMBobCycle = self.VMBobCycle or 0
	local alpha2 = sin(rt * 8.4 * 1.7 ) * (self.VMBobCycle)
	local alpha = sin(rt * 8.4 * 1 ) * self.VMBobCycle
	alpha = lerp(lerpSpeed, alpha, alpha2)
	alpha = (alpha / 3) + 0.5
	local bob = Plutonic.Interpolation.VectorBezierCurve(alpha, self.vBobIn, self.vBobMid, self.vBobOut)
	local abob = Plutonic.Interpolation.AngleBezierCurve(alpha, self.aBobIn, self.aBobMid, self.aBobOut)
	if self:GetIronsights() then
		bob = bob * ( self.VMIronsights * .08)
		abob = abob * (self.VMIronsights * .04)
	end
	bob = bob / lerp(lerpSpeed, 1, 1.7)
	abob = abob / lerp(lerpSpeed, 1, 1.7)
	pos = pos + ang:Right() * bob.x * self.VMBobCycle
	pos = pos + ang:Forward() * bob.y * self.VMBobCycle
	pos = pos + ang:Up() * bob.z * self.VMBobCycle
	local ovel = self.Owner:GetVelocity()
	local move = vec(ovel.x, ovel.y, 0)
	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)
	local fd = (self.Owner:GetForward():Dot(vel) + 1) / 2
	self.VMRDBEF = lerp(Frametime() * 2.9, self.VMRDBEF or 0, vel:Length2DSqr())
	ang:RotateAroundAxis(ang:Right(), abob.p * (self.VMBobCycle))
	ang:RotateAroundAxis(ang:Up(), abob.y * self.VMBobCycle)
	local offsetOscilX = 2.6
	local oscilX = -(self.VMRDBEF*2) * cos(rt * 12.6) * (self.Ironsights and .125 or .675)
	local oscilY = -(self.VMRDBEF*2) * sin(rt * 6.3) * (self.Ironsights and .125 or .675)
	--local oscilZ = (self.VMRDBEF*2) * sin((rt + 0.4) * 16.8) * (self.Ironsights and .012 or .112)

	--pos = pos + ang:Up() * abs(oscilZ) * self.VMBobCycle

	pos, ang = Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		Vector(self.BarrelLength * 1.3, 0, 0), 
		Vector(0, oscilX * .125, oscilY * -.125), 
		Angle( oscilY, oscilX, 0)
	)
	return pos, ang
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
	self.VMWallLean = Lerp(FrameTime() * 6.4, self.VMWallLean or 0, left - right)
end

function SWEP:ViewmodelThink()
	if not IsFirstTimePredicted() then return end
	self:DoWallLeanThink()
	self.Ironsights = self:GetIronsights()
	
	self.VMSprint = lerp(FrameTime() * 4, self.VMSprint or 0, self:IsSprinting() and 1 or 0)
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
	self.VMBobCycle = approach(self.VMBobCycle, Plutonic.Framework.IsMoving() and 1 or 0, Frametime() * 4)
	local mul = self:IsSprinting() and 1 or 1
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
	local changeX = self.VMDeltaX + 0
	self.VMDeltaX = lerp(ft * 4, self.VMDeltaX, 0)
	self.VMWiggly = lerp(ft * 1.9, self.VMWiggly, 0)
	self.VMDeltaY = lerp(ft * 4, self.VMDeltaY, 0)
	self.VMDeltaX = clamp(self.VMDeltaX, -16,16)
	self.VMDeltaY = clamp(self.VMDeltaY, -16, 16)
	local isIronsights = self:GetIronsights()
	self.VMSwayIronTransform = self.VMSwayIronTransform or 0
	self.VMSwayIronTransform = approach(self.VMSwayIronTransform, isIronsights and 1 or 0.1, ft * 2)
	local brl = self.VMSwayIronTransform * self.BarrelLength

	
	local swayXv = -(self.VMDeltaX * .25) 
	local l_wiggle = 0 -- math.AngleDifference(self.VMWiggly,self.VMDeltaX  ) * .125
	
	local swayXa = -self.VMDeltaX * 1

	local swayY = self.VMDeltaY * .25
	if isIronsights then
		rd = rd / 2
	end
	self.VMRoll = lerp(ft * 3, self.VMRoll, rd * movepercent)
	local degRoll = deg(self.VMRoll) / 3
	degRoll = degRoll + ((self.VMWallLean or 0) * 11.4)

	pos, ang = Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		Vector(brl, 0, 0), 
		Vector(0, swayXv, -swayY), 
		Angle(self.VMDeltaY, swayXa, -degRoll)
	)
	pos, ang = self:DoWalkBob(pos, ang)

	pos, ang = self:DoIronsights(pos, ang)
	
	pos, ang = self:DoCrouch(pos, ang)
	pos, ang = self:DoBlocked(pos, ang)
	pos, ang = self:DoSprint(pos, ang)
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

SWEP.CAM_ReloadAlp = 0
SWEP.CAM_ReloadAct = 0

function SWEP:CalcView(ply, pos, ang, fov)
	if self:GetReloading() then
		local vm = self.Owner:GetViewModel()
		local n_ang = nil

		PrintTable(vm:GetAttachments())
		-- aim
		local aim = vm:GetAttachment(self.ReloadAttach or 2)
		if aim then
			n_ang = (aim.Pos - pos):Angle()
		end

		self.CAM_ReloadAlp = Lerp(Frametime(), self.CAM_ReloadAlp, .1)

		return pos, lerpAngle(self.CAM_ReloadAlp * ((vm:SequenceDuration() - (Curtime() - self.CAM_ReloadAct))/vm:SequenceDuration()), ang, n_ang), fov

		
	else
		
		self.CAM_ReloadAlp =0
		self.CAM_ReloadAct = Curtime()

		return pos, ang, fov
	end
end