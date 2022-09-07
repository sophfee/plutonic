function SWEP:HasAttachment(name)
	return (self:GetCurAttachment() or "") == name
end

local wepMeta = FindMetaTable("Weapon")

function wepMeta:GiveAttachment(name)
	if not self.Attachments or not self.Attachments[name] then
		return
	end

	self:SetCurAttachment(name)

	if self.Attachments[name].ModSetup then
		self:SetupModifiers(name)
	end
end

function wepMeta:TakeAttachment(name)
	if not self.Attachments or not self.Attachments[name] then
		return
	end

	self:SetCurAttachment("")

	if self.Attachments[name].ModCleanup then
		self:RollbackModifiers(name)
	end
end

function SWEP:SetupModifiers(name)
	self.Attachments[name].ModSetup(self)
end

function SWEP:RollbackModifiers(name)
	self.Attachments[name].ModCleanup(self)
end