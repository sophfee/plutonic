util.AddNetworkString("Longsword.EmitSound")
util.AddNetworkString("Longsword.Echo")
function SWEP:EmitWorldSound(snd)
	net.Start("Longsword.EmitSound")
	net.WriteEntity(self)
	net.WriteEntity(self.Owner)
	net.WriteString(snd)
	net.SendPAS(self:GetPos())
end