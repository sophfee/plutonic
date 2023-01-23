Plutonic.Framework.FireBullets = function(bullet, SuppressHostEvents)
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
end