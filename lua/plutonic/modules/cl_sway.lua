local abs = math.abs
local Curtime = CurTime

Plutonic.Hooks.Add(
	"StartCommand",
	function(ply, ucmd)
		if ply.GetActiveWeapon then
			local wep = ply:GetActiveWeapon()

			if IsValid(wep) then
				if wep.IsPlutonic then
					local x, y = ucmd:GetMouseX(), ucmd:GetMouseY()
					local i = wep.SwayMultiplier or 0.001
					local n = wep.SwayMultiplier or 0.0056
					local m = wep:GetIronsights() and i or n

					if abs(x) > 0 or abs(y) > 0 then

						wep.VMDeltaX = wep.VMDeltaX + ucmd:GetMouseX() * m
						wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * m

						wep.VMDeltaXWeighted = wep.VMDeltaXWeighted + ucmd:GetMouseX() * .01
						wep.VMDeltaYWeighted = wep.VMDeltaYWeighted + ucmd:GetMouseY() * .01
					end
				end
			end
		end
	end
)
