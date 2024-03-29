AddCSLuaFile()
SWEP.Base = "plutonic_base"
SWEP.Projectile = {}
function SWEP:PrimaryAttack()
	if self:Clip1() < 1 then
		self:SetNextPrimaryFire(CurTime() + 1)

		return
	end

	if self.Primary.ThrowDelay then
		timer.Simple(
			self.Primary.ThrowDelay,
			function()
				if IsValid(self) then
					self:ThrowAttack()
					self:ViewPunch()
					if self:Clip1() < 1 then
						self:GetOwner():StripWeapon(self:GetClass())
					end
				end
			end
		)
	else
		self:ThrowAttack()
		self:ViewPunch()
	end

	if self.Primary.Sound ~= "" then
		self:EmitSound(self.Primary.Sound)
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self.DoFireAnim then
		self:PlayAnim(ACT_VM_PRIMARYATTACK)
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	else
		self:SendWeaponAnim(ACT_VM_THROW)
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		self:SendWeaponAnim(ACT_VM_DRAW)
	end

	if self:Clip1() < 1 then
		if self.PairedItem then
			if self:GetOwner():HasInventoryItemSpecific(self.PairedItem) then
				self:GetOwner():TakeInventoryItem(self.PairedItem)
			end
		else
			self:GetOwner():StripWeapon(self:GetClass())
		end
	end
end

function SWEP:Think()
	if CLIENT then
		self:ViewmodelThink()
	end

	self:IdleThink()
end

function SWEP:Reload()
	return
end

function SWEP:ThrowAttack()
	if CLIENT then return end
	self:TakePrimaryAmmo(1)
	local projectile = ents.Create("plutonic_projectile")
	projectile:SetModel(self.Projectile.Model)
	projectile.Owner = self:GetOwner()
	local pos = self:GetOwner():GetShootPos()
	pos = pos + self:GetOwner():GetForward() * 2
	pos = pos + self:GetOwner():GetRight() * 3
	pos = pos + self:GetOwner():GetUp() * -3
	projectile:SetPos(pos)
	if self.Projectile.Timer then
		projectile.Timer = CurTime() + self.Projectile.Timer
	end

	if self.Projectile.Touch then
		projectile.ProjTouch = self.Projectile.Touch
	end

	if self.ProjectileFire then
		projectile.OnFire = self.ProjectileFire
	end

	if self.ProjectileThink then
		projectile.ProjThink = self.ProjectileThink
	end

	if self.ProjectileRemove then
		projectile.ProjRemove = self.ProjectileRemove
	end

	if self.Projectile.FireSound then
		projectile.FireSound = self.Projectile.FireSound
	end

	if self.Projectile.HitSound then
		projectile.HitSound = self.Projectile.HitSound
	end

	if self.Projectile.RemoveWait then
		projectile.RemoveWait = self.Projectile.RemoveWait
	end

	projectile:SetOwner(self:GetOwner())
	projectile:Spawn()
	local force = 700
	if self:GetOwner():KeyDown(IN_FORWARD) then
		force = 1000
	elseif self:GetOwner():KeyDown(IN_BACK) then
		force = 600
	end

	if self.Projectile.ForceMod then
		force = force * self.Projectile.ForceMod
	end

	local phys = projectile:GetPhysicsObject()
	if not IsValid(phys) then return end
	if self.Projectile.Mass then
		phys:SetMass(self.Projectile.Mass)
	end

	phys:ApplyForceCenter(self:GetOwner():GetAimVector() * force * 2 + Vector(0, 0, 0))
	phys:AddAngleVelocity(Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500)))
end