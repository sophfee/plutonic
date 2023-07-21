--      Copyright (c) 2022-2023, sophie S. All rights reserved      --
-- Plutonic is a project built for Landis Games. --
CreateClientConVar("plutonic_debug", "0", false, false)
CreateClientConVar("plutonic_centered", "0", true, false, "Centers the viewmodel, DOOM style.", 0, 1)
surface.CreateFont(
	"PlutonicDebugSimple",
	{
		font = "Segoe UI Black",
		size = 14,
		weight = 1000,
		antialias = true,
		shadow = true
	}
)

surface.CreateFont(
	"PlutonicDebugUnSimple",
	{
		font = "Segoe UI Black",
		size = 32,
		weight = 1000,
		antialias = true,
		shadow = true
	}
)

local debugCol = Color(12, 120, 255, 255)
local debugValue = Color(200, 200, 200, 255)
local ironFade = ironFade or 0
local GetConVar = GetConVar
local LocalPlayer = LocalPlayer
function SWEP:DrawHUD()
	local debugMode = GetConVar("plutonic_debug")
	if Singularity_DevHud or debugMode:GetBool() then
		local scrW = 68
		local scrH = 292
		local dev = GetConVar("developer"):GetInt()
		if dev == 0 then
			LocalPlayer():ConCommand("developer 1")
		end

		surface.SetFont("PlutonicDebugUnSimple")
		surface.SetTextColor(debugCol)
		surface.SetTextPos(64, 96)
		surface.DrawText("[PLUTONIC v1.0.0]")
		surface.SetFont("PlutonicDebugSimple")
		surface.SetTextPos(64, 128)
		surface.DrawText("Debug Mode Enabled!")
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) - 0)
		surface.DrawText((self.PrintName or "PrintName ERROR") .. " [BDMG: " .. (self.Primary.Damage or "?") .. ", RPM: " .. (60 / (self.Primary.Delay or 0)) .. ", SHOTS: " .. (self.Primary.NumShots or "?") .. "]")
		surface.SetTextColor(debugCol)
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 15)
		surface.DrawText("Recoil: ")
		surface.SetTextColor(debugValue)
		surface.DrawText(tostring(math.Round(self.Recoil or 0, 4)))
		surface.SetTextColor(debugCol)
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 30)
		surface.DrawText("Spread: ")
		surface.SetTextColor(debugValue)
		surface.DrawText(tostring(math.Round(self.LastSpread or 0, 4)))
		--surface.DrawText("Last Spread: "..math.Round(self.LastSpread or "[SHOOT WEAPON]", 4))
		if self.LastSpread then
			surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 45)
			surface.SetTextColor(debugCol)
			surface.DrawText("Cone: ")
			surface.SetTextColor(debugValue)
			local perc = self.LastSpread / self.Primary.Cone
			surface.DrawText(math.floor(perc * 100) .. "% of Base Cone")
			--
		end

		local ns = (self:GetNextPrimaryFire() or 0) - CurTime()
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 105)
		surface.DrawText("Next Shot: " .. (ns > 0 and ns or "CLEAR"))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 120)
		surface.DrawText("VMBobCycle Oscillation: " .. tostring(self.VMBobCycle))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 135)
		surface.DrawText("VMBetterVis Oscillation: " .. math.Round(tostring(self.VMRDBEF), 8))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 150)
		surface.DrawText("VMBlocked: " .. tostring(self.VMBlocked))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 165)
		surface.DrawText("VMVel: " .. tostring(math.Round(self.VMVel, 4)))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 180)
		surface.DrawText("VMIronsightsFraction: " .. tostring(self.VMIronsights))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 195)
		surface.DrawText("VMSprint: " .. tostring(self.VMSprint))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 210)
		surface.DrawText("Attachments: " .. table.concat(self.AttachmentEntCache, ", "))
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 225)
		surface.DrawText("VMRecoilAng: " .. tostring(self.VMRecoilAng))
	end

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
	"PlutonicSingularityHUDStopDrawing",
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

concommand.Add(
	"plutonic_debug_vm_attachments",
	function(ply, cmd, args)
		PrintTable(ply:GetViewModel():GetAttachments())
	end
)