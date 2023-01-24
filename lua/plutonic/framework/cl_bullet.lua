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
    bullet.Callback = function(attacker, tr)
        if attacker.IsDeveloper then
            if attacker:IsDeveloper() then
                debugoverlay.Cross(tr.HitPos, 2, 3, Color(255, 0, 0), true)
            end
        end
    end

    self.Owner:FireBullets(bullet, SuppressHostEvents)
end