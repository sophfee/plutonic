/**************************************************************************/
/*	client/attachment.lua											      */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)		  */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)		  */
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

function SWEP:Attach(att)
	-- backend
	self.EquippedAttachments[att] = true
	self:AttachmentEquipped(att)
	if self.Attachments[att].ModSetup then
		self.Attachments[att].ModSetup(self)
	end
end

function SWEP:Detach(att)
	-- backend
	self.EquippedAttachments[att] = nil
	self:AttachmentDetached(att)
	if self.Attachments[att].ModCleanup then
		self.Attachments[att].ModCleanup(self)
	end

	local attData = self.Attachments[att]
	if attData.Cosmetic and IsValid(self.AttachmentEntCache[att]) then
		self.AttachmentEntCache[att]:Remove()
		self.AttachmentEntCache[att] = nil
	end
end

function SWEP:AttachmentEquipped(att)
end

function SWEP:AttachmentDetached(att)
end