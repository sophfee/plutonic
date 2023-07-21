net.Receive("Plutonic.AttachmentEquip", function()
	local wep = Entity(net.ReadUInt(16))
	local own = Entity(net.ReadUInt(16))
	local att = net.ReadString()

	if not IsValid(wep) then return end
	if not wep.IsPlutonic then return end
	if IsValid(own) and own ~= LocalPlayer() then return end

	wep:Attach(att)

	if IsValid(Singularity_modstation) then
		Singularity_modstation:RefreshAttachments(wep)
	end
end)

net.Receive("Plutonic.AttachmentRemove", function()

	local wep = Entity(net.ReadUInt(16))
	local own = Entity(net.ReadUInt(16))
	local att = net.ReadString()

	print(wep, own, att)

	if not IsValid(wep) then return end
	if not wep.IsPlutonic then return end
	if IsValid(own) and own ~= LocalPlayer() then return end

	wep:Detach(att)

	if IsValid(Singularity_modstation) then
		Singularity_modstation:RefreshAttachments(wep)
	end
end)


Plutonic.RTSight = GetRenderTarget("plutonic_rtsight", ScrW(), ScrH(), false)
Plutonic.RTMaterial = CreateMaterial("plutonic_rtmaterial", "UnlitGeneric", {
	["$basetexture"] = Plutonic.RTSight:GetName(),
	["$translucent"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
})