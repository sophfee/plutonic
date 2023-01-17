--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

-- [ File Details ]
-- Purpose: Loads the inital basic values, loads first!

SWEP.IsLongsword = true
SWEP.PrintName = "Longsword"
SWEP.Category = "LS"
SWEP.DrawWeaponInfoBox = false

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 55
SWEP.UseHands = true

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.CustomEvents = {}

SWEP.CSMuzzleFlashes = true

SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.Primary.Recoil = 0.8
SWEP.Primary.Damage = 5
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.03
SWEP.Primary.Delay = 0.13

SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 12

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

SWEP.EmptySound = Sound("Weapon_Pistol.Empty")
SWEP.IronsightsRocking = 16
SWEP.SwayFactor = 8
SWEP.Sway = 1
SWEP.Spread = {}
SWEP.Spread.Min = 0
SWEP.Spread.Max = 0.5
SWEP.Spread.IronsightsMod = 0.1
SWEP.Spread.CrouchMod = 0.6
SWEP.Spread.AirMod = 1.2
SWEP.Spread.RecoilMod = 0.025
SWEP.Spread.VelocityMod = 0.5
SWEP.IronsightsSpeed = 4
SWEP.IronsightsPos = Vector( -5.9613, -3.3101, 2.706 )
SWEP.IronsightsAng = Angle( 0, 0, 0 )
SWEP.IronsightsFOV = 0.8
SWEP.IronsightsSensitivity = 0.8
SWEP.IronsightsCrosshair = false
SWEP.UseIronsightsRecoil = true
SWEP.scopedIn = SWEP.scopedIn or false
SWEP.CanBreachDoors = false
SWEP.SwayScale = 0
SWEP.BobScale = 0

SWEP.Reverb = {}
SWEP.Reverb.Primary = {}
SWEP.Reverb.Primary.IndoorEnabled = false
SWEP.Reverb.Primary.Indoor = Sound("")
SWEP.Reverb.Primary.IndoorRange = 1200
SWEP.Reverb.Primary.OutdoorEnabled = false
SWEP.Reverb.Primary.Outdoor = Sound("")
SWEP.Reverb.Primary.OutdoorRange = 5000

sound.Add({
	name = "Longsword2.Draw",
	sound = {
		"weapons/ins2/uni/uni_weapon_draw_01.wav",
		"weapons/ins2/uni/uni_weapon_draw_02.wav",
		"weapons/ins2/uni/uni_weapon_draw_03.wav"
	},
	level = 60,
	channel = CHAN_AUTO,
	pitch = {95,105}
})

sound.Add({
	name = "Longsword2.Raise",
	sound = {
		"weapons/ins2/uni/uni_lean_in_01.wav",
		"weapons/ins2/uni/uni_lean_in_02.wav",
		"weapons/ins2/uni/uni_lean_in_03.wav",
		"weapons/ins2/uni/uni_lean_in_04.wav"
	},
	level = 60,
	channel = CHAN_AUTO,
	pitch = {95,105}
})

-- impulse
function SWEP:OnLowered()
	self:EmitSound("Longsword2.Raise", nil, nil, nil, nil, SND_NOFLAGS, 1)
end

function SWEP:Initialize()

	if CLIENT then
		self.VMPos = Vector()
		self.VMAng = Angle()
		self.VMIronsights = 0
		self.VMCrouch = 0
		self.VMBlocked = 1
		self.VMRDBEF = 0
		self.VMBobCycle = 0
		self.VMSwayX = 0
		self.VMDeltaX = 0
		self.VMRoll = 0
		self.VMSwayY = 0
		self.VMDeltaX = 0
		self.VMRattle = 0
		self.VMSprint = 0
		self.VMVel = 0
		self.VMIdle = 0
		self.VMRecoil = Vector()
		self.VMRecoilAng = Angle()
	end

	self:SetIronsights(false)

	self:SetReloading(false)
	self:SetReloadTime(0)

	self:SetRecoil(0)
	self:SetNextIdle(0)

	self:SetHoldType(self.HoldType)

	if SERVER and self.CustomMaterial then
		self.Weapon:SetMaterial(self.CustomMaterial)
	end
end

function SWEP:OnReloaded()
	timer.Simple(0, function()
		self:SetHoldType(self.HoldType)
	end)
end



function SWEP:Deploy()

	if CLIENT then
		self.VMPos = Vector()
		self.VMAng = Angle()
		self.VMIronsights = 0
		self.VMCrouch = 0
		self.VMBlocked = 1 -- The oddball, due to the way it works needs to be set to 1
		self.VMRDBEF = 0
		self.VMBobCycle = 0
		self.VMSwayX = 0
		self.VMDeltaX = 0
		self.VMRoll = 0
		self.VMSwayY = 0
		self.VMDeltaX = 0
		self.VMRattle = 0
		self.VMSprint = 0
		self.VMVel = 0
		self.VMIdle = 0
		self.VMRecoil = Vector()
		self.VMRecoilAng = Angle()
	end

	if self.CustomMaterial then
		if CLIENT then
			self.Owner:GetViewModel():SetMaterial(self.CustomMaterial)
			self.CustomMatSetup = true
		end
	end
	self.DrawTime = UnPredictedCurTime()
	self:PlayAnim(ACT_VM_DRAW)
	if self.Owner:IsPlayer() then
		self.Owner:GetViewModel():SetPlaybackRate(1)
	end
	self:EmitSound(Sound("Longsword2.Draw"), nil, nil, nil, nil, SND_NOFLAGS, 1)

	return true
end

local PIERCING_MATS = {
	[MAT_FLESH] = true,
	[MAT_BLOODYFLESH] = true,
	[MAT_ALIENFLESH] = true,
	[MAT_ANTLION] = true,
	[MAT_DIRT] = true,
	[MAT_SAND] = true,
	[MAT_FOLIAGE] = true,
	[MAT_GRASS] = true,
	[MAT_SLOSH] = true,
	[MAT_PLASTIC] = true,
	[MAT_TILE] = true,
	[MAT_CONCRETE] = true,
	[MAT_WOOD] = true,
	[MAT_GLASS] = true,
	[MAT_COMPUTER] = true
}

local ALWAYS_PIERCE = {
	[MAT_GLASS] = true,
	[MAT_VENT] = true,
	[MAT_GRATE] = true
}

function SWEP:ShootBullet(damage, num_bullets, aimcone, override_src, override_dir)

	if self.UseBallistics then
		if CLIENT then return end
		local bulllet = ents.Create("ls_ballistic")
		bulllet:SetPos(self.Owner:GetShootPos())
		bulllet:SetAngles(self.Owner:GetAimVector():Angle())
		bulllet:SetOwner(self.Owner)
		
		bulllet:Spawn()
		bulllet:Launch()
		return
	end

	local bullet = {}

	bullet.Num 	= num_bullets
	bullet.Src 	= override_src or self.Owner:GetShootPos() -- Source
	bullet.Dir 	= override_dir or self.Owner:GetAimVector() -- Dir of bullet
	bullet.Spread 	= Vector(aimcone, aimcone, 0)	-- Aim Cone

	if self.Primary.Tracer then
		bullet.TracerName = "tracer"
		--bullet.TracerName = self.Primary.Tracer
	else
		bullet.TracerName = "tracer"
	end

	if self.Primary.Range then
		bullet.Distance = self.Primary.Range
	end

	bullet.Tracer	= 1 -- Show a tracer on every x bullets
	bullet.Force	= 1 -- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"

	if CLIENT then
		bullet.Callback = function(attacker, tr)
			--ParticleEffect("muzzleflash_1", tr.StartPos, tr.HitNormal:Angle(), nil)
			if (self.Primary.Piercing or ALWAYS_PIERCE[tr.MatType]) and not pierce_shot then
				if true then
					-- Find the exit point

					local exitPoint = util.TraceLine({
						start = tr.HitPos + tr.Normal * 16,
						endpos = tr.HitPos,
						filter = attacker,
						mask = MASK_SHOT
					})

					if exitPoint.Hit then
						--util.ParticleTracerEx("TracerSound", tr.HitPos, exitPoint.HitPos, true, attacker:EntIndex(), 2)
						--debugoverlay.Cross(exitPoint.HitPos, 2, 3, Color(0, 255, 0), true)
						if true then
							local newbullet = {}
							newbullet.Num 	= num_bullets
							newbullet.Src 	= exitPoint.HitPos -- Source
							newbullet.Dir 	= tr.Normal -- Dir of bullet
							newbullet.Spread 	= Vector(aimcone, aimcone, 0)	-- Aim Cone
							newbullet.Tracer	= 1 -- Show a tracer on every x bullets
							newbullet.Force	= 1 -- Amount of force to give to phys objects
							newbullet.Damage	= damage / 3
							newbullet.AmmoType = "Pistol"
							self.Owner:FireBullets(newbullet)
						end
					end
				end
			end
			
		--util.ParticleTracerEx("TracerSound", attacker:GetShootPos(), tr.HitPos, true, attacker:EntIndex(), 2)
			if attacker.IsDeveloper then
				if attacker:IsDeveloper() then
					debugoverlay.Cross(tr.HitPos, 2, 3, Color(255, 0, 0), true)
				end
			end
		end
	else
		bullet.Callback = function(attacker, tr)

			--ParticleEffect("muzzleflash_1", tr.StartPos, tr.HitNormal:Angle(), nil)

			if (self.Primary.Piercing or ALWAYS_PIERCE[tr.MatType]) and not pierce_shot then
				if true then
					-- Find the exit point

					local exitPoint = util.TraceLine({
						start = tr.HitPos + tr.Normal * 16,
						endpos = tr.HitPos,
						filter = attacker,
						mask = MASK_SHOT
					})

					if exitPoint.Hit then
						--util.ParticleTracerEx("TracerSound", tr.HitPos, exitPoint.HitPos, true, attacker:EntIndex(), 2)
						--debugoverlay.Cross(exitPoint.HitPos, 2, 3, Color(0, 255, 0), true)
						if true then
							local newbullet = {}
							newbullet.Num 	= num_bullets
							newbullet.Src 	= exitPoint.HitPos -- Source
							newbullet.Dir 	= tr.Normal -- Dir of bullet
							newbullet.Spread 	= Vector(aimcone, aimcone, 0)	-- Aim Cone
							newbullet.Tracer	= 1 -- Show a tracer on every x bullets
							newbullet.Force	= 1 -- Amount of force to give to phys objects
							newbullet.Damage	= damage / 1.6
							newbullet.AmmoType = "Pistol"
							self.Owner:FireBullets(newbullet)
						end
					end
				end
			end
			
			util.ParticleTracerEx("Tracer", tr.StartPos, tr.HitPos, true, self:EntIndex(), 1)

			if self.CanBreachDoors then
				if impulse then -- only works on impulse framework
					local door = tr.Entity
					--print("hi smile")
					--print(door)
					if IsValid(door) then
						if door:IsDoor() and door:GetClass() == "prop_door_rotating" then
							local hp = door.__BREACH_HEALTH or 80
							door.__BREACH_HEALTH = hp - self.Primary.Damage
							--print(door.__BREACH_HEALTH)
							if door.__BREACH_HEALTH <= 0 then
								door:SetNotSolid(true)
                				door:SetNoDraw(true)
                				-- Attempt to fix PVS problems.
								door:EmitSound("Metal_Box.Break", 140)
                				door:DoorUnlock()
                				door:Fire("open", "", 0)
                				door:Fire("lock", "", 1.2)

                				if door:GetClass() == "prop_door_rotating" then
                    				local fakeDoor = ents.Create("prop_physics")
                    				if IsValid(fakeDoor) and IsValid(door) then
                        				fakeDoor:SetModel(door:GetModel())
                        				fakeDoor:SetPos(door:GetPos())
                        				fakeDoor:SetAngles(door:GetAngles())
                        				fakeDoor:SetSkin(door:GetSkin())
                        				fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD)

                        				fakeDoor:Spawn()

                        				fakeDoor:GetPhysicsObject():SetVelocity(attacker:GetForward() * 250)

                        				timer.Simple(impulse.Config.ExplosionDoorRespawnTime, function()
                            				if IsValid(fakeDoor) then
                                				fakeDoor:Remove()
                            				end
                        				end)
                    				end
                				end

                				timer.Simple(impulse.Config.ExplosionDoorRespawnTime, function()
                    				if not IsValid(door) then return end
                    				door:DoorUnlock()
                    				door:SetNotSolid(false)
                    				door:SetNoDraw(false)
									door.__BREACH_HEALTH = 80

                    				door.IsCharged = false
                				end)
							end 
						end
					end
				end
			end
		end
	end

	self.Owner:FireBullets(bullet)
	self:ShootEffects()
end

function SWEP:GetShootSrc()
    local owner = self:GetOwner()

    if !IsValid(owner) then return self:GetPos() end
    if owner:IsNPC() then return owner:GetShootPos() end

    local dir    = owner:EyeAngles()
    local offset = Vector(0, 0, 0)

    local src = owner:EyePos()


    src = src + dir:Right()   * offset[1]
    src = src + dir:Forward() * offset[2]
    src = src + dir:Up()      * offset[3]

    return src
end


function SWEP:ShootEffects()
	if CLIENT then
		self.CrosshairGapBoost = 16
		self.VMRecoilPos = self.BlowbackPos
		self.VMRecoilAng = self.BlowbackAngle
		self:LS_ProceduralRecoil(1)
	end

	self.VMRecoilFOV = 1
	if not self:GetIronsights() or not self.UseIronsightsRecoil then
		
		if self.PrimaryFireSequence then
			local vm = self.Owner:GetViewModel()
			vm.ResetSequenceInfo( vm )
			vm.SetSequence( vm, self.PrimaryFireSequence )
			vm:SendViewModelMatchingSequence(vm:LookupSequence(self.PrimaryFireSequence))
		else
			self:PlayAnim(ACT_VM_PRIMARYATTACK)
			self:QueueIdle()
		end
		
	else
		--self.ViewModelPos = self.IronsightsPos + self.BlowbackPos + (self.ViewModelOffset or Vector())
		--self.ViewModelAng = self.IronsightsAng + self.BlowbackAngle + (self.ViewModelOFfsetAng or Angle())
		self:SetIronsightsRecoil( 2 )
		self.CanDecreaseBlowback = CurTime() + 0.1
	end

	if CLIENT then
		self.CrosshairGapBoost = 24
		if !LocalPlayer():ShouldDrawLocalPlayer() and self.Owner == LocalPlayer() then
			local vm = self.Owner:GetViewModel()
			--PrintTable(vm:GetAttachments())
			local attachment = vm:LookupAttachment( self.MuzzleFlashAttachment or self.IronsightsMuzzleFlashAttachment or "muzzle")
			local posang = vm:GetAttachment(attachment)

			if posang then
				

				ParticleEffectAttach(self.MuzzleEffect or self.IronsightsMuzzleFlash, PATTACH_POINT_FOLLOW, vm, attachment)
			end
		end
	end


	local ed = EffectData()
    ed:SetStart(self:GetShootSrc())
    ed:SetOrigin(self:GetShootSrc())
    ed:SetScale(1)
    ed:SetEntity(self.OverrideWMEntity or self)
	ed:SetAttachment(self.MuzzleFlashAttachment or 1)
	util.Effect("longsword_muzzleflash", ed)

	self:PlayAnimWorld(ACT_VM_PRIMARYATTACK)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	if CLIENT then self:PlayAmmoIndicator() end

	if self.CustomShootEffects then
		self.CustomShootEffects(self)
	end
end

if SERVER then
	util.AddNetworkString("Longsword2_World_MuzzleFlash")

	function SWEP:LS2_ParticleEffectAttach(effect, attachment)

		local rf = RecipientFilter()
		rf:AddAllPlayers()
		--rf:AddPVS( self.Owner.GetPos( self.Owner ) )
		--rf:RemovePlayer( self.Owner )

		net.Start( "Longsword2_World_MuzzleFlash" )
		net.WriteEntity( self.Owner )
		net.WriteEntity( self )
		net.WriteString( effect )
		net.WriteInt( attachment, 32 )
		net.Send( rf )
	end
else
	net.Receive("Longsword2_World_MuzzleFlash", function()

		-- The entity the particle go to
		local usr = net.ReadEntity()
		
		

		local ent = net.ReadEntity()
		local eff = net.ReadString()
		local att = net.ReadInt(32)

		ParticleEffectAttach( eff, PATTACH_POINT_FOLLOW, ent, att )
	end)	
end

function SWEP:IsSprinting()
	return ( self.Owner:GetVelocity():Length2D() > self.Owner:GetRunSpeed() - 50 )
		and self.Owner:IsOnGround()
end

function SWEP:PrimaryAttack()
	if not self:CanShoot() then return end

	local clip = self:Clip1()

	if self.Primary.Burst and clip >= 3 then
		self:SetBursting(true)
		self.Burst = 3

		local delay = CurTime() + ((self.Primary.Delay * 3) + (self.Primary.BurstEndDelay or 0.3))
		self:SetNextPrimaryFire(delay)
		self:SetReloadTime(delay)
	elseif clip >= 1 then
		self:TakePrimaryAmmo(1)

		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self:CalculateSpread())

		self:AddRecoil()
		self:ViewPunch()

		self:EmitSound(self.Primary.Sound)

		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetReloadTime(CurTime() + self.Primary.Delay)
	else
		self:EmitSound(self.EmptySound)
		self:Reload()
		self:SetNextPrimaryFire(CurTime() + 1)
	end
end

function SWEP:SecondaryAttack() 
end

function SWEP:Holster()
	-- reset everything when we holster
	self:SetIronsights( false )
	self:SetIronsightsRecoil( 0 )

	self:SetReloading( false )
	self:SetReloadTime( 0 )

	self:SetRecoil( 0 )
	self:SetNextIdle( 0 )

	if CLIENT then
		self.ViewModelPos = Vector( 0, 0, 0 )
		self.ViewModelAng = Angle( 0, 0, 0 )
		self.FOV = nil
	end

	if self.CustomMaterial then
		if CLIENT then
			if self.Owner == LocalPlayer() then
				self.Owner:GetViewModel():SetMaterial("")
			end
		end
	end

	if self.ExtraHolster then
		self.ExtraHolster(self)
	end
	
	return true
end

function SWEP:OnRemove()
	if self.CustomMaterial then
		if CLIENT then
			if not self.Owner.GetViewModel then -- disconnect errors
				return
			end

			if not self.Owner == LocalPlayer() then
				return
			end

			if not IsValid(self.Owner) then
				return
			end

			if not IsValid(self.Owner:GetViewModel()) then
				return
			end

			self.Owner:GetViewModel():SetMaterial("")
		end
	end
end

function SWEP:QueueIdle()
	if self.Owner:IsNPC() then return end
	self:SetNextIdle( CurTime() + self.Owner:GetViewModel():SequenceDuration() + 0.1 )
end



function SWEP:CanShoot()
	return self:CanPrimaryAttack() and not self:GetBursting() and not (self.LoweredPos and self:IsSprinting()) and self:GetReloadTime() < CurTime()
end

function SWEP:ViewPunch()

	if self.Owner:IsNPC() then return end

	local punch = Angle()

	local mul = self:GetIronsights() and 0.65 or 1
	punch.p = util.SharedRandom( "ViewPunch", -0.5, 0.5 ) * self.Primary.Recoil * mul
	punch.y = util.SharedRandom( "ViewPunch", -0.5, 0.5 ) * self.Primary.Recoil * mul
	punch.r = 0

	self.Owner:ViewPunch( punch )

	if IsFirstTimePredicted() and ( CLIENT or game.SinglePlayer() ) then
		self.Owner:SetEyeAngles( self.Owner:EyeAngles() -
			Angle( self.Primary.Recoil * ( self:GetIronsights() and 0.5 or 1 ), 0, 0 ) )
	end
end

function SWEP:CanIronsight()
	if self.NoIronsights then
		return false
	end
	
	local att = self:GetCurAttachment()
	if att != "" and self.Attachments[att] and self.Attachments[att].Behaviour == "sniper_sight" and hook.Run("ShouldDrawLocalPlayer", self.Owner) then
		return false
	end

	return not self:IsSprinting() and not self:GetReloading() and self.Owner:IsOnGround()
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
	
	--print(options)
	-- Disables animation based muzzle event
	return true

end