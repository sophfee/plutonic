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
		return ironsights_pos + LerpVector(
			self:GetIronsightsRecoil(),
			Vector(),
			self.BlowbackPos
		) + (
			offset_pos or Vector()),
			self.IronsightsAng + LerpAngle(self:GetIronsightsRecoil(),Angle(),self.BlowbackAngle or Angle()) + Angle(0,0,(1-self.IronsightsLerp)*-self.IronsightsRocking)
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

local function LerpC(t, a, b, powa)
    return a + (b - a) * math.pow(t, powa)
end

SWEP.VMDeltaX = 0
SWEP.VMDeltaY = 0

SWEP.VMPos = Vector()
SWEP.VMAng = Angle()

SWEP.VMPos_Target = Vector()
SWEP.VMAng_Target = Angle()

hook.Add("CreateMove", "Longsword2.StartCommand", function(ply, ucmd)

	if ply.GetActiveWeapon then
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) then
			if wep.IsLongsword then
				wep.VMDeltaX = wep.VMDeltaX + ucmd:GetMouseX() * 0.004
				wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * 0.004
			end
		end
	end
	
end)

local pi2 = math.pi * 1.1

function SWEP:GetViewModelPosition( pos, ang )
	local ft = FrameTime()
	local ft8 = ft * 8
	local ct = RealTime()
	local ovel = self.Owner:GetVelocity()
	local move = Vector(ovel.x, ovel.y, 0)
	local movement = move:LengthSqr()
	local movepercent = math.Clamp(movement / self.Owner:GetRunSpeed() ^ 2, 0, 1)

	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)
	local fd = (self.Owner:GetForward():Dot(vel) + 1) / 2

	-- [[ OFFSET ]] --
	pos = pos + (ang:Right() * self.ViewModelOffset.x)
	pos = pos + (ang:Forward() * self.ViewModelOffset.y)
	pos = pos + (ang:Up() * self.ViewModelOffset.z)

	ang:RotateAroundAxis( ang:Right(),   self.ViewModelOffsetAng.p )
	ang:RotateAroundAxis( ang:Up(),      self.ViewModelOffsetAng.y )
	ang:RotateAroundAxis( ang:Forward(), self.ViewModelOffsetAng.r )


	-- [[ SWAY ]] --

	self.VMDeltaX = math.Clamp(self.VMDeltaX, -11, 11)
	self.VMDeltaY = math.Clamp(self.VMDeltaY, -11, 11)

	self.VMDeltaX = Lerp(FrameTime() * pi2, self.VMDeltaX, 0)
	self.VMDeltaY = Lerp(FrameTime() * pi2, self.VMDeltaY, 0)
	
	-- Perform VM Rotations and shit
	ang:RotateAroundAxis(ang:Up(), self.VMDeltaX)
	ang:RotateAroundAxis(ang:Right(), self.VMDeltaY)

	-- Offset the viewmodel
	pos = pos + (ang:Right() * (self.VMDeltaX/6))
	pos = pos + (ang:Up() * -(self.VMDeltaY/6))

	-- [[ END SWAY ]] --

	-- [[ BOBBING ]] --

	local vel = self.Owner:GetVelocity()
	local len = vel:Length()

	pos = pos + (ang:Right() * (len/600) * math.sin(CurTime() * 18))
	pos = pos + (ang:Up() * -(len/600) * math.cos(CurTime() * 18))
	
	c_move = Lerp(ft8, c_move or 0, onGround and movepercent or 0)
	pos = pos + ang:Forward() * c_move * 0 * fd - ang:Up() * .75 * c_move + ang:Right() * .5 * c_move
		ang.y = ang.y - math.sin(ct * 8.4) * 1.7
		ang.p = ang.p - math.sin(ct * 16.8) * 0.8
		ang.r = ang.r - math.cos(ct * 8.4) * 0.3

	-- We lerp all positions to avoid jittering
	
	if self:GetIronsights() then
		pos = pos + self.IronsightsPos.x * ang:Right()
		pos = pos + self.IronsightsPos.y * ang:Forward()
		pos = pos + self.IronsightsPos.z * ang:Up()

		ang:RotateAroundAxis( ang:Right(),   self.IronsightsAng.p )
		ang:RotateAroundAxis( ang:Up(),      self.IronsightsAng.y )
		ang:RotateAroundAxis( ang:Forward(), self.IronsightsAng.r )
	end

	

	self.VMPos_Target = pos

	
	self.VMAng_Target = ang

	self.VMPos = LerpVector(FrameTime(), self.VMPos_Target, self.VMPos)
	self.VMAng = LerpAngle(FrameTime(), self.VMAng_Target, self.VMAng)

	return self.VMPos, self.VMAng
end
