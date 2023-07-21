local ALWAYS_PIERCE = {
	[MAT_GLASS] = true,
	[MAT_VENT] = true,
	[MAT_GRATE] = true
}

-- 
Plutonic.Framework.FireBullets = function(self, bullet, SuppressHostEvents)
	local num_bullets = bullet.Num or 1
	local spread = bullet.Spread or Vector(0, 0, 0)
	local damage = bullet.Damage or 0
	bullet.Callback = function(attacker, tr)
		--ParticleEffect("muzzleflash_1", tr.StartPos, tr.HitNormal:Angle(), nil)
		if (self.Primary.Piercing or ALWAYS_PIERCE[tr.MatType]) and not pierce_shot then
			-- Find the exit point
			local exitPoint = util.TraceLine(
				{
					start = tr.HitPos + tr.Normal * 16,
					endpos = tr.HitPos,
					filter = attacker,
					mask = MASK_SHOT
				}
			)

			if exitPoint.Hit then
				local newbullet = {}
				newbullet.Num = num_bullets
				newbullet.Src = exitPoint.HitPos -- Source
				newbullet.Dir = tr.Normal -- Dir of bullet
				newbullet.Spread = spread
				newbullet.Tracer = 9999 -- Show a tracer on every x bullets
				newbullet.Force = 1 -- Amount of force to give to phys objects
				newbullet.Damage = damage / 1.6
				newbullet.AmmoType = "Pistol"
				self:GetOwner():FireBullets(newbullet)
			end
		end

		util.ParticleTracerEx("Tracer", tr.StartPos, tr.HitPos, true, self:EntIndex(), 1)
		if self.CanBreachDoors and Singularity and IsValid(tr.Entity) and tr.Entity:IsDoor() and tr.Entity:GetClass() == "prop_door_rotating" then
			local door = tr.Entity
			--print("hi smile")
			--print(door)
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
					fakeDoor:SetModel(door:GetModel())
					fakeDoor:SetPos(door:GetPos())
					fakeDoor:SetAngles(door:GetAngles())
					fakeDoor:SetSkin(door:GetSkin())
					fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD)
					fakeDoor:Spawn()
					fakeDoor:GetPhysicsObject():SetVelocity(attacker:GetForward() * 250)
					local timerCallback = function()
						fakeDoor:Remove()
					end

					timer.Simple(Singularity.Config.ExplosionDoorRespawnTime, timerCallback)
				end

				local timerCallback = function()
					door:DoorUnlock()
					door:SetNotSolid(false)
					door:SetNoDraw(false)
					door.__BREACH_HEALTH = 80
					door.IsCharged = false
				end

				timer.Simple(Singularity.Config.ExplosionDoorRespawnTime, timerCallback)
			end
		end
	end

	self:GetOwner():FireBullets(bullet, SuppressHostEvents)
end