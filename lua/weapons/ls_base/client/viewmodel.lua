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

SWEP.VMOffsetPos = Vector( 0, 0, 0 )
SWEP.VMOffsetAng = Angle( 0, 0, 0 )

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
SWEP.VMRoll = 0

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

hook.Add("StartCommand", "Longsword2.StartCommand", function(ply, ucmd)

	if ply.GetActiveWeapon then
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) then
			if wep.IsLongsword then
				if wep:GetIronsights() then
					local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()

					if math.abs(x) > 0 or math.abs(y) > 0 then
						wep.LastInput = CurTime()
						wep.VMWarbleDirection = x > 0 and 1 or -1
					end
					wep.VMDeltaX = wep.VMDeltaX + ucmd:GetMouseX() * 0.001
					wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * 0.001
				else
					local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()

					if math.abs(x) > 0 or math.abs(y) > 0 then
						wep.LastInput = CurTime()
					end
					wep.VMDeltaX = wep.VMDeltaX + ucmd:GetMouseX() * 0.004
					wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * 0.004
				end
			end
		end
	end
	
end)

local abs = math.abs

local pi2 = math.pi * 1.2

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
	local onGround = self.Owner:OnGround()


	-- [[ SWAY ]] --

	local toffset, toffsetang = self:GetOffset()
	if self.VMOffsetPos then
		--self.VMOffsetPos = LerpVector(ft / 8, self.VMOffsetPos or toffset, toffset)
		local offset = self.VMOffsetPos
		pos = pos + (ang:Right() * offset.x)
		pos = pos + (ang:Forward() * offset.y)
		pos = pos + (ang:Up() * offset.z)
	end

	if self.VMOffsetAng then
		--self.VMOffsetAng = LerpAngle(ft / 8, self.VMOffsetAng or toffsetang, toffsetang)
		local offsetang = self.VMOffsetAng
		ang:RotateAroundAxis( ang:Right(),   offsetang.p )
		ang:RotateAroundAxis( ang:Up(),      offsetang.y )
		ang:RotateAroundAxis( ang:Forward(), offsetang.r )
	end

	-- Rattle
	if self.LastInput < CurTime() then
		-- Reflect the current dir
		if not self.VMRattle then
			self.VMRattleVelocity = self.VMDeltaX / -4
			self.VMRattle = true

			self.VMRattlePos = Vector(0, 0, 0)
			self.VMRattleAng = Angle(0, 0, 0)
		end
		
	end

	local rattle = self.VMRattleVelocity
		

	if abs(rattle) > 0 then
		self.VMRattleVelocity = math.Approach(rattle, 0, ft * 0.5)
			
		self.VMRattlePos = LerpVector(ft, self.VMRattlePos, (ang:Right() * math.sin(-rattle)  * 1))
		self.VMRattleAng = LerpAngle(ft, self.VMRattleAng, Angle(math.sin(-rattle) * 8, 0, 0))

		--ang:RotateAroundAxis(ang:Up(), self.VMRattleAng.p)
		--pos = pos + self.VMRattlePos
	
	else


		self.VMRattle = false
		
	end

	self.VMDeltaX = math.Clamp(self.VMDeltaX, -11, 11)
	self.VMDeltaY = math.Clamp(self.VMDeltaY, -11, 11)

	self.VMDeltaX = Lerp(FrameTime() * pi2, self.VMDeltaX, 0)
	self.VMDeltaY = Lerp(FrameTime() * pi2, self.VMDeltaY, 0)

	
	-- Perform VM Rotations and shit
	ang:RotateAroundAxis(ang:Up(), self.VMDeltaX)
	ang:RotateAroundAxis(ang:Right(), self.VMDeltaY)

	-- Offset the viewmodel
	pos = pos + (ang:Right() * (self.VMDeltaX/(math.pi*1.7)))
	pos = pos + (ang:Up() * -(self.VMDeltaY/(math.pi*1.7)))

	-- Roll
	self.VMRoll = Lerp(ft8, self.VMRoll, rd * movepercent)

	local degRoll = math.deg(math.sin(self.VMRoll * math.pi))

	ang:RotateAroundAxis(ang:Forward(), degRoll * (math.pi / 10))
	--ang:RotateAroundAxis(ang:Right(), self.VMRoll * 7)
	ang:RotateAroundAxis(ang:Up(), self.VMRoll * (math.pi / 5	))
	pos = pos + (ang:Right() * (degRoll /80))
	pos = pos + (ang:Up() * (degRoll /80 ))


	-- [[ END SWAY ]] --

	-- [[ BOBBING ]] --

	local vel = self.Owner:GetVelocity()
	local len = vel:Length()
	
	c_move = Lerp(ft8, c_move or 0, onGround and movepercent or 0)
	--pos = pos + ang:Forward() * c_move  * fd - ang:Up() * .75 * c_move + ang:Right() * .5 * c_move
	local p = c_move * c_sight * 1
	local move = math.Clamp(len / self.Owner:GetRunSpeed(), 0, 1)

	if self:GetIronsights() then
		move = move * 0.2
	
	end

	if move > 0 then
		pos = pos - ang:Up() * move * 1.7
		-- Compress our weapon slightly when we move
		if not self:GetIronsights() then
			ang:RotateAroundAxis(ang:Forward(), move * -15)
			pos = pos - ang:Right() * 1.5 * move
		end
		
	end
	if onGround then
		local cycle = math.sin(ct * 8.4) 
		local cycle2 = math.cos(ct * 16.8) 

		-- Horizontal
		ang:RotateAroundAxis(ang:Up(), cycle * 2 * move)
		pos = pos + ang:Right() * cycle * 0.5 * move

		-- Vertical
		ang:RotateAroundAxis(ang:Right(), cycle2 * -0.3 * move)
		pos = pos + ang:Up() * cycle2 * 0.3 * move

		-- Special sprint case for rifles
		if move >= 0.8 and self.LoweredPos then

			local cycle = math.sin(ct * 9.7 * 2) 
			local cycle2 = math.cos(ct * 19.4 * 2) 

			-- Horizontal

			-- Vertical
			ang:RotateAroundAxis(ang:Forward(), cycle * 3 * move)
			ang:RotateAroundAxis(ang:Up(), cycle* -0.3 * move)
			ang:RotateAroundAxis(ang:Right(), cycle * -0.74 * move)
			pos = pos + ang:Right() * cycle * 0.1 * move
			pos = pos + ang:Forward() * cycle * 0.4 * move
			--pos = pos + ang:Up() * cycle2 * 0.3 * move
		
		end


	else
		local cycle = math.sin(ct * 8.4* movement) 
		local cycle2 = math.cos(ct * 16.8* movement) 

		-- Horizontal
		ang:RotateAroundAxis(ang:Up(), cycle * 2 * move)
		pos = pos + ang:Right() * cycle * 0.5 

		-- Vertical
		ang:RotateAroundAxis(ang:Right(), cycle2 * -0.3 * move)
		pos = pos + ang:Up() * cycle2 * 0.3 * movement	
	end
	-- We lerp all positions to avoid jittering
	
	--if self:GetIronsights() then

	-- Calculate offsets (real)
	

	self.VMPos = pos
	self.VMAng = ang

	self.VMPos = self.VMPos + (self.VMAng:Right() * self.VMRecoilPos.x)
	self.VMPos = self.VMPos + (self.VMAng:Up() * self.VMRecoilPos.y)
	self.VMPos = self.VMPos + (self.VMAng:Forward() * self.VMRecoilPos.z)

	self.VMAng:RotateAroundAxis(self.VMAng:Right(), self.VMRecoilAng.x)
	self.VMAng:RotateAroundAxis(self.VMAng:Up(), self.VMRecoilAng.y)
	self.VMAng:RotateAroundAxis(self.VMAng:Forward(), self.VMRecoilAng.z)

	self.VMRecoilPos = LerpVector(FrameTime() * 6, self.VMRecoilPos, Vector(0, 0, 0))
	self.VMRecoilAng = LerpAngle(FrameTime() * 6, self.VMRecoilAng, Angle(0, 0, 0))

	-- Recoil is last so it's overriding all

	

	return self.VMPos, self.VMAng
end
