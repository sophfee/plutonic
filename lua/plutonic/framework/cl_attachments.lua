net.Receive("Plutonic.AttachmentEquip", function()
	local wep = Entity(net.ReadUInt(16))
	local att = net.ReadString()

	if not IsValid(wep) then return end
	if not wep.IsPlutonic then return end
	if wep:GetOwner() ~= LocalPlayer() then return end

	wep:Attach(att)

	if IsValid(impulse_modstation) then
		impulse_modstation:RefreshAttachments(wep)
	end
end)

net.Receive("Plutonic.AttachmentRemove", function()
	local wep = Entity(net.ReadUInt(16))
	local att = net.ReadString()

	if not IsValid(wep) then return end
	if not wep.IsPlutonic then return end
	if wep:GetOwner() ~= LocalPlayer() then return end

	wep:Detach(att)

	if IsValid(impulse_modstation) then
		impulse_modstation:RefreshAttachments(wep)
	end
end)