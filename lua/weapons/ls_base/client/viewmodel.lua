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

-- quad bezier lerp from roblox ez dub
local function rbxLerp(a, b, c)
	return a + (b - a) * c
end

local function quadBezier(t, p0, p1, p2)
	local l1 = rbxLerp(p0, p1, t)
	local l2 = rbxLerp(p1, p2, t)
	local quad = rbxLerp(l1, l2, t)
	return quad
end

local function vecBezier(t, v0, v1, v2)
	return Vector(quadBezier(t, v0.x, v1.x, v2.x), quadBezier(t, v0.y, v1.y, v2.y), quadBezier(t, v0.z, v1.z, v2.z))
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

	local centered = GetConVar("longsword_centered")
	local isCentered = centered:GetBool()
	local is_pos = self.IronsightsPos
	local v1 = isCentered and Vector(is_pos.x, 0, -2) or Vector(0, 0, 0)
	local v2 = Vector(is_pos.x * 1.2, is_pos.y * 0.8, is_pos.x * 0.8)
	--local v3 = Vector(is_pos.x*1.2,is_pos.y/1.125,is_pos.z/1.125)
	local ironsights_pos = vecBezier(quadBezier(self.IronsightsLerp, 0, 0.4, 1), v1, v2, is_pos)

	if self:GetIronsights() then
		local offset_pos = LerpVector(self:GetIronsightsRecoil(), Vector(), VectorRand(-0.06, 0.06))
		self.IronsightsLerp = math.Approach(self.IronsightsLerp, 1, FrameTime() * self.IronsightsSpeed)
		return ironsights_pos + (offset_pos or Vector()), self.IronsightsAng
	else
		self.IronsightsLerp = math.Approach(self.IronsightsLerp, 0, FrameTime() * self.IronsightsSpeed)
	end
	if self.IronsightsLerp > 0 then
		return ironsights_pos, Angle(0, 0, self.IronsightsLerp * self.IronsightsRocking)
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
						--wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * 0.001
						--wep.VMSwayY = wep.VMDeltaY
						local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()

						if abs(x) > 0 or abs(y) > 0 then
							wep.LastInput = CurTime()

							wep.VMSwayX = wep.VMSwayX + ucmd:GetMouseX() * 0.03

							if wep.VMSwayX > 0 then
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayX = min(wep.VMSwayX, wep.VMDeltaX) + x * 0.03
							else
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayX = max(wep.VMSwayX, wep.VMDeltaX) + x * 0.03
							end

							wep.VMSwayY = wep.VMSwayY + ucmd:GetMouseY() * 0.03

							if wep.VMSwayY > 0 then
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayY = min(wep.VMSwayY, wep.VMDeltaY) + y * 0.03
							else
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayY = max(wep.VMSwayY, wep.VMDeltaY) + y * 0.03
							end
						end
					else
						local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()

						if abs(x) > 0 or abs(y) > 0 then
							wep.LastInput = CurTime()

							wep.VMSwayX = wep.VMSwayX + ucmd:GetMouseX() * 0.12

							if wep.VMSwayX > 0 then
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayX = min(wep.VMSwayX, wep.VMDeltaX) + x * 0.12
							else
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayX = max(wep.VMSwayX, wep.VMDeltaX) + x * 0.12
							end

							wep.VMSwayY = wep.VMSwayY + ucmd:GetMouseY() * 0.12

							if wep.VMSwayY > 0 then
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayY = min(wep.VMSwayY, wep.VMDeltaY) + y * 0.12
							else
								--wep.VMDeltaX = wep.VMSwayX
								wep.VMSwayY = max(wep.VMSwayY, wep.VMDeltaY) + y * 0.12
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

function SWEP:GetViewModelPosition(pos, ang)
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

	local toffset, toffsetang = self:GetOffset()
	if self.VMOffsetPos then
		local offset = self.VMOffsetPos
		pos = pos + (ang:Right() * offset.x)
		pos = pos + (ang:Forward() * offset.y)
		pos = pos + (ang:Up() * offset.z)
	end

	if self.VMOffsetAng then
		local offsetang = self.VMOffsetAng
		ang:RotateAroundAxis(ang:Right(), offsetang.p)
		ang:RotateAroundAxis(ang:Up(), offsetang.y)
		ang:RotateAroundAxis(ang:Forward(), offsetang.r)
	end

	local dt = clamp(abs((ct - self.LastInput) / 1.8), 0, 1)

	local elt = (1 - easeOutElastic(dt))

	self.VMDeltaX = self.VMDeltaX or 0
	self.VMDeltaY = self.VMDeltaY or 0
	self.VMRoll = self.VMRoll or 0
	self.VMSwayX = self.VMSwayX or 0
	self.VMSwayY = self.VMSwayY or 0

	self.VMDeltaX = lerp(ft8, self.VMDeltaX, self.VMSwayX * elt)
	self.VMDeltaY = lerp(ft8, self.VMDeltaY, self.VMSwayY * elt)

	-- Perform VM Rotations and shit
	ang:RotateAroundAxis(ang:Up(), self.VMDeltaX)
	ang:RotateAroundAxis(ang:Right(), self.VMDeltaY)

	-- Offset the viewmodel
	pos = pos + (ang:Right() * (self.VMDeltaX / (pi * 1.7)))
	pos = pos + (ang:Up() * -(self.VMDeltaY / (pi * 1.7)))

	-- Roll
	self.VMRoll = lerp(ft8, self.VMRoll, rd * movepercent)

	local degRoll = deg(sin(self.VMRoll * pi))

	ang:RotateAroundAxis(ang:Forward(), degRoll * (pi / 10))
	ang:RotateAroundAxis(ang:Up(), self.VMRoll * (pi / 5))
	pos = pos + (ang:Right() * (degRoll / 80))
	pos = pos + (ang:Up() * (degRoll / 80))

	-- [[ END SWAY ]] --

	-- [[ BOBBING ]] --

	local vel = self.Owner:GetVelocity()
	local len = vel:Length()

	c_move = lerp(ft8, c_move or 0, onGround and movepercent or 0)
	--pos = pos + ang:Forward() * c_move  * fd - ang:Up() * .75 * c_move + ang:Right() * .5 * c_move
	local p = c_move * c_sight * 1
	local move = clamp(len / self.Owner:GetRunSpeed(), 0, 1)

	if isIronsights then
		move = move * 0.2
	end

	if move > 0 then
		pos = pos - ang:Up() * move * 1.7
		-- Compress our weapon slightly when we move
		if not isIronsights then
			ang:RotateAroundAxis(ang:Forward(), move * -8)
			pos = pos - ang:Right() * 0.5 * move
		end
	end
	if onGround then
		local cycle = sin(rt * 8.4)
		local cycle2 = cos(rt * 16.8)

		local stepcycle = cos(rt * 10.4)
		pos = pos + ang:Right() * stepcycle * 1.1 * move
		ang:RotateAroundAxis(ang:Up(), stepcycle * 1.2 * move)

		pos = pos + ang:Up() * cycle2 * 0.7 * move
		ang:RotateAroundAxis(ang:Right(), cycle2 * -1.95 * move)

		ang:RotateAroundAxis(ang:Forward(), cycle * 1.97 * move)

		-- Horizontal

		-- Special sprint case for rifles
		if move >= 0.8 and self.LoweredPos then
			--pos = pos + ang:Up() * cycle2 * 0.3 * move
			local cycle = sin(rt * 9.7 * 2)
			local cycle2 = cos(rt * 19.4 * 2)

			if (self.VMLastSprintSound or 0) < ct then
				self.VMLastSprintSound = ct + 0.33
				self:EmitSound("Longsword2.Sprint")
			end
			-- Horizontal

			-- Vertical
			ang:RotateAroundAxis(ang:Forward(), cycle * 3 * move)
			ang:RotateAroundAxis(ang:Up(), cycle * -0.3 * move)
			ang:RotateAroundAxis(ang:Right(), cycle * -0.74 * move)
			pos = pos + ang:Right() * cycle * 0.1 * move
			pos = pos + ang:Forward() * cycle * 0.4 * move
		elseif move >= 0.2 then
			if (self.VMLastWalkSound or 0) < ct then
				self.VMLastWalkSound = CurTime() + 0.33
				self:EmitSound("Longsword2.Walk")
			end
		end
	else
		local cycle = sin(rt * 8.4 * movement)
		local cycle2 = cos(rt * 16.8 * movement)

		-- Horizontal
		ang:RotateAroundAxis(ang:Up(), cycle * 2 * move)
		pos = pos + ang:Right() * cycle * 0.5

		-- Vertical
		ang:RotateAroundAxis(ang:Right(), cycle2 * -0.3 * move)
		pos = pos + ang:Up() * cycle2 * 0.3 * movement
	end

	if round(move, 4) == 0 then
		if not isIronsights then
			local t = ct - (self.VMLastMoved or ct)
			local lt = clamp(t, 0, 1)

			local cycle = cos(t * 0.8) * lt
			local vycle = sin(t * 0.8) * lt
			local tycle = sin(t * 0.8) * lt

			-- Horizontal
			ang:RotateAroundAxis(ang:Up(), cycle * 0.7)
			pos = pos + ang:Right() * cycle * 0.1

			-- Vertical
			ang:RotateAroundAxis(ang:Right(), vycle * -0.4)
			pos = pos + ang:Up() * vycle * 0.1

			pos = pos + ang:Forward() * tycle * 0.5
			ang:RotateAroundAxis(ang:Forward(), tycle * 1.5)
		end
	else
		self.VMLastMoved = ct
	end

	if self.Owner:KeyDown(IN_DUCK) and not isIronsights then
		self.VMCrouchDelta = approach(self.VMCrouchDelta, 1, ft)
	else
		self.VMCrouchDelta = approach(self.VMCrouchDelta, 0, ft)
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
