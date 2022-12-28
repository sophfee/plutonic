--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --
-- **IN DEVELOPMENT** --

-- SWEP Customizable Values
SWEP.CustomEvents = SWEP.CustomEvents or {}
SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAngle = Angle(0, 0, 0)
SWEP.SwayRightMultiplier = 3.0 -- 3 is a good baseline.
SWEP.SwayUpMultiplier = 3.0 -- 3 is a good baseline.
SWEP.SwayLevel = 0.3
SWEP.SwayBob = 1.0
SWEP.SwayIdle = 0.5

LS2_DebugRoll = CreateClientConVar("ls2_debugroll", "0", true, false)

-- quad bezier lerp from roblox ez dub
function Longsword.Lerp(a, b, c)
	return a + (b - a) * c
end

function Longsword.BezierCurve(t, p0, p1, p2)
	local l1 = Longsword.Lerp(p0, p1, t)
	local l2 = Longsword.Lerp(p1, p2, t)
	local quad = Longsword.Lerp(l1, l2, t)
	return quad
end

function Longsword.VectorBezierCurve(t, v0, v1, v2)
	return Vector(Longsword.BezierCurve(t, v0.x, v1.x, v2.x), Longsword.BezierCurve(t, v0.y, v1.y, v2.y), Longsword.BezierCurve(t, v0.z, v1.z, v2.z))
end

function Longsword.AngleBezierCurve(t, a0, a1, a2)
	return Angle(Longsword.BezierCurve(t, a0.p, a1.p, a2.p), Longsword.BezierCurve(t, a0.y, a1.y, a2.y), Longsword.BezierCurve(t, a0.r, a1.r, a2.r))
end


SWEP.IronsightsLerp = 0

local rtx =
	GetRenderTargetEx(
	"ls2_rt",
	512,
	512,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_NONE,
	0,
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
		["$phongexponent"] = 100,
		["$phongboost"] = 1,
		["$phongfresnelranges"] = "[0 0.5 1]",
		["$phongalbedotint"] = "[1 1 1]",
		["$phongtint"] = "[1 1 1]"
	}
)

-- Cleaning this up (nick)
function SWEP:GetOffset()
	if self:GetReloading() then
		return
	end

	if self.LoweredPos and self:IsSprinting() then
		return self.LoweredPos, self.LoweredAng
	end
end

SWEP.VMOffsetPos = Vector(0, 0, 0)
SWEP.VMOffsetAng = Angle(0, 0, 0)

function SWEP:OffsetThink()
	local offset_pos, offset_ang, no_lerp = self:GetOffset()
	--[[local offset_base = (self.Owner:GetVelocity():LengthSqr() > 97.5^2)
	
	if offset_base and not offset_pos then
		offset_pos = vector_origin - Vector(0,0,0.5)
	end ]]
	if not offset_pos then
		local centered = GetConVar("longsword_centered")
		local isCentered = centered:GetBool()
		local x = self.IronsightsPos.x
		offset_pos = isCentered and Vector(x, vector_origin.y, vector_origin.z - 2) or vector_origin
	end
	if not offset_ang then
		local centered = GetConVar("longsword_centered")
		local isCentered = centered:GetBool()
		offset_ang = isCentered and self.IronsightsAng or angle_zero
	end

	if self.ViewModelOffset then
		offset_pos = offset_pos + self.ViewModelOffset
	end

	if self.ViewModelOffsetAng then
		offset_ang = offset_ang + self.ViewModelOffsetAng
	end

	self.VMOffsetPos = LerpVector(FrameTime() * (8), self.VMOffsetPos, offset_pos)
	self.VMOffsetAng = LerpAngle(FrameTime() * (8), self.VMOffsetAng, offset_ang)
end

function SWEP:PlayAnim(act)
	if self.CustomEvents[act] then
		act = self.CustomEvents[act]
	end

	local vmodel = self.Owner:GetViewModel()
	local seq = vmodel:SelectWeightedSequence(act)

	vmodel:SendViewModelMatchingSequence(seq)
end

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

local mat = Material("models/weapons/tfa_ins2/optics/aimpoint_lense")
mat:SetTexture("$basetexture", rtx:GetName())
mat:SetInt("$translucent", 1)
mat:SetInt("$additive", 1)
mat:Recompute()

function SWEP:ViewModelDrawn()
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

		self.VMRenderTarget:SetTexture("$basetexture", rtx)
		if not self.VMInitRT3 then
			self.VMInitRT3 = true
			local m = mat:GetMatrix("$basetexturetransform")
			m:SetScale(Vector(-1, 1, 0))
			mat:SetMatrix("$basetexturetransform", m)
			mat:SetVector("$envmaptint", Vector(0, 0, 0))
			mat:Recompute()
		end

	--att:SetSubMaterial(1, "models/weapons/tfa_ins2/optics/aimpoint_reticule_holo")
		att:SetSubMaterial(1, "")
	--att:GetSubMaterial()

		self:DrawHoloSight(pos, ang, att)
	end
end

local lastAng = Angle(0, 0, 0)
local swayAng = Angle()
local cacheAng = Angle(0, 0, 0)
local c_jump = 0
local c_look = 0
local c_move = 0
local c_sight = 0

local function LerpC(t, a, b, powa)
	return a + (b - a) * math.pow(t, powa)
end

-- General math caching
local abs,
	min,
	max,
	clamp,
	sin,
	cos,
	rad,
	deg,
	pi,
	pi2,
	round,
	Curtime,
	Frametime,
	Realtime,
	vec,
	ang,
	lerp,
	lerpAngle,
	lerpVector,
	approach =

	math.abs,
	math.min,
	math.max,
	math.Clamp,
	math.sin,
	math.cos,
	math.rad,
	math.deg,
	math.pi,
	math.pi * 2,
	math.Round,
	CurTime,
	FrameTime,
	RealTime,
	Vector,
	Angle,
	Lerp,
	LerpAngle,
	LerpVector,
	math.Approach

-- General easings
local easeInOutQuad, easeOutElastic, easeInOutQuint = math.ease.InOutQuad, math.ease.OutElastic, math.ease.InOutQuint

SWEP.VMDeltaX = 0
SWEP.VMDeltaY = 0

SWEP.VMStillXFor = 0

SWEP.VMRoll = 0

SWEP.VMSwayX = 0
SWEP.VMSwayY = 0

SWEP.VMRecoilPos = Vector(0, 0, 0)
SWEP.VMRecoilAng = Angle(0, 0, 0)

SWEP.VMRattle = false
SWEP.VMRattleVelocity = 0
SWEP.VMRattlePos = Vector(0, 0, 0)
SWEP.VMRattleAng = Angle(0, 0, 0)

SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Angle(0, 0, 0)

SWEP.VMPos_Target = Vector(0, 0, 0)
SWEP.VMAng_Target = Angle(0, 0, 0)

SWEP.VMOffsetPos = Vector(0, 0, 0)
SWEP.VMOffsetAng = Angle(0, 0, 0)
SWEP.VMLastSprintSound = 0
SWEP.VMLastWalkSound = 0

SWEP.VMCrouchDelta = 0

hook.Add(
	"StartCommand",
	"Longsword2.StartCommand",
	function(ply, ucmd)
		if ply.GetActiveWeapon then
			local wep = ply:GetActiveWeapon()

			if IsValid(wep) then
				if wep.IsLongsword then
					if wep:GetIronsights() then
						local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()

						if abs(x) > 0 or abs(y) > 0 then
							wep.LastInput = CurTime()

							wep.VMSwayX = wep.VMSwayX + ucmd:GetMouseX() * 0.01

							if wep.VMSwayX > 0 then
								wep.VMSwayX = min(wep.VMSwayX, wep.VMDeltaX) + x * 0.01
							else
								wep.VMSwayX = max(wep.VMSwayX, wep.VMDeltaX) + x * 0.01
							end

							wep.VMSwayY = wep.VMSwayY + ucmd:GetMouseY() * 0.01

							if wep.VMSwayY > 0 then
								wep.VMSwayY = min(wep.VMSwayY, wep.VMDeltaY) + y * 0.01
							else
								wep.VMSwayY = max(wep.VMSwayY, wep.VMDeltaY) + y * 0.01
							end
						end
					else
						local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()

						if abs(x) > 0 or abs(y) > 0 then
							wep.LastInput = CurTime()

							wep.VMSwayX = wep.VMSwayX + ucmd:GetMouseX() * 0.04

							if wep.VMSwayX > 0 then
								wep.VMSwayX = min(wep.VMSwayX, wep.VMDeltaX) + x * 0.04
							else
								wep.VMSwayX = max(wep.VMSwayX, wep.VMDeltaX) + x * 0.04
							end

							wep.VMSwayY = wep.VMSwayY + ucmd:GetMouseY() * 0.04

							if wep.VMSwayY > 0 then
								wep.VMSwayY = min(wep.VMSwayY, wep.VMDeltaY) + y * 0.04
							else
								wep.VMSwayY = max(wep.VMSwayY, wep.VMDeltaY) + y * 0.04
							end
						end
					end
				end
			end
		end
	end
)

local walk_pos_in = {
	Vector(-0.1, -0.1, -0.4)
}
local walk_pos_out = {
	Vector(0.4, 0, -0.1)
}

local walk_ang_in = {
	Angle(0, -4, 4)
}

local walk_ang_out = {
	Angle(2, -2, 2)
}

SWEP.VMWalkBobInCyclePos = walk_pos_in[1]
SWEP.VMWalkBobInCycleAng = walk_ang_in[1]
SWEP.VMWalkBobOutCyclePos = walk_pos_out[1]
SWEP.VMWalkBobOutCycleAng = walk_ang_out[1]
SWEP.VMLastMoved = 0

SWEP.Primary.FirePower = 1 -- This controls our VM recoil procedural animation

sound.Add(
	{
		name = "Longsword2.Sprint",
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
		name = "Longsword2.Walk",
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

local vBobIn = Vector(1.26, -0.267, -2.5)
local vBobMid = Vector(-0.3, -.4, 0.94)
local vBobOut = Vector(-1.2126, -0.2, -2.5 )

local aBobIn = Angle(2, 2, -4)
local aBobMid = Angle(-1.2, -2, 1)
local aBobOut = Angle(3, -3.4, 4)

function Longsword.IsMoving()
	return LocalPlayer():GetVelocity():Length2DSqr() > 40^2
end

LS_BOB_STATE_IN = 0
LS_BOB_STATE_MID = 1
LS_BOB_STATE_OUT = 2

local lerpSpeed = 1

function Longsword.Bob(self, pos, ang)

	local rt = Realtime()

	self.VMBobCycle = self.VMBobCycle or 0
	self.VMBobState = self.VMBobState or LS_BOB_STATE_IN
	self.VMBobInCyclePos = self.VMBobInCyclePos or vBobIn
	self.VMBobOutCyclePos = self.VMBobOutCyclePos or vBobOut

	if Longsword.IsMoving() then
		self.VMBobCycle = lerp(Frametime() * 3, self.VMBobCycle, 1)
	else
		self.VMBobCycle = lerp(Frametime() * 3, self.VMBobCycle, 0)
	end

	local mul = self:IsSprinting() and 1.7 or 1
	local l = self:IsSprinting() and 1 or 0
	lerpSpeed = lerp(Frametime() * 3, lerpSpeed, l)

	local alpha2 = sin(rt * 8.4 * 1.7 ) * self.VMBobCycle
	local alpha = sin(rt * 8.4 * 1 ) * self.VMBobCycle

	alpha = lerp(lerpSpeed, alpha, alpha2)
	alpha = (alpha / 3) + 0.5

	local bob = Longsword.VectorBezierCurve(alpha, vBobIn, vBobMid, vBobOut)
	local abob = Longsword.AngleBezierCurve(alpha, aBobIn, aBobMid, aBobOut)

	-- add a slight roll to the weapon
	--ang:RotateAroundAxis(ang:Forward(), alpha * -3)
	

	if self:GetIronsights() then
		bob = bob * (1 -self.VMIronsights)
		abob = abob * (1 -self.VMIronsights)
	end

	pos = pos + ang:Right() * bob.x * self.VMBobCycle
	pos = pos + ang:Forward() * bob.y * self.VMBobCycle
	pos = pos + ang:Up() * bob.z * self.VMBobCycle

	ang:RotateAroundAxis(ang:Right(), abob.p * self.VMBobCycle)
	ang:RotateAroundAxis(ang:Forward(), abob.r * self.VMBobCycle)
	ang:RotateAroundAxis(ang:Up(), abob.y * self.VMBobCycle)

	return pos, ang

end

function Longsword.VMCrouch(self, pos, ang)

	self.VMCrouch = self.VMCrouch or 0

	local isIronsights = self:GetIronsights()

	if self.Owner:KeyDown(IN_DUCK) and not isIronsights then
		self.VMCrouch = lerp(Frametime() * 0.8, self.VMCrouch, 1)
	else
		self.VMCrouch = lerp(Frametime() * 0.8, self.VMCrouch, 0)
	end

	local alpha = math.ease.InOutElastic(self.VMCrouch)

	pos = pos + ang:Up() * -1.4 * alpha
	pos = pos + ang:Right() * -2.7 * alpha
	pos = pos + ang:Forward() * -1.5 * alpha

	ang:RotateAroundAxis(ang:Forward(), -12 * alpha)

	return pos, ang

end

-- For when you look right at the wall
function Longsword.VMBlocked(self, pos, ang)

	if self.Owner != LocalPlayer() then return pos, ang end

	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 32,
		filter = self.Owner
	})

	self.VMBlocked = self.VMBlocked or 0

	if tr.Hit then
		self.VMBlocked = lerp(Frametime() * 2, self.VMBlocked, tr.Fraction)
	else
		self.VMBlocked = lerp(Frametime() * 1.5, self.VMBlocked, 1)
	end

	pos = pos + ang:Forward() * (1 - self.VMBlocked) * -12
	ang:RotateAroundAxis(ang:Forward(), (1 - self.VMBlocked) * -11)
	pos = pos + ang:Right() * (1 - self.VMBlocked) * -2


	return pos, ang
end

function Longsword.VMIronsights(self, pos, ang)

	self.VMIronsights = self.VMIronsights or 0
	self.VMRattle = self.VMRattle or 0
	
	local dir = false
	
	if self:GetIronsights() then
		dir = true
		self.VMIronsights = lerp(Frametime() * 3.5, self.VMIronsights, 1)
		self.VMRattle = lerp(Frametime() * 0.75, self.VMRattle, 0)
	else
		self.VMIronsights = lerp(Frametime() * .5, self.VMIronsights, 0)
		self.VMRattle =  1
	end

	local alpha = math.ease.InBack(self.VMIronsights)

	local ironsightPos = self.IronsightsPos
	local ironsightAng = self.IronsightsAng

	pos = pos + ang:Up() * ironsightPos.z * alpha
	pos = pos + ang:Right() * ironsightPos.x * alpha
	pos = pos + ang:Forward() * ironsightPos.y * alpha

	ang:RotateAroundAxis(ang:Right(), ironsightAng.p * alpha)
	ang:RotateAroundAxis(ang:Up(), ironsightAng.y * alpha)
	ang:RotateAroundAxis(ang:Forward(), ironsightAng.r * alpha)

	-- a little lift in the middle of the animation
	local rt = Realtime()
	ang:RotateAroundAxis(ang:Right(), abs(sin( (alpha) * (math.pi) )) * 4 )
	pos = pos + ang:Up() * abs(sin( (alpha) * (math.pi) )) * -.7
	

	if dir then
		local rattle = math.ease.InOutElastic(self.VMRattle)
		
		--ang:RotateAroundAxis(ang:Right(), sin(rt*8)* rattle)
		--ang:RotateAroundAxis(ang:Up(), cos(rt*8) * rattle)
		--ang:RotateAroundAxis(ang:Forward(), cos(rt*16) * rattle)

	end
	return pos, ang
end

function SWEP:GetViewModelPosition(pos, ang)

	-- START BY VISUALIZING THE MODEL IN THE CENTER!
	-- This is the default position of the viewmodel, so we can use it as a reference point
	-- to calculate the new position and angles

	local start_pos, start_ang = pos + Vector(0,0,0), ang + Angle(0,0,0)

	local ironsightPos = self.IronsightsPos
	local ironsightAng = self.IronsightsAng
	ang:RotateAroundAxis(ang:Right(), ironsightAng.p)
	ang:RotateAroundAxis(ang:Up(), -ironsightAng.y)
	ang:RotateAroundAxis(ang:Forward(), ironsightAng.r)
	
	pos = pos + (start_ang:Forward() * ironsightPos.y)
	pos = pos + (start_ang:Right() * (ironsightPos.x))
	pos = pos + (start_ang:Up() * ironsightPos.z)
	pos = pos + (start_ang:Up() * -1.5)
	pos = pos + (start_ang:Forward() * 5)

	--offset`

	self.VMDeltaX = self.VMDeltaX or 0
	self.VMDeltaY = self.VMDeltaY or 0
	self.VMRoll = self.VMRoll or 0
	self.VMSwayX = self.VMSwayX or 0
	self.VMSwayY = self.VMSwayY or 0
	self.LastInput = self.LastInput or Curtime()

	local ft = Frametime()
	local ft8 = ft * 8
	local ct = Curtime()
	local rt = Realtime()

	local ovel = self.Owner:GetVelocity()
	local move = vec(ovel.x, ovel.y, 0)
	local movement = move:LengthSqr()
	local movepercent = clamp(movement / self.Owner:GetRunSpeed() ^ 2, 0, 1)

	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)
	local fd = (self.Owner:GetForward():Dot(vel) + 1) / 2
	local onGround = self.Owner:OnGround()

	local isIronsights = self:GetIronsights()

	-- [[ SWAY ]] --

	local dt = clamp(abs((ct - self.LastInput) / 1.8), 0, 1)

	local elt = (1 - easeOutElastic(dt))

	

	self.VMDeltaX = lerp(ft8, self.VMDeltaX, self.VMSwayX * elt)
	self.VMDeltaY = lerp(ft8, self.VMDeltaY, self.VMSwayY * elt)

	self.VMDeltaX = clamp(self.VMDeltaX, -16, 16)
	self.VMDeltaY = clamp(self.VMDeltaY, -16, 16)

	-- Perform VM Rotations and shit
	ang:RotateAroundAxis(ang:Up(), self.VMDeltaX)
	ang:RotateAroundAxis(ang:Right(), self.VMDeltaY)

	-- Offset the viewmodel
	pos = pos + (ang:Right() * (self.VMDeltaX / (pi * 1.7)))
	pos = pos + (ang:Up() * -(self.VMDeltaY / (pi * 1.7)))

	-- Roll
	--local move = clamp(len / self.Owner:GetRunSpeed(), 0, 1)

	-- Reduce roll when ironsights
	if isIronsights then
		rd = rd / 2
	end
	if isIronsights then
		movement = movement * 0.2
	end

	local sRoll = 0
	self.VMRoll = lerp(ft * 3, self.VMRoll, rd * movepercent + sRoll)

	local degRoll = deg(sin(self.VMRoll * pi)) / 4

	ang:RotateAroundAxis(ang:Forward(), degRoll)

	-- Offset the viewmodel
	--pos = pos + (ang:Right() * (degRoll / 14))
	-- rolling to the left requires a different offset
	
	--pos = pos + (ang:Up() * (degRoll / 40))
	--pos = pos + (ang:Up() * (degRoll / 40))

	-- [[ END SWAY ]] --

	-- [[ BOBBING ]] --

	pos, ang = Longsword.Bob(self, pos, ang)

	local vel = self.Owner:GetVelocity()
	local len = vel:Length()

	c_move = lerp(ft8, c_move or 0, onGround and movepercent or 0)
	--pos = pos + ang:Forward() * c_move  * fd - ang:Up() * .75 * c_move + ang:Right() * .5 * c_move
	local p = c_move * c_sight * 1
	local move = clamp(len / self.Owner:GetRunSpeed(), 0, 1)

	if isIronsights then
		move = move * 0.2
	end

	pos, ang = Longsword.VMCrouch(self, pos, ang)
	-- We lerp all positions to avoid jittering

	--if self:GetIronsights() then

	-- ** DEBUG CODE ** --
	
	-- ROLLING PERFECTLY
	--pos = pos + (ang:Right() * -sin(dbg_roll/-8))
	--pos = pos + (ang:Up() * -sin(dbg_roll/-8))
	--pos = pos + (ang:Up() * sin(dbg_roll/8))

	-- Calculate offsets (real)

	pos, ang = Longsword.VMBlocked(self, pos, ang)

	pos, ang = Longsword.VMIronsights(self, pos, ang)

	-- REVERSE THE RELATIVITY!
	
	ang:RotateAroundAxis(ang:Right(), -ironsightAng.p)
	ang:RotateAroundAxis(ang:Up(), ironsightAng.y)
	ang:RotateAroundAxis(ang:Forward(), -ironsightAng.r)
	
	pos = pos + (start_ang:Forward() * -ironsightPos.y)
	pos = pos + (start_ang:Right() * -ironsightPos.x)
	pos = pos + (start_ang:Up() * -ironsightPos.z)
	pos = pos + (start_ang:Up() *1.5)
	pos = pos + (start_ang:Forward() * -5)
	
	if self.VMOffsetAng then
		local offsetang = self.VMOffsetAng
		ang:RotateAroundAxis(ang:Right(), offsetang.p)
		ang:RotateAroundAxis(ang:Up(), offsetang.y)
		ang:RotateAroundAxis(ang:Forward(), offsetang.r)
	end
	if self.VMOffsetPos then
		local offset = self.VMOffsetPos
		pos = pos + (ang:Right() * offset.x)
		pos = pos + (ang:Forward() * offset.y)
		pos = pos + (ang:Up() * offset.z)
	end

	self.VMPos = pos
	self.VMAng = ang

	self.VMPos = self.VMPos + (self.VMAng:Right() * self.VMRecoilPos.x)
	self.VMPos = self.VMPos + (self.VMAng:Forward() * self.VMRecoilPos.y)
	self.VMPos = self.VMPos + (self.VMAng:Up() * self.VMRecoilPos.z)

	self.VMAng:RotateAroundAxis(self.VMAng:Right(), self.VMRecoilAng.p)
	self.VMAng:RotateAroundAxis(self.VMAng:Up(), self.VMRecoilAng.y)
	self.VMAng:RotateAroundAxis(self.VMAng:Forward(), self.VMRecoilAng.r)

	self.VMRecoilPos = lerpVector(ft * 6, self.VMRecoilPos, Vector(0, 0, 0))
	self.VMRecoilAng = lerpAngle(ft * 6, self.VMRecoilAng, Angle(0, 0, 0))

	-- Recoil is last so it's overriding all

	return self.VMPos, self.VMAng
end

local aimdot = Material("models/weapons/tfa_ins2/optics/po4x_reticule")
local aimdot2 = Material("models/weapons/tfa_ins2/optics/aimpoint_reticule_sc")
local bl = Material("pp/blurscreen")

function SWEP:DrawHoloSight(vm_pos, vm_ang, att)
	local pos = vm_pos
	local ang = vm_ang

	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 0)

	pos = pos + ang:Right() * 0.5
	pos = pos + ang:Up() * 0.5
	pos = pos + ang:Forward() * 0.5

	render.UpdateScreenEffectTexture()
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_REPLACE)
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)

	render.SetBlend(0)
	render.OverrideDepthEnable(true, true)

	render.SetStencilReferenceValue(32)

	att:DrawModel()

	--render.SetStencilReferenceValue(0)

	render.OverrideDepthEnable(false)

	render.SetBlend(1)

	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetColorModulation(1, 1, 1, 255)
	render.SetMaterial(aimdot)
	local pos = att:GetPos()
	pos = pos + (att:GetAngles():Forward() * 1)
	pos = pos + (att:GetAngles():Up() * 1.4)

	local fpos = pos + (att:GetAngles():Forward() * 36)

	local sc = pos:ToScreen()

	--render.SetStencilReferenceValue(54)

	--render.SetStencilCompareFunction(STENCIL_ALWAYS)

	--render.SetBlend(0)

	render.SetMaterial(aimdot)
	local rangle = att:GetAngles()
	rangle:RotateAroundAxis(rangle:Up(), 180)
	render.DrawQuadEasy(pos + rangle:Up() * 24, rangle:Right(), 4, 1, color_white, 0)
	--draw.NoTexture()
	--render.DrawSphere(pos , 32, 50, 50, Color(255, 255, 255, 255))

	--
	render.SetBlend(1)

	render.SetStencilReferenceValue(32)
	--render.DrawScreenQuad()
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilCompareFunction(STENCIL_GREATER)

	render.SetStencilReferenceValue(0)
	render.SetStencilEnable(false)
	render.ClearStencil()

	render.UpdateFullScreenDepthTexture()

	render.UpdateFullScreenDepthTexture()
	--render.DrawTextureToScreen(bl:GetTexture("$basetexture"))
end

hook.Add(
	"RenderScene",
	"Longsword2.RenderScene",
	function(pos, ang)
		if LocalPlayer():Alive() and LocalPlayer():GetActiveWeapon():IsValid() then
			local wep = LocalPlayer():GetActiveWeapon()
			if wep.IsLongsword then
				if wep:GetAttachmentBehavior() != "holosight" then
					return
				end
				if wep:GetIronsights() then
					for i = 1, 4 do
						bl:SetFloat("$blur", (i / 10) * 20)
						bl:Recompute()
						--render.SetStencilReferenceValue(32 - i)
						render.SetMaterial(bl)
						render.DrawScreenQuad()
					end
				end
				local att = wep.AttachedCosmetic
				local pos = att:GetPos()
				pos = pos + (att:GetAngles():Forward() * 1)
				pos = pos + (att:GetAngles():Up() * 1.4)

				local fpos = pos + (att:GetAngles():Forward() * 36)

				render.PushRenderTarget(rtx, 0, 0, 512, 512)

				render.ClearRenderTarget(rtx, Color(0, 0, 0, 255))
				--if self:GetIronsights() then
				--render.PushRenderTarget(rtx)
				--render.BlurRenderTarget(rtx, ScrW(), ScrH(), 3)
				local pang = att:GetAngles()
				-- render.PopRenderTarget()
				render.RenderView(
					{
						origin = pos,
						angles = pang,
						x = 0,
						y = 0,
						w = 512,
						h = 512,
						drawviewmodel = false,
						fov = 14.6
					}
				)

				--cam.Start2D()
				--render.SetStencilReferenceValue(32)
				pang:RotateAroundAxis(pang:Up(), 180)

				fpos = fpos + (pang:Right() * wep.VMDeltaX)
				fpos = fpos + (pang:Up() * wep.VMDeltaY)

				cam.Start3D()

				render.SetMaterial(aimdot)
				render.UpdatePowerOfTwoTexture()

				render.DrawQuadEasy(fpos, pang:Forward(), 14, 14, Color(255, 255, 255, 255), 180)

				render.SetMaterial(aimdot2)
				render.DrawQuadEasy(fpos, pang:Forward(), 16 * 3.4, 9 * 3.4, Color(255, 255, 255, 255), 180)
				cam.End3D()

				--render.SetMaterial(aimdot)
				--render.DrawTextureToScreen(aimdot:GetTexture("$basetexture"))

				--end

				render.PopRenderTarget()
			end
		end
	end
)

-- Landing effect
hook.Add(
	"OnPlayerHitGround",
	"Longsword2.PlayerLanding",
	function(ply, _, __, speed)
		if ply:Alive() and ply:GetActiveWeapon():IsValid() then
			local wep = ply:GetActiveWeapon()
			if wep.IsLongsword then
				wep.LastInput = CurTime()
				wep.VMSwayY = speed / 30
				wep.VMSwayX = math.random(-1, 1) * speed / 50
			end
		end
	end
)

function SWEP:LS_ProceduralRecoil(force)

	if self:GetIronsights() then
		force = force / 4
	end
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