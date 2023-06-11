

function SWEP:GiveAttachment(attachment)
	if not self.Attachments[attachment] then return end

	local AttachmentData = self.Attachments[attachment]

	if not self:CanAttach(attachment) then return end
	
	self.EquippedAttachments[attachment] = true
	self:OnAttachmentEquip(attachment)

	if self.Attachments[attachment].ModSetup then
		self.Attachments[attachment].ModSetup(self)
	end

	net.Start("Plutonic.AttachmentEquip")
	net.WriteUInt(self:EntIndex(), 16)
	net.WriteString(attachment)
	net.Broadcast()
end

function SWEP:TakeAttachment(attachment)
	if not self.Attachments[attachment] then return end

	-- If the attachment is required by another attachment, we can't remove it
	if not self:CanDetach(attachment) then return end

	self.EquippedAttachments[attachment] = nil
	self:OnAttachmentRemove(attachment)

	if self.Attachments[attachment].ModCleanup then
		self.Attachments[attachment].ModCleanup(self)
	end

	net.Start("Plutonic.AttachmentRemove")
	net.WriteUInt(self:EntIndex(), 16)
	net.WriteString(attachment)
	net.Broadcast()
end

function SWEP:OnAttachmentEquip(attachment, uid)
	-- for HL2RP & others
	if impulse then
		hook.Run("PlayerEquipAttachment", self.Owner, self, attachment)
	end
end

function SWEP:OnAttachmentRemove(attachment)
	-- for HL2RP & others
	if impulse then
		hook.Run("PlayerRemoveAttachment", self.Owner, self, attachment)
	end
end