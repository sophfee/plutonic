-- Ballistics used for long range shit yknow

Longsword.Ballistics = {}
Longsword.BallisticStep = 16

function Longsword.LaunchBallistic(weapon, player, targetPos, aimVec)

	
end

hook.Add("PlayerPostThink", "Longsword.Ballistics.Core", function(ply)
	if Longsword.Ballistics[ply] then

		for k, v in pairs(Longsword.Ballistics[ply]) do
			local weapon = v.weapon
			local targetPos = v.targetPos
			local currentPos = v.currentPos
			local aimVec = v.aimVec

			local trace = util.TraceLine({
				start = player:GetShootPos(),
				endpos = player:GetShootPos() + aimVec * 100000,
				filter = player
			})

		end
	end
end)