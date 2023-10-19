/**************************************************************************/
/*	shared/worldmodel.lua											      */
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