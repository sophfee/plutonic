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

Plutonic.Framework.FireBullets = function(self, bullet, SuppressHostEvents)
    local num_bullets = bullet.Num or 1
    local spread = bullet.Spread or Vector(0, 0, 0)
    local damage = bullet.Damage or 0

    bullet.Callback = function(attacker, tr)

        --ParticleEffect("muzzleflash_1", tr.StartPos, tr.HitNormal:Angle(), nil)

        if (self.Primary.Piercing or ALWAYS_PIERCE[tr.MatType]) and not pierce_shot then
                -- Find the exit point

            local exitPoint = util.TraceLine({
                start = tr.HitPos + tr.Normal * 16,
                endpos = tr.HitPos,
                filter = attacker,
                mask = MASK_SHOT
            })

            if exitPoint.Hit then
                local newbullet = {}
                    newbullet.Num 	= num_bullets
                    newbullet.Src 	= exitPoint.HitPos -- Source
                    newbullet.Dir 	= tr.Normal -- Dir of bullet
                    newbullet.Spread = spread
                    newbullet.Tracer	= 9999 -- Show a tracer on every x bullets
                    newbullet.Force	= 1 -- Amount of force to give to phys objects
                    newbullet.Damage	= damage / 1.6
                    newbullet.AmmoType = "Pistol"
                self.Owner:FireBullets(newbullet)
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

    self.Owner:FireBullets(bullet, SuppressHostEvents)
    
end