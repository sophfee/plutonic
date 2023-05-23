

function SWEP:GiveAttachment(attachment)
	if not self.Attachments[attachment] then return end
	self.EquippedAttachments[attachment] = true
	self:OnAttachmentEquip(attachment)

	if self.Attachments[attachment].ModSetup then
		self.Attachments[attachment].ModSetup(self)
	end

	if SERVER then
		net.Start("Plutonic.AttachmentEquip")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteString(attachment)
		net.Broadcast()
	end
end

function SWEP:TakeAttachment(attachment)
	if not self.Attachments[attachment] then return end
	self.EquippedAttachments[attachment] = nil
	self:OnAttachmentRemove(attachment)

	if self.Attachments[attachment].ModCleanup then
		self.Attachments[attachment].ModCleanup(self)
	end

	if SERVER then
		net.Start("Plutonic.AttachmentRemove")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteString(attachment)
		net.Broadcast()
	end
end

function SWEP:OnAttachmentEquip(attachment)
end

function SWEP:OnAttachmentRemove(attachment)
end