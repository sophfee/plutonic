/**************************************************************************/
/*	shared/attachment.lua												  */
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

SWEP.EquippedAttachments = SWEP.EquippedAttachments or {}
SWEP.AttachmentEntCache = SWEP.AttachmentEntCache or {}
SWEP.Attachments = SWEP.Attachments or {}
function SWEP:HasAttachment(name)
	return self.EquippedAttachments[name] ~= nil
end

function SWEP:CanAttach(att)
	att = self.Attachments[att]
	if att == nil then
		print("[MS] [CanAttach::Fail] Attachment not found")

		return false
	end

	if att.Requires ~= nil then
		print("[MS] [CanAttach::Loop] Attachment has requirements")
		for k, v in pairs(att.Requires) do
			if not self:HasAttachment(k) then
				print("[MS] [CanAttach::Fail] Missing requirement: " .. k)

				return false
			end
		end
	end

	if att.Conflicts ~= nil then
		print("[MS] [CanAttach::Loop] Attachment has conflicts")
		for k, v in pairs(att.Conflicts) do
			if self:HasAttachment(k) then
				print("[MS] [CanAttach::Fail] Conflicts with: " .. k)

				return false
			end
		end
	end

	print("[MS] [CanAttach::Success] Attachment can be attached!")

	return true
end

function SWEP:CanDetach(attach)
	local att = self.Attachments[attach]
	if att == nil then
		print("[MS] [CanDetach::Fail] Attachment not found")

		return false
	end

	for k, v in pairs(self.EquippedAttachments) do
		print("[MS] [CanDetach::Loop] " .. k .. " is an equipped attachment")
		if k == attach then
			print("[MS] [CanDetach::Info] " .. k .. " is the attachment we're trying to detach (SKIP!)")
			continue
		end

		local atte = self.Attachments[k]
		if not atte then
			print("[MS] [CanDetach::Warn] " .. k .. " is not a valid attachment (SKIP!)")
			continue
		end

		if atte.Requires ~= nil then
			print("[MS] [CanDetach::Loop] " .. k .. " has requirements")
			for e, _ in pairs(atte.Requires) do
				print("[MS] [CanDetach::Loop] " .. k .. " requires " .. e)
				if e == attach then
					print("[MS] [CanDetach::Fail] " .. k .. " requires me! (CANNOT DETACT!)")

					return false
				end
			end
		end
	end

	print("[MS] [CanDetach::Success] " .. attach .. " can be detached!")

	return true
end