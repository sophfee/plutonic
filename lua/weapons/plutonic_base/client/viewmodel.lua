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

	--[[if self.lastshot then
		if (math.abs(self.lastshot - CurTime()) < .06 ) then
			
			local alpha = 1 - ((CurTime() - self.lastshot) / 3)
			if not self.heatedbarrel then
				chat.AddText("racism is funny")
				self.heatedbarrel = ProjectedTexture()
				self.heatedbarrel:SetTexture("effects/flashlight001")
				self.heatedbarrel:SetFarZ(256)
				self.heatedbarrel:SetFOV(140)
				self.heatedbarrel:SetBrightness(2)
				self.heatedbarrel:SetColor(self.MuzzleFlashColor or Color(244, 209, 66))
				self.heatedbarrel:SetEnableShadows(true)
				self.heatedbarrel:SetNearZ(1)
				self.heatedbarrel:SetPos(vm:LocalToWorld(self.PointOrigin + Vector(4, 0, 0)))
				self.heatedbarrel:SetAngles(self.Owner:EyeAngles())
				self.heatedbarrel:Update()

			else
				self.heatedbarrel:SetTexture("effects/flashlight001")
				self.heatedbarrel:SetFarZ(256)
				self.heatedbarrel:SetFOV(140)
				self.heatedbarrel:SetBrightness(0)
				self.heatedbarrel:SetColor(self.MuzzleFlashColor or Color(244, 209, 66))
				self.heatedbarrel:SetEnableShadows(true)
				self.heatedbarrel:SetNearZ(1)
				local attchhhhgf = vm:GetAttachment(1)
				self.heatedbarrel:SetPos(attchhhhgf.Pos)
				self.heatedbarrel:SetAngles(attchhhhgf.Ang)
				self.heatedbarrel:Update()
			end
			
		else
			if self.heatedbarrel then
				self.heatedbarrel:Remove()
				self.heatedbarrel = nil
			end
		end
	end

	if self.lastshot then
		if ( true ) then
			
			local alpha = 1 - ((CurTime() - self.lastshot) / 3)
			if not self.TexGunLight then
				self.TexGunLight = ProjectedTexture()
				self.TexGunLight:SetTexture("effects/flashlight001")
				self.TexGunLight:SetFarZ(2048)
				self.TexGunLight:SetFOV(60)
				self.TexGunLight:SetBrightness(2)
				self.TexGunLight:SetColor(color_white)
				self.TexGunLight:SetTargetEntity(vm)
				self.TexGunLight:SetEnableShadows(true)
				self.TexGunLight:SetNearZ(1)
				--self.TexGunLight:SetPos()
				self.TexGunLight:SetAngles(self.Owner:EyeAngles())
				self.TexGunLight:Update()

			else
				self.TexGunLight:SetTexture("effects/flashlight001")
				self.TexGunLight:SetColor(Color(151, 174, 217))
				self.TexGunLight:SetEnableShadows(true)
				self.TexGunLight:SetTargetEntity(nil)
				self.TexGunLight:SetShadowFilter(0)
				self.TexGunLight:SetNearZ(1)
				local attchhhhgf = vm:GetAttachment(1)
				self.TexGunLight:SetPos(attchhhhgf.Pos)
				self.TexGunLight:SetAngles(attchhhhgf.Ang)
				self.TexGunLight:Update()
			end
			
		else
			if self.TexGunLight then
				self.TexGunLight:Remove()
				self.TexGunLight = nil
			end
		end
	end]]

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
local abs,min,max,clamp,sin,cos,rad,deg,pi,pi2,round,Curtime,Frametime,Realtime,vec,ang,lerp,lerpAngle,lerpVector,approach=math.abs,math.min,math.max,math.Clamp,math.sin,math.cos,math.rad,math.deg,math.pi,math.pi * 2,math.Round,UnPredictedCurTime,RealFrameTime,RealTime,Vector,Angle,Lerp,LerpAngle,LerpVector,math.Approach
local easeInOutQuad, easeOutElastic, easeInOutQuint = math.ease.InOutQuad, math.ease.OutElastic, math.ease.InOutQuint

function SWEP:PostRender()
	self:DoWallLeanThink()
	self.Ironsights = self:GetIronsights()
	
	self.VMSprint = lerp(Frametime() * 4, self.VMSprint or 0, self:IsSprinting() and 1 or 0)
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

	--[[if (abs(self.VMLastDeltaXInFrame or 0) < abs(self.VMDeltaX or 0)) then
		self.VMDeltaXT = Curtime()
	end
	
	self.VMDeltaX = approach(self.VMDeltaX or 0, 0, ft * (isIronsights and 8 or 16))
	self.VMDeltaY = approach(self.VMDeltaY or 0, 0, ft * (isIronsights and 8 or 16))

	self.VMHighestDeltaXUntilRest = max(self.VMHighestDeltaXUntilRest or 0, self.VMDeltaX)
	if round(self.VMDeltaX, 4) == 0 then
		self.VMDeltaXM = self.VMHighestDeltaXUntilRest + 0
		self.VMHighestDeltaXUntilRest = 0
	end

	self.VMLastDeltaXInFrame = self.VMDeltaX + 0
	self.VMLastDeltaYInFrame = self.VMDeltaY + 0]]

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
sound.Add(
	{
		name = "Plutonic.Sprint",
		channel = CHAN_ITEM,
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
		channel = CHAN_ITEM,
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

	return pos, ang --Plutonic.Framework.RotateAroundPoint(pos, ang, Vector(self.BarrelLength, 0, 0), Vector(idle * -1, idle2 * -1, idle * -1), Angle(idle * 1, idle2 * 1, fidget * 1))
end

SWEP.LoweredMidPos = Vector(4,-3,0.4)
SWEP.LoweredMidAng = Angle(-6,7,-5)
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

	return pos, ang
end

SWEP.vBobIn2 = Vector(-1.7, -1.2, 0)
SWEP.vBobMid2 = Vector(0, 0, -4.8 )
SWEP.vBobOut2 = Vector(1.7, -4.2, 0)

SWEP.aBobIn2 = Angle(0, 3, -3)
SWEP.aBobMid2 = Angle(0, 0, 0)
SWEP.aBobOut2 = Angle(0, -3, 3)

SWEP.vBobIn = Vector( 0.2, 2.15, .1) 
SWEP.vBobMid = Vector(  -3.6, 0,-3) 
SWEP.vBobOut = Vector(  0.2, -2.15, .1)
SWEP.aBobIn = Angle(3, -6, 5)
SWEP.aBobMid = Angle(-2.2, 0, -.4)
SWEP.aBobOut = Angle(3, 6, -5)

lerpSpeed = 0
function SWEP:DoWalkBob(pos, ang)
	if self.DoCustomWalkBob then
		return self:DoCustomWalkBob(pos, ang)
	end
	local rt = Realtime()
	self.VMBobCycle = self.VMBobCycle or 0
	local alpha2 = sin(rt * 8.4 * 1.5 ) * (self.VMBobCycle)
	local alpha = sin(rt * 8.4 * 1 ) * self.VMBobCycle
	alpha = lerp(lerpSpeed, alpha, alpha2)
	alpha = (alpha / 3) + 0.5

	local bob = Plutonic.Interpolation.VectorBezierCurve(alpha, self.vBobIn, self.vBobMid, self.vBobOut)
	local abob = Plutonic.Interpolation.AngleBezierCurve(alpha, self.aBobIn, self.aBobMid, self.aBobOut)
	
	if self:GetIronsights() then
		bob = bob * ( self.VMIronsights * .08)
		abob = abob * (self.VMIronsights * .04)
	end

	if not self.LoweredPos then
		bob = bob / lerp(lerpSpeed, 1, 1.6)
		abob = abob / lerp(lerpSpeed, 1, 1.6)
	else
		bob = bob / lerp(lerpSpeed, 1.6, 1)
		abob = abob / lerp(lerpSpeed, 1.6, 1)
	end

	--pos = pos + ang:Right() * bob.x * self.VMBobCycle
	--pos = pos + ang:Forward() * bob.y * self.VMBobCycle
	--pos = pos + ang:Up() * bob.z * self.VMBobCycle
	local ovel = self.Owner:GetVelocity()
	local move = vec(ovel.x, ovel.y, 0)
	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)
	local fd = (self.Owner:GetForward():Dot(vel) + 1) / 2
	--self.VMRDBEF = lerp(Frametime() * 2.9, self.VMRDBEF or 0, vel:Length2DSqr())
	--ang:RotateAroundAxis(ang:Right(), abob.p * (self.VMBobCycle))
	--ang:RotateAroundAxis(ang:Up(), abob.y * self.VMBobCycle)
	--ang:RotateAroundAxis(ang:Forward(), abob.r * self.VMBobCycle)
	local offsetOscilX = 2.6
	local oscilX = -(self.VMRDBEF*2) * cos(rt * 12.6) * (self.Ironsights and .1 or .5)
	local oscilY = -(self.VMRDBEF*2) * sin(rt * 6.3) * (self.Ironsights and .1 or .5)

	local snx  = sin(rt * 8.4)
	local wasneg
	if snx < 0 then
		snx = snx * -1
		wasneg= true
	end
	local oscilZ = (self.VMRDBEF*2) * math.ease.InBack( abs(snx) )
	if wasneg then
		oscilZ = oscilZ * -1
	end

	local xnx  = cos(rt * 8.4)
	local wasneg
	if xnx < 0 then
		xnx = xnx * -1
		wasneg= true
	end
	local oscilX = (self.VMRDBEF*2) * math.ease.InBack( abs(xnx) )
	if wasneg then
		oscilX = oscilX * -1
	end

	bob = LerpVector(self.VMBobCycle, Vector(), bob)
	abob = LerpAngle(self.VMBobCycle, Angle(), abob)

	pos, ang = Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		self.PointOrigin or Vector(0, 0, 0),
		bob + Vector(oscilZ * .15, oscilX* .15 , 0),
		abob
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
	--self.VMWallLean = Lerp(FrameTime() * 6.4, self.VMWallLean or 0, left - right)
end

function SWEP:ViewmodelThink()
	local flip = Plutonic.Framework.GetControl_Bool( "vm_flip_lefty", true )
	self.ViewModelFlip = flip
end

function SWEP:GetViewModelPosition(pos, ang)
	local start_pos = pos + Vector()
	local start_ang = ang + Angle(0,0,0)
	local ironsightPos = self.IronsightsPos
	local ironsightAng = self.IronsightsAng
	--[[ang:RotateAroundAxis(ang:Right(), ironsightAng.p)
	ang:RotateAroundAxis(ang:Up(), -ironsightAng.y)
	ang:RotateAroundAxis(ang:Forward(), ironsightAng.r)
	pos = pos + (start_ang:Forward() * ironsightPos.y)
	pos = pos + (start_ang:Right() * (ironsightPos.x))
	pos = pos + (start_ang:Up() * ironsightPos.z)
	pos = pos + (start_ang:Up() * -1.5)
	pos = pos + (start_ang:Forward() * self.BarrelLength)]]
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
	local brl = self.BarrelLength * 2

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
	pos, ang = Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		xsn, 
		Vector(0, 0, 0), 
		Angle(self.VMDeltaY, swayXa, 0)
	)

	ang:RotateAroundAxis(ang:Forward(), degRoll)

	

	self.PointOrigin = xsn
	
	pos, ang = self:DoWalkBob(pos, ang)

	

	
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
	self.VMRecoilPos = lerpVector(ft * 6, self.VMRecoilPos, Vector(0, 0, 0))
	self.VMRecoilAng = lerpAngle(ft * 6, self.VMRecoilAng, Angle(0, 0, 0))

	pos, ang = Plutonic.Framework.RotateAroundPoint(
		pos, 
		ang, 
		self.PointOrigin, 
		Vector(0, 0, 0), 
		-LocalPlayer():GetViewPunchAngles()
	)

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
			n_ang = self:GetReloadAnimation(pos, ang)
		end

		self.CAM_ReloadAlp = Lerp(Frametime(), self.CAM_ReloadAlp, self.ReloadProceduralCameraFrac or .1)

		return pos, lerpAngle(self.CAM_ReloadAlp * ((vm:SequenceDuration() - (Curtime() - self.CAM_ReloadAct))/vm:SequenceDuration()), ang, n_ang), fov

		
	else
		
		self.CAM_ReloadAlp =0
		self.CAM_ReloadAct = Curtime()

		return pos, ang, fov
	end
end