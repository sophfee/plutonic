/**************************************************************************/
/*	server/attachments.lua											      */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)         */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)        */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

function SWEP:GiveAttachment(attachment)
	if not self.Attachments[attachment] then return end
	if not self:CanAttach(attachment) then return end
	self.EquippedAttachments[attachment] = true
	self:OnAttachmentEquip(attachment)
	if self.Attachments[attachment].ModSetup then
		self.Attachments[attachment].ModSetup(self)
	end

	if self:IsReliable() then
		net.Start("Plutonic.AttachmentEquip")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteUInt(self:GetOwner():EntIndex(), 16)
		net.WriteString(attachment)
		net.Broadcast()
	else
		self.QueuedAttachments = self.QueuedAttachments or {}
		self.QueuedAttachments[attachment] = true
	end
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
	net.WriteUInt(self:GetOwner():EntIndex(), 16)
	net.WriteString(attachment)
	net.Broadcast()
end

function SWEP:OnAttachmentEquip(attachment, uid)
	-- for HL2RP & others
	if impulse then
		hook.Run("PlayerEquipAttachment", self:GetOwner(), self, attachment)
	end
end

function SWEP:OnAttachmentRemove(attachment)
	-- for HL2RP & others
	if impulse then
		hook.Run("PlayerRemoveAttachment", self:GetOwner(), self, attachment)
	end
end