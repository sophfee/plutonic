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
					local m = wep:GetIronsights() and 0.001 or 0.0056

					if abs(x) > 0 or abs(y) > 0 then
						if abs(x * m) > 1 then
							wep.LastInput = Curtime() 
						end

						wep.VMDeltaX = wep.VMDeltaX + ucmd:GetMouseX() * m
						wep.VMWiggly = wep.VMWiggly + ucmd:GetMouseX() * (m * 1.045)
						wep.VMDeltaY = wep.VMDeltaY + ucmd:GetMouseY() * m
					end
				end
			end
		end
	end
)
