net.Receive("Longsword.Echo", function()
	local ply = net.ReadUInt(8)
	local snd = net.ReadString()

	surface.PlaySound( snd )
end)
