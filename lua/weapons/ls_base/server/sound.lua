util.AddNetworkString("Longsword.EmitSound")
function SWEP:EmitWorldSound(snd)
	net.Start("Longsword.EmitSound")
	net.WriteEntity(self)
	net.WriteEntity(self.Owner)
	net.WriteString(snd)
	net.SendPAS(self:GetPos())
end