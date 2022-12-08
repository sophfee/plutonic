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


local rtx = GetRenderTargetEx("ls2_rt", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 0, CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_DEFAULT)



SWEP.VMRenderTarget = CreateMaterial("ls2_sight_rt", "UnlitGeneric", {
	["$model"] = 1,
	["$basetexture"] = rtx:GetName(),
	["$phong"] = 1,
	["$phongexponent"] = 100,
	["$phongboost"] = 1,
	["$phongfresnelranges"] = "[0 0.5 1]",
	["$phongalbedotint"] = "[1 1 1]",
	["$phongtint"] = "[1 1 1]"
})

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
		return ironsights_pos + (offset_pos or Vector()),
		self.IronsightsAng
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

local mat = Material("ph_scope/ph_scope_lens5")
mat:SetTexture("$basetexture", rtx)

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
	--PrintTable(att:GetMaterials())

	--[[self.VMRenderTarget:SetTexture("$basetexture", rtx)
	if not self.asdasd then
		self.asdasd = true
		local m = self.VMRenderTarget:GetMatrix("$basetexturetransform")
		m:SetScale(Vector(-1,1, 0))
		self.VMRenderTarget:SetMatrix("$basetexturetransform", m)
		self.VMRenderTarget:SetFloat("$phong", 1)
	self.VMRenderTarget:SetFloat("$phongexponent", 100)
	self.VMRenderTarget:SetFloat("$phongboost", 1)
	--self.VMRenderTarget:SetFloat("$phongfresnelranges", 1)
	
	self.VMRenderTarget	:SetTexture("$bumpmap", "models/debug/debugwhite")
	self.VMRenderTarget:Recompute()
	end]]

	

	

	--att:SetSubMaterial(1, "")
	att:SetSubMaterial(2, "ph_scope/ph_scope_lens5")
	--att:GetSubMaterial()

	
	self:DrawHoloSight(pos, ang, att)
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

-- General math caching
local abs, min, max, clamp, sin, cos, rad, deg = math.abs, math.min, math.max, math.Clamp, math.sin, math.cos, math.rad, math.deg

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

hook.Add("StartCommand", "Longsword2.StartCommand", function(ply, ucmd)

	if ply.GetActiveWeapon then
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) then
			if wep.IsLongsword then
				if wep:GetIronsights() then
					local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()

					if math.abs(x) > 0 or math.abs(y) > 0 then
						wep.LastInput = CurTime()

						wep.VMSwayX = wep.VMSwayX + ucmd:GetMouseX() * 0.03

						if wep.VMSwayX > 0 then
							wep.VMSwayX = math.min(wep.VMSwayX, wep.VMDeltaX) + x * 0.03
							--wep.VMDeltaX = wep.VMSwayX
						else
							wep.VMSwayX = math.max(wep.VMSwayX, wep.VMDeltaX) + x * 0.03
							--wep.VMDeltaX = wep.VMSwayX
						end

						wep.VMSwayY = wep.VMSwayY + ucmd:GetMouseY() * 0.03

						if wep.VMSwayY > 0 then
							wep.VMSwayY = math.min(wep.VMSwayY, wep.VMDeltaY) + y * 0.03
							--wep.VMDeltaX = wep.VMSwayX
						else
							wep.VMSwayY = math.max(wep.VMSwayY, wep.VMDeltaY) + y * 0.03
							--wep.VMDeltaX = wep.VMSwayX
						end
					end

					--wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * 0.001
					--wep.VMSwayY = wep.VMDeltaY
				else
					local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()
					

					if math.abs(x) > 0 or math.abs(y) > 0 then
						wep.LastInput = CurTime()

						wep.VMSwayX = wep.VMSwayX + ucmd:GetMouseX() * 0.12

						if wep.VMSwayX > 0 then
							wep.VMSwayX = math.min(wep.VMSwayX, wep.VMDeltaX) + x * 0.12
							--wep.VMDeltaX = wep.VMSwayX
						else
							wep.VMSwayX = math.max(wep.VMSwayX, wep.VMDeltaX) + x * 0.12
							--wep.VMDeltaX = wep.VMSwayX
						end

						wep.VMSwayY = wep.VMSwayY + ucmd:GetMouseY() * 0.12

						if wep.VMSwayY > 0 then
							wep.VMSwayY = math.min(wep.VMSwayY, wep.VMDeltaY) + y * 0.12
							--wep.VMDeltaX = wep.VMSwayX
						else
							wep.VMSwayY = math.max(wep.VMSwayY, wep.VMDeltaY) + y * 0.12
							--wep.VMDeltaX = wep.VMSwayX
						end
					end

					

					--wep.VMSwayX = wep.VMDeltaX + ucmd:GetMouseX() * 0.04
					--wep.VMDeltaX = wep.VMSwayX 
					--wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * 0.004
				end
			end
		end
	end
	
end)

local abs = math.abs

local pi2 = math.pi * 1.2

local walk_pos_in = {
	Vector(
		-0.1, 
		-0.1, 
		-0.4
	)
}
local walk_pos_out = {
	Vector(
		0.4, 
		0, 
		-0.1
	)
}

local walk_ang_in = {
	Angle(
		0, 
		-4, 
		4
	)
}

local walk_ang_out = {
	Angle(
		2, 
		-2, 
		2
	)
}

SWEP.VMWalkBobInCyclePos = walk_pos_in[1]
SWEP.VMWalkBobInCycleAng = walk_ang_in[1]
SWEP.VMWalkBobOutCyclePos = walk_pos_out[1]
SWEP.VMWalkBobOutCycleAng = walk_ang_out[1]

SWEP.VMLastMoved = 0

sound.Add({
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
})

sound.Add({
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
})



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

	if math.Round(self.VMDeltaX, 6) == 0 then
		self.VMStillXFor = self.VMStillXFor + ft
	else
		self.VMStillXFor = 0	
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

	--self.VMDeltaX = math.Clamp(self.VMDeltaX, -11, 11)
	--self.VMDeltaY = math.Clamp(self.VMDeltaY, -11, 11)

	local dt = math.Clamp( abs((CurTime() - self.LastInput)/1.8), 0, 1)

	self.VMDeltaX = Lerp(ft8, self.VMDeltaX, self.VMSwayX * (1 - math.ease.OutElastic(dt))) 
	self.VMDeltaY = Lerp(ft8, self.VMDeltaY, self.VMSwayY * (1 - math.ease.OutElastic(dt))) 

	
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
			ang:RotateAroundAxis(ang:Forward(), move * -8)
			pos = pos - ang:Right() * 0.5 * move
		end
		
	end
	if onGround then
		local cycle = math.sin(ct * 8.4)
		local cycle2 = math.cos(ct * 16.8)

		local stepcycle = math.cos(ct * 10.4)
		pos = pos + ang:Right() * stepcycle * 1.1 * move
		ang:RotateAroundAxis(ang:Up(), stepcycle * 1.2 * move)

		pos = pos + ang:Up() * cycle2 * 0.7 * move
		ang:RotateAroundAxis(ang:Right(), cycle2 * -1.95 * move)

		ang:RotateAroundAxis(ang:Forward(), cycle * 1.97 * move)

		-- Horizontal


		-- Special sprint case for rifles
		if move >= 0.8 and self.LoweredPos then

			local cycle = math.sin(ct * 9.7 * 2) 
			local cycle2 = math.cos(ct * 19.4 * 2) 

			if (self.VMLastSprintSound or 0) < CurTime() then
				self.VMLastSprintSound = CurTime() + 0.33
				self:EmitSound("Longsword2.Sprint")
			end
			-- Horizontal

			-- Vertical
			ang:RotateAroundAxis(ang:Forward(), cycle * 3 * move)
			ang:RotateAroundAxis(ang:Up(), cycle* -0.3 * move)
			ang:RotateAroundAxis(ang:Right(), cycle * -0.74 * move)
			pos = pos + ang:Right() * cycle * 0.1 * move
			pos = pos + ang:Forward() * cycle * 0.4 * move
			--pos = pos + ang:Up() * cycle2 * 0.3 * move
		
		elseif move >= 0.2 then
			if (self.VMLastWalkSound or 0) < CurTime() then
				self.VMLastWalkSound = CurTime() + 0.33
				self:EmitSound("Longsword2.Walk")
			end
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

	if math.Round(move, 4) == 0 then

		if not self:GetIronsights() then

			local t = CurTime() - (self.VMLastMoved or CurTime())
			local lt = math.Clamp(t, 0, 1)

			local cycle = math.cos(t * 0.8) * lt  
			local vycle = math.sin(t * 0.8) * lt
			local tycle = math.sin(t * 0.8) * lt

			-- Horizontal
			ang:RotateAroundAxis(ang:Up(), cycle * 0.7)
			pos = pos + ang:Right() * cycle * 0.1

			-- Vertical
			ang:RotateAroundAxis(ang:Right(), vycle * -0.4)
			pos = pos + ang:Up() * vycle * 0.1

			pos = pos + ang:Forward() * tycle *  0.5
			ang:RotateAroundAxis(ang:Forward(), tycle * 1.5)
		end
	else 
		self.VMLastMoved = CurTime()
	end

	if self.Owner:KeyDown(IN_DUCK) and not self:GetIronsights() then
		self.VMCrouchDelta = math.Approach(self.VMCrouchDelta, 1, ft)	
	else	
		self.VMCrouchDelta = math.Approach(self.VMCrouchDelta, 0, ft)
	end

	if self.VMCrouchDelta > 0 then
		pos = pos + ang:Up() * -0.4 * easeInOutQuint(self.VMCrouchDelta)
		ang:RotateAroundAxis(ang:Forward(), easeInOutQuint(self.VMCrouchDelta) * -4)
	end
	-- We lerp all positions to avoid jittering
	
	--if self:GetIronsights() then

	-- Calculate offsets (real)
	

	self.VMPos = pos
	self.VMAng = ang

	self.VMPos = self.VMPos + (self.VMAng:Right() * self.VMRecoilPos.x)
	self.VMPos = self.VMPos + (self.VMAng:Forward() * self.VMRecoilPos.y)
	self.VMPos = self.VMPos + (self.VMAng:Up() * self.VMRecoilPos.z)

	self.VMAng:RotateAroundAxis(self.VMAng:Right(), self.VMRecoilAng.p)
	self.VMAng:RotateAroundAxis(self.VMAng:Up(), self.VMRecoilAng.y)
	self.VMAng:RotateAroundAxis(self.VMAng:Forward(), self.VMRecoilAng.r)

	self.VMRecoilPos = LerpVector(FrameTime() * 6, self.VMRecoilPos, Vector(0, 0, 0))
	self.VMRecoilAng = LerpAngle(FrameTime() * 6, self.VMRecoilAng, Angle(0, 0, 0))

	-- Recoil is last so it's overriding all

	

	return self.VMPos, self.VMAng
end

local aimdot = Material("ph_scope/ph_scope_lens5")
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


	render.SetBlend( 0 )
		render.OverrideDepthEnable( true, true )

			render.SetStencilReferenceValue(32)

			
	
			att:DrawModel()

			--render.SetStencilReferenceValue(0)

			

		
		render.OverrideDepthEnable( false )
	
	render.SetBlend( 1 )

	render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetColorModulation(1, 1, 1, 255)
	render.SetMaterial(aimdot)
		local pos = att:GetPos()
		pos = pos + (att:GetAngles():Forward() * 44)
		pos = pos + (att:GetAngles():Up() * 1.4)
		
		local sc = pos:ToScreen()

		
		--render.DrawScreenQuad()
		
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilCompareFunction(STENCIL_GREATER)

	if self:GetIronsights() then
		
		for i = 1, 10 do
			bl:SetFloat("$blur", i * 6)
			bl:Recompute()
			render.SetStencilReferenceValue(32 - i)
			render.SetMaterial(bl)
			render.DrawScreenQuad()
		end
	end

	render.SetStencilReferenceValue(0)
	render.SetStencilEnable(false)
	render.ClearStencil()

	
	render.UpdateFullScreenDepthTexture()

	render.PushRenderTarget(rtx,0,0,512,512)

		

		render.ClearRenderTarget(rtx, Color(0,0,0,0))
		if self:GetIronsights() then
		--render.PushRenderTarget(rtx)
			render.BlurRenderTarget(rtx, ScrW(), ScrH(), 3)
		-- render.PopRenderTarget()
		render.RenderView({
			origin = pos,
			angles = pang ,
			x=0,
			y=0,
			w = -512,
			h = 512,
			drawviewmodel = false,
        	fov = 14.6,	
		})
		render.DrawScreenQuad()
		end

		local pang = att:GetAngles()
		
		
		render.PopRenderTarget()
	
	
	--render.DrawTextureToScreen(bl:GetTexture("$basetexture"))
end