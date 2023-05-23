net.Receive("Plutonic.AttachmentEquip", function()
	local wep = Entity(net.ReadUInt(16))
	local att = net.ReadString()

	if not IsValid(wep) then return end
	if not wep.IsPlutonic then return end

	wep:Attach(att)
end)

net.Receive("Plutonic.AttachmentRemove", function()
	local wep = Entity(net.ReadUInt(16))
	local att = net.ReadString()

	if not IsValid(wep) then return end
	if not wep.IsPlutonic then return end

	wep:Detach(att)
end)