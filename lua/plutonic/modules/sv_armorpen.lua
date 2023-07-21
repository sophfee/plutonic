-- Armor Penetration
Plutonic.Hooks.Add(
	"ScalePlayerDamage",
	function(ply, hitgroup, dmg)
		if ply:Armor() == 0 then return end
		local attacker = dmg:GetAttacker()
		if IsValid(attacker) and attacker:IsPlayer() then
			local wep = attacker:GetActiveWeapon()
			if IsValid(wep) and wep.Primary and wep.Primary.PenetrationScale then
				dmg:ScaleDamage(wep.Primary.PenetrationScale)
			end
		end
	end
)