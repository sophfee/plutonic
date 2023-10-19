/**************************************************************************/
/*	sv_bullet.lua											              */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)		  */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)		  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

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
		if self.CanBreachDoors and (impulse or impulse) and IsValid(tr.Entity) and tr.Entity:IsDoor() and tr.Entity:GetClass() == "prop_door_rotating" then
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

					timer.Simple(impulse.Config.ExplosionDoorRespawnTime, timerCallback)
				end

				local timerCallback = function()
					door:DoorUnlock()
					door:SetNotSolid(false)
					door:SetNoDraw(false)
					door.__BREACH_HEALTH = 80
					door.IsCharged = false
				end

				timer.Simple(impulse.Config.ExplosionDoorRespawnTime, timerCallback)
			end
		end
	end

	self:GetOwner():FireBullets(bullet, SuppressHostEvents)
end