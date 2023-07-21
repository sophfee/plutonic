function SWEP:DrawWorldModel()
	if self.ExtraDrawWorldModel then
		self.ExtraDrawWorldModel(self)
	else
		self:DrawModel()
	end
	--[[
	local attachment = self:GetCurAttachment()

	if not self.Attachments or not self.Attachments[attachment] or not self.Attachments[attachment].Cosmetic then
		return
	end

	local attData = self.Attachments[attachment]

	if not IsValid(self.worldAttachment) then
		self.worldAttachment = ClientsideModel(attData.Cosmetic.Model, RENDERGROUP_TRANSLUCENT)
		self.worldAttachment:SetParent(self)
		self.worldAttachment:SetNoDraw(true)

		if attData.Cosmetic.Scale then
			self.worldAttachment:SetModelScale(attData.Cosmetic.Scale)
		end
	end

	local vm = self

	if attData.Cosmetic.PlayerParent then
		vm = self.Owner
	end

	local att = self.worldAttachment
	local c = attData.Cosmetic
	local w = c.World

	if not w then
		return
	end

	local bone = w.Bone and vm:LookupBone(w.Bone) or self:LookupBone("ValveBiped.Bip01_R_Hand")
	local m = vm:GetBoneMatrix(bone)

	local pos, ang = m:GetTranslation(), m:GetAngles()
	
	att:SetPos(pos + ang:Forward() * w.Pos.x + ang:Right() * w.Pos.y + ang:Up() * w.Pos.z)
	ang:RotateAroundAxis(ang:Up(), w.Ang.y)
	ang:RotateAroundAxis(ang:Right(), w.Ang.p)
	ang:RotateAroundAxis(ang:Forward(), w.Ang.r)
	att:SetAngles(ang)
	att:DrawModel()
	[[]]
end

hook.Add(
	"PostPlayerDraw",
	"PlutonicDrawWorldAttachment",
	function()
		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) then return end
		if IsValid(wep.worldAttachment) then
			wep.worldAttachment:DrawModel()
			wep.worldAttachment:SetRenderOrigin()
			wep.worldAttachment:SetRenderAngles()
		end
	end
)