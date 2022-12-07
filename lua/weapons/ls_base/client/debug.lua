--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

CreateClientConVar("longsword_debug", "0", false, false)
CreateClientConVar("longsword_centered", "0", true, false, "Centers the viewmodel, DOOM style.",0,1)

surface.CreateFont("lsDebug", {
	font = "Consolas",
	size = 18,
	weight = 1000,
	antialias = true,
	shadow = true
})

local debugCol = Color(0, 255, 0, 200)
local ironFade = ironFade or 0
local GetConVar = GetConVar
local LocalPlayer = LocalPlayer
function SWEP:DrawHUD()
	local debugMode = GetConVar("longsword_debug")

	if (impulse_DevHud or debugMode:GetBool()) then
		local scrW = ScrW()
		local scrH = ScrH()
		local dev = GetConVar("developer"):GetInt()

		if dev == 0 then
			print("[longsword] Enabling 'developer 1'")
			LocalPlayer():ConCommand("developer 1")
		end

		surface.SetFont("lsDebug")
		surface.SetTextColor(debugCol)

		surface.SetTextPos(0, 0)
		surface.DrawText("[LONGSWORD DEBUG MODE ENABLED]")

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) - 20)
		surface.DrawText((self.PrintName or "PrintName ERROR").." [BDMG: "..(self.Primary.Damage or "?")..", RPM: "..(60 / (self.Primary.Delay or 0))..", SHOTS: "..(self.Primary.NumShots or "?").."]")

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2))
		surface.DrawText("Recoil: "..self:GetRecoil())

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 20)
		surface.DrawText("Ironsights Recoil: "..self:GetIronsightsRecoil())

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 40)
		surface.DrawText("Last Spread: "..(self.LastSpread or "[SHOOT WEAPON]"))


		if self.LastSpread then
			local perc = (self.LastSpread / self.Primary.Cone)
			surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 60)
			surface.SetTextColor(Color(255 * perc, 255 * (1 - perc), 0, 200))
			surface.DrawText((perc * 100).."% of Base Cone")
			surface.SetTextColor(debugCol)
		end

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 90)
		surface.DrawText("Is Ironsights: "..tostring(self:GetIronsights()))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 110)
		surface.DrawText("Is Bursting: "..tostring(self:GetBursting()))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 130)
		surface.DrawText("Is Reloading: "..tostring(self:GetReloading()))

		local ns = (self:GetNextPrimaryFire() or 0) - CurTime()
		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 150)
		surface.DrawText("Next Shot: "..(ns > 0 and ns or "CLEAR"))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 210)
		surface.DrawText("Warble: " .. tostring(self.VMWarble))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 230)
		surface.DrawText("Sway X: " .. tostring(self.VMDeltaX))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 250)
		surface.DrawText("Sway Y: " .. tostring(self.VMDeltaY))

		surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 270)
		surface.DrawText("TS Last Input: " .. tostring((self.LastInput or 0) - CurTime()))


		local attach = self:GetCurAttachment()

		if attach and attach != "" then
			surface.SetTextPos((scrW / 2) + 30, (scrH / 2) + 180)
			surface.DrawText("Attachment: "..self:GetCurAttachment())
		end
	end

	if self:HasAttachment("") then
		if self.scopedIn then
			self.scopedIn = false
		end
		return
	end

	local attachment = self:GetCurAttachment()

	if not self.Attachments[attachment] or self.Attachments[attachment].Behaviour != "sniper_sight" then
		if self.scopedIn then
			self.scopedIn = false
		end
		return
	end

	if not self:GetIronsights() then
		ironFade = 0
		self.scopedIn = false
		return
	end

	local scrw = ScrW()
	local scrh = ScrH()
	local ft = FrameTime()

	if ironFade != 1 and not self.scopedIn then
		ironFade = math.Clamp(ironFade + (ft * 2.6), 0, 1)

		surface.SetDrawColor(ColorAlpha(color_black, ironFade * 255))
		surface.DrawRect(0, 0, scrw, scrh)

		return
	else
		self.scopedIn = true
	end

	if self.scopedIn and ironFade != 0 then
		ironFade = math.Clamp(ironFade - (ft * 1), 0, 1)

		surface.SetDrawColor(ColorAlpha(color_black, ironFade * 255))
		surface.DrawRect(0, 0, scrw, scrh)
	end

	ls_StopHUDDraw = true

	local scopeh = scrh * 1
	local scopew = scopeh * 1.8
	local hw = (scrw * 0.5) - (scopew / 2)
	local hh = (scrh * 0.5) - (scopeh / 2)

	surface.SetDrawColor(color_black)
	surface.DrawRect(0, 0, scrw, hh)
	surface.DrawRect(0, 0, scrw - scopew, scrh)
	surface.DrawRect(scrw - hw, 0, scrw - scopew, scrh)
	surface.DrawRect(0, hh + scopeh, scrw, scrh)

	surface.SetDrawColor(self.Attachments[attachment].ScopeColour or color_white)
	surface.SetMaterial(self.Attachments[attachment].ScopeTexture)
	surface.DrawTexturedRect(hw, hh, scopew, scopeh)

	if self.Attachments[attachment].NeedsHDR then
		local hasHDR = GetConVar("mat_hdr_level"):GetInt() or 0

		if hasHDR == 0 then
			draw.SimpleText("WARNING!", "ChatFont", ScrW() * 0.5, ScrH() * 0.5, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("To see this scope, you must enable HDR in your settings.", "ChatFont", ScrW() * 0.5, (ScrH() * 0.5) + 20, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("Press ESC > Settings > Video > Advanced Settings > High Dynamic Range to FULL", "ChatFont", ScrW() * 0.5 , (ScrH() * 0.5) + 40, nil, TEXT_ALIGN_CENTER)
			draw.SimpleText("You will then have to rejoin.", "ChatFont", ScrW() * 0.5 , (ScrH() * 0.5) + 60, nil, TEXT_ALIGN_CENTER)
		end
	end

	if self.Attachments[attachment].ScopePaint then
		self.Attachments[attachment].ScopePaint(self)
	end
end

SWEP.SelectColor = Color( 255, 210, 0 )
SWEP.EmptySelectColor = Color( 255, 50, 0 )
function SWEP:DrawWeaponSelection()
end





hook.Add("ShouldDrawHUDBox", "longswordimpulseHUDStopDrawing", function()
	local v = tonumber(ls_StopHUDDraw or 1)
	ls_StopHUDDraw = false

	return tobool(v)
end)