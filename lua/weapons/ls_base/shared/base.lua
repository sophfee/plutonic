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

function SWEP:Initialize()
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
	if self.CustomMaterial then
		if CLIENT then
			self.Owner:GetViewModel():SetMaterial(self.CustomMaterial)
			self.CustomMatSetup = true
		end
	end

	self:PlayAnim(ACT_VM_DRAW)
	self.Owner:GetViewModel():SetPlaybackRate(1)
	self:EmitSound(Sound("Longsword2.Draw"), nil, nil, nil, nil, SND_NOFLAGS, 1)

	return true
end

function SWEP:ShootBullet(damage, num_bullets, aimcone)
	local bullet = {}

	bullet.Num 	= num_bullets
	bullet.Src 	= self.Owner:GetShootPos() -- Source
	bullet.Dir 	= self.Owner:GetAimVector() -- Dir of bullet
	bullet.Spread 	= Vector(aimcone, aimcone, 0)	-- Aim Cone

	if self.Primary.Tracer then
		bullet.TracerName = self.Primary.Tracer
	end

	if self.Primary.Range then
		bullet.Distance = self.Primary.Range
	end

	bullet.Tracer	= 1 -- Show a tracer on every x bullets
	bullet.Force	= 1 -- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = ""

	if CLIENT then
		bullet.Callback = function(attacker, tr)
			if attacker.IsDeveloper then
				if attacker:IsDeveloper() then
					debugoverlay.Cross(tr.HitPos, 2, 3, Color(255, 0, 0), true)
				end
			end
		end
	else
		bullet.Callback = function(attacker, tr)
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

function SWEP:ShootEffects()
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
		self.ViewModelPos = self.IronsightsPos + self.BlowbackPos + (self.ViewModelOffset or Vector())
		self.ViewModelAng = self.IronsightsAng + self.BlowbackAngle + (self.ViewModelOFfsetAng or Angle())
		self:SetIronsightsRecoil( 2 )
		self.CanDecreaseBlowback = CurTime() + 0.1
	end

	if CLIENT then
		if not (impulse.IronsightsMuzzleFlashFix and not self:GetIronsights()) then
			local vm = self.Owner:GetViewModel()
			--PrintTable(vm:GetAttachments())
			local attachment = vm:LookupAttachment( self.IronsightsMuzzleFlashAttachment or "muzzle")
			local posang = vm:GetAttachment(attachment)

			if posang then
				

				if (self.IronsightsMuzzleParticle) then
					posang.Ang:RotateAroundAxis(Vector(0,1,0),-90)
					--posang.Ang:RotateAroundAxis(Vector(0,0,1),180)
					 ParticleEffectAttach(self.IronsightsMuzzleFlash, PATTACH_POINT_FOLLOW, vm, attachment)
				else
					--[[local ef = EffectData()
					ef:SetOrigin(self.Owner:GetShootPos())
					ef:SetStart(self.Owner:GetShootPos())
					ef:SetNormal(self.Owner:EyeAngles():Forward())
					ef:SetEntity(self.Owner:GetViewModel())
					ef:SetAttachment(attachment)
					ef:SetScale(self.IronsightsMuzzleFlashScale or 1)
					util.Effect(self.IronsightsMuzzleFlash or "CS_MuzzleFlash", ef)]]
				end
			end
		end
	end

	
	-- self.Owner:MuzzleFlash()
	self:PlayAnimWorld(ACT_VM_PRIMARYATTACK)

	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if self.IronsightsMuzzleFlash and CLIENT then
		local attachment = self:LookupAttachment( self.IronsightsMuzzleFlashAttachment or "muzzle")
		local ef = EffectData()
					ef:SetOrigin(self.Owner:GetShootPos())
					ef:SetStart(self.Owner:GetShootPos())
					ef:SetNormal(self.Owner:EyeAngles():Forward())
					ef:SetEntity(self)
					ef:SetAttachment(1)
					ef:SetScale(self.IronsightsMuzzleFlashScale or 1)
		self:CreateParticleEffect("hl2mmod_muzzleflash_smg1", 2, {attachtype=PATTACH_POINT_FOLLOW,entity=self,position=self.Owner:GetShootPos()})
	end

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

		self:EmitSound(self.Primary.Sound, nil, nil, nil, nil, SND_NOFLAGS, 1)

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
	self:SetNextIdle( CurTime() + self.Owner:GetViewModel():SequenceDuration() + 0.1 )
end



function SWEP:CanShoot()
	return self:CanPrimaryAttack() and not self:GetBursting() and not (self.LoweredPos and self:IsSprinting()) and self:GetReloadTime() < CurTime()
end

function SWEP:ViewPunch()
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


function SWEP:CanReload()
	return self:Ammo1() > 0 and self:Clip1() < self.Primary.ClipSize
		and not self:GetReloading() and self:GetNextPrimaryFire() < CurTime()
end

function SWEP:Reload()
	if not self:CanReload() then return end

	self.Owner:DoReloadEvent()

	if not self.DoEmptyReloadAnim or self:Clip1() != 0 then
		self:PlayAnim(ACT_VM_RELOAD)
	else
		self:PlayAnim(ACT_VM_RELOAD_EMPTY)
	end
	self:QueueIdle()

	if self.ReloadSound then 
		self:EmitSound(self.ReloadSound)
	elseif self.OnReload then
		self.OnReload(self)
	end

	if self.ReloadWorldSound then
		if SERVER then self:EmitWorldSound(self.ReloadWorldSound) end 
	end

	self:SetReloading( true )
	self:SetReloadTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )

	hook.Run("LongswordWeaponReload", self.Owner, self)
end



function SWEP:FinishReload()
	self:SetReloading( false )

	local amount = math.min( self:GetMaxClip1() - self:Clip1(), self:Ammo1() )

	self:SetClip1( self:Clip1() + amount )
	self.Owner:RemoveAmmo( amount, self:GetPrimaryAmmoType() )
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
	
	--print(options)
	-- Disables animation based muzzle event
	return true

end