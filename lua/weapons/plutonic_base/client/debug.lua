/**************************************************************************/
/*	client/debug.lua											          s*/
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

local debugCol = Color(12, 120, 255, 255)
local debugValue = Color(200, 200, 200, 255)
local ironFade = ironFade or 0
local GetConVar = GetConVar
local LocalPlayer = LocalPlayer
function SWEP:DrawHUD()

	if not Plutonic.DebugConvar:GetBool() then
		return
	end

	local line = 4

	Plutonic:DebugText("Plutonic", "Debug", 8, true)
	Plutonic:DebugText("Class Name", self.ClassName, 10)
	Plutonic:DebugText("Damage", self.Primary.Damage, 11)
	Plutonic:DebugText("Recoil", self.Primary.Recoil, 12)
	Plutonic:DebugText("RT", "Debug", 14, true)
	Plutonic:DebugText("rendertarget", tostring(self.ScopeRenderTarget), 16)
	Plutonic:DebugText("scope", tostring(self.ScopeRenderMaterial), 17)
	Plutonic:DebugText("drawing", tostring(self.VMIronsights >= 0.250), 18)
	Plutonic:DebugText("attachments", tostring(table.ToString(self.EquippedAttachments, nil, false)), 19)
	

	if self.Attachments then
		local hasScope = false
		for att, _ in pairs(self.EquippedAttachments) do
			if self.Attachments[att].Behavior == "sniper_scope" then
				hasScope = true
			end
		end

		if not hasScope then return end
	end

	if not self:GetIronsights() then
		ironFade = 0
		self.scopedIn = false

		return
	end

	local scrw = ScrW()
	local scrh = ScrH()
	local ft = FrameTime()
	if ironFade ~= 1 and not self.scopedIn then
		ironFade = math.Clamp(ironFade + (ft * 2.6), 0, 1)
		surface.SetDrawColor(ColorAlpha(color_black, ironFade * 255))
		surface.DrawRect(0, 0, scrw, scrh)

		return
	else
		self.scopedIn = true
	end

	if self.scopedIn and ironFade ~= 0 then
		ironFade = math.Clamp(ironFade - (ft * 1), 0, 1)
		surface.SetDrawColor(ColorAlpha(color_black, ironFade * 255))
		surface.DrawRect(0, 0, scrw, scrh)
	end

	plutonic_debug_StopHUDDraw = true
	local scopeh = scrh * 1
	local scopew = scopeh * 1.8
	local hw = (scrw * 0.5) - (scopew / 2)
	local hh = (scrh * 0.5) - (scopeh / 2)
	surface.SetDrawColor(color_black)
	surface.DrawRect(0, 0, scrw, hh)
	surface.DrawRect(0, 0, scrw - scopew, scrh)
	surface.DrawRect(scrw - hw, 0, scrw - scopew, scrh)
	surface.DrawRect(0, hh + scopeh, scrw, scrh)
	surface.SetDrawColor(self.Attachments[attachment].ScopeColor or color_white)
	surface.SetMaterial(self.Attachments[attachment].ScopeTexture)
	surface.DrawTexturedRect(hw, hh, scopew, scopeh)
	if self.Attachments[attachment].NeedsHDR then
		local hasHDR = GetConVar("mat_hdr_level"):GetInt() or 0
		if hasHDR == 0 then
			draw.SimpleText("WARNING!", "ChatFont", ScrW() * 0.5, ScrH() * 0.5, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("To see this scope, you must enable HDR in your settings.", "ChatFont", ScrW() * 0.5, (ScrH() * 0.5) + 20, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("Press ESC > Settings > Video > Advanced Settings > High Dynamic Range to FULL", "ChatFont", ScrW() * 0.5, (ScrH() * 0.5) + 40, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("You will then have to rejoin.", "ChatFont", ScrW() * 0.5, (ScrH() * 0.5) + 60, nil, TEXT_ALIGN_CENTER)
		end
	end

	if self.Attachments[attachment].ScopePaint then
		self.Attachments[attachment].ScopePaint(self)
	end
end

SWEP.SelectColor = Color(255, 210, 0)
SWEP.EmptySelectColor = Color(255, 50, 0)
function SWEP:DrawWeaponSelection()
end

hook.Add(
	"ShouldDrawHUDBox",
	"PlutonicHUDStopDrawing",
	function()
		local v = tonumber(plutonic_debug_StopHUDDraw or 1)
		plutonic_debug_StopHUDDraw = false

		return tobool(v)
	end
)

concommand.Add(
	"plutonic_debug_vm_bones",
	function(ply, cmd, args)
		for boneId = 1, ply:GetViewModel():GetBoneCount() do
			local bone = ply:GetViewModel():GetBoneName(boneId)
			print(boneId, bone)
		end
	end
)

concommand.Add("plutonic_debug_vm_attachments", function(ply, cmd, args)
	for k, v in pairs(ply:GetViewModel():GetAttachments()) do
		print(k, v.name, v.id)
		local att = ply:GetViewModel():GetAttachment(v.id)
		local pos, ang = att.Pos, att.Ang
		pos, ang = WorldToLocal(pos, ang, ply:EyePos(), ply:EyeAngles())
		print(pos, ang)
	end
end)

concommand.Add("plutonic_debug_vm_sequences", function(ply, cmd, args)
	print("\n--- SEQUENCE RAW DUMP ---")
	PrintTable(ply:GetViewModel():GetSequenceList())

	print("\n--- ACTIVITY NUM TO SEQUENCE DUMP ---")
	local vm = ply:GetViewModel()
	for i = 0, vm:GetSequenceCount() - 1 do
		local seq = vm:GetSequenceName(i)
		local act = vm:GetSequenceActivity(i)
		print(act, seq)
	end

	print("\n--- SEQUENCE LENGTHS ---")
	local data = {};
	local longest_name = 0;
	for i = 0, vm:GetSequenceCount() - 1 do
		local seq = vm:GetSequenceName(i)
		if #seq > longest_name then longest_name = #seq; end
		local len = vm:SequenceDuration(i);
		local set = {i, seq, len};
		table.insert(data, set);
	end

	for index, d in ipairs(data) do
		local fml = string.format("%.4f", d[3]);
		MsgC(d[2], string.rep(" ", longest_name - #d[2] + 1), fml, "\n")    
	end
end)