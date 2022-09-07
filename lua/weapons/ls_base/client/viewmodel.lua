--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

-- SWEP Customizable Values
SWEP.CustomEvents        = SWEP.CustomEvents or {}
SWEP.ViewModelPos        = Vector( 0, 0, 0 )
SWEP.ViewModelAngle      = Angle( 0, 0, 0 )
SWEP.SwayRightMultiplier = 3.0 -- 3 is a good baseline.
SWEP.SwayUpMultiplier    = 3.0 -- 3 is a good baseline.
SWEP.SwayLevel           = 0.3
SWEP.SwayBob             = 1.0
SWEP.SwayIdle            = 0.5

-- quad bezier lerp from roblox ez dub
local function rbxLerp(a,b,c)
	return a + (b - a) * c
end

local function quadBezier(t, p0, p1, p2)
	local l1 = rbxLerp(p0, p1, t)
	local l2 = rbxLerp(p1, p2, t)
	local quad = rbxLerp(l1, l2, t)
	return quad
end

local function vecBezier(t,v0,v1,v2)
	return Vector(quadBezier(t,v0.x,v1.x,v2.x),quadBezier(t,v0.y,v1.y,v2.y),quadBezier(t,v0.z,v1.z,v2.z))
end

SWEP.IronsightsLerp = 0

-- Cleaning this up (nick)
function SWEP:GetOffset()
	if self:GetReloading() then return end

	if self.LoweredPos and self:IsSprinting() then
		return self.LoweredPos, self.LoweredAng
	end

	local centered = GetConVar("longsword_centered")
	local isCentered = centered:GetBool()
	local is_pos =self.IronsightsPos
	local v1 = isCentered and Vector(is_pos.x,0,-2) or Vector(0,0,0)
	local v2 = Vector(is_pos.x*1.2,is_pos.y*0.8,is_pos.x*0.8)
	--local v3 = Vector(is_pos.x*1.2,is_pos.y/1.125,is_pos.z/1.125)
	local ironsights_pos = vecBezier(quadBezier(self.IronsightsLerp,0,0.4,1),v1,v2,is_pos)

	if self:GetIronsights() then
		local offset_pos =  LerpVector(self:GetIronsightsRecoil(),Vector(),VectorRand(-0.06,0.06))
		self.IronsightsLerp = math.Approach(self.IronsightsLerp, 1, FrameTime()*self.IronsightsSpeed)
		return ironsights_pos + LerpVector(self:GetIronsightsRecoil(),Vector(),self.BlowbackPos) + (offset_pos or Vector()), self.IronsightsAng + LerpAngle(self:GetIronsightsRecoil(),Angle(),self.BlowbackAngle or Angle()) + Angle(0,0,(1-self.IronsightsLerp)*-self.IronsightsRocking)
	else
		self.IronsightsLerp = math.Approach(self.IronsightsLerp, 0, FrameTime()*self.IronsightsSpeed)
	end
	if self.IronsightsLerp > 0 then
		return ironsights_pos, Angle(0,0,self.IronsightsLerp*self.IronsightsRocking)
	end
end

SWEP.ViewModelPos = Vector( 0, 0, 0 )
SWEP.ViewModelAngle = Angle( 0, 0, 0 )

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
		offset_pos = isCentered and Vector(x,vector_origin.y,vector_origin.z-2) or vector_origin 
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

	self.ViewModelPos = LerpVector(FrameTime() * (11 * (self.IronsightsSpeed/4)), self.ViewModelPos, offset_pos)
	self.ViewModelAngle = LerpAngle(FrameTime() * (11 * (self.IronsightsSpeed/4)), self.ViewModelAngle, offset_ang)
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
end

local lastAng  = Angle(0, 0, 0)
local swayAng  = Angle()
local cacheAng = Angle(0, 0, 0)
local c_jump   = 0
local c_look   = 0
local c_move   = 0
local c_sight  = 0

function SWEP:GetViewModelPosition( pos, ang )
	
	local sway = self.SwayLevel or 1.0
	local bob  = self.SwayBob   or 1.0
	local idle = self.SwayIdle  or 0.5

	ang:RotateAroundAxis( ang:Right(),   self.ViewModelAngle.p )
	ang:RotateAroundAxis( ang:Up(),      self.ViewModelAngle.y )
	ang:RotateAroundAxis( ang:Forward(), self.ViewModelAngle.r )

	pos = pos + self.ViewModelPos.x * ang:Right()
	pos = pos + self.ViewModelPos.y * ang:Forward()
	pos = pos + self.ViewModelPos.z * ang:Up()

	local predicted = IsFirstTimePredicted()
	local ft        = FrameTime()
	local ct        = RealTime()

	-- camera move lag, based on QTG weapon base
	local aDelta = self.Owner:EyeAngles() - lastAng

	if aDelta.y >= 180 then
		aDelta.y = aDelta.y - 360
	elseif aDelta.y <= -180 then
		aDelta.y = aDelta.y + 360
	end

	aDelta.p = math.Clamp(aDelta.p, -5, 5)
	aDelta.y = math.Clamp(aDelta.y, -5, 5)
	aDelta.r = math.Clamp(aDelta.r, -5, 5)

	if self:GetIronsights() or self:GetReloading() then
		aDelta = aDelta * 0.1
	end

	if predicted then
		cacheAng = LerpAngle(math.Clamp(ft * 10, 0, 1), cacheAng, aDelta)
	end

	swayAng = LerpAngle(FrameTime()*100,swayAng,self.Owner:EyeAngles())
	
	lastAng = self.Owner:EyeAngles()
	swayAng = swayAng + Angle(lastAng.p/2,lastAng.y/2,lastAng.r/2)

	local psway = sway / (self.SwayFactor or 6)
	ang:RotateAroundAxis(ang:Right(), - cacheAng.p * sway)
	ang:RotateAroundAxis(ang:Up(), cacheAng.y * sway)
	ang:RotateAroundAxis(ang:Forward(), cacheAng.y * sway)
	pos = pos + (ang:Right()*self.SwayRightMultiplier) * cacheAng.y * psway + (ang:Up()*self.SwayUpMultiplier)* cacheAng.p * psway

	-- player movement and wep movement, based on QTG weapon base cuz i dont like maths
	local ovel = self.Owner:GetVelocity()
	local move = Vector(ovel.x, ovel.y, 0)
	local movement = move:LengthSqr()
	local movepercent = math.Clamp(movement / self.Owner:GetRunSpeed() ^ 2, 0, 1)

	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)
	local fd = (self.Owner:GetForward():Dot(vel) + 1) / 2

	if predicted then
		local ft8 = math.min(ft * 8, 1)
		local onGround = self.Owner:OnGround()

		if self:GetIronsights() then
			movepercent = movepercent * 0.32
		end

		local c_move2 = movepercent
		c_move = Lerp(ft8, c_move or 0, onGround and movepercent or 0)
		c_sight = Lerp(ft8, c_sight or 0, self:GetIronsights() and onGround and not self:GetReloading() and not self:IsSprinting() and 0.1 or 1)

		local jump = self:GetIronsights() and math.Clamp(ovel.z / 120, -0.25, 0.5) or 0
		c_jump = Lerp(ft8, c_jump or 0, (self.Owner:GetMoveType() == MOVETYPE_NOCLIP or self:GetIronsights()) and jump or math.Clamp(ovel.z / 120, -1.5, 1))

		if rd > 0.5 then
			c_look = Lerp(math.Clamp(ft * 5, 0, 1), c_look, 20 * c_move2)
		elseif rd < -0.5 then
			c_look = Lerp(math.Clamp(ft * 5, 0, 1), c_look, -20 * c_move2)
		else
			c_look = Lerp(math.Clamp(ft * 5, 0, 1), c_look, 0)
		end
	end

	pos = pos + ang:Up() * .75 * c_jump
	ang.p = ang.p + (c_jump or 0) * 3
	ang.r = ang.r + c_look

	if bob != 0 and c_move > 0 then
		local p = c_move * c_sight * bob

		pos = pos + ang:Forward() * c_move * c_sight * fd - ang:Up() * .75 * c_move + ang:Right() * .5 * c_move * c_sight
		ang.y = ang.y - math.sin(ct * 8.4) * 1.7 * p
		ang.p = ang.p - math.sin(ct * 16.8) * 0.8 * p
		ang.r = ang.r - math.cos(ct * 8.4) * 0.3 * p
	end

	if idle != 0 then
		local p = (1 - c_move) * c_sight * idle

		ang.p = ang.p - math.sin(ct * 0.5) * p
		ang.y = ang.y - math.sin(ct) * 0.5 * p
		ang.r = ang.r - math.sin(ct) * 0.5 * p
	end

	return pos, ang
end
