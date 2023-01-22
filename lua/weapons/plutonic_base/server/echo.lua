-- This forwards all our other hooks
function SWEP:InternalEchoHandle()

	--if not self.Reverb.Primary.Enabled then return end

	if not IsValid(self.Owner) then return end

	local tr = util.TraceLine({
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + Vector(0, 0, 10000),
        filter = function(ent)
            if ent:IsPlayer() then 
                return false 
            end

            return true
        end
    })

    local inside = true

    if tr.HitSky then
        inside = false
    end

	self:PrimaryEcho(inside)
end

function SWEP:PrimaryEcho(inside)
	local rf = RecipientFilter()
	rf:AddAllPlayers()
	rf:RemovePlayer(self.Owner)

	local pos = self.Owner:GetPos()
	local maxDist = inside and self.Reverb.Primary.IndoorRange ^ 2 or self.Reverb.Primary.OutdoorRange ^ 2

	for _, ply in ipairs(rf:GetPlayers()) do
		if ply:GetPos():DistToSqr( pos ) > maxDist then
			rf:RemovePlayer( ply )
		end
	end

	net.Start("Longsword.Echo")
	net.WriteBool(inside)
	net.WriteVector(self.Owner:GetPos())
	net.WriteUInt(self.Owner:EntIndex(), 16)
	net.WriteString(self.Primary.Sound)
	net.Send( rf )
end