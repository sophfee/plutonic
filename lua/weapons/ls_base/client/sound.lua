--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

net.Receive("Longsword.EmitSound", function()
	local entity = net.ReadEntity()
	local owner = net.ReadEntity()
	local snd = net.ReadString()

	if owner == LocalPlayer() then
		local shouldPlay = impulse.GetSetting("view_thirdperson")

		if shouldPlay then
			entity:EmitSound(snd)
		end
	else
		entity:EmitSound(snd)
	end
end)