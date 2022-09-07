--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

-- Replacement GUI
local PANEL = {}

function PANEL:Init()
    -- Setup viewport window.
    self.SetSize(self, 500, 400)
    self.SetTitle(self, "Longsword Replacement Editor")
    self.Center(self)
    self.MakePopup(self)
end

vgui.Register("longswordReplacementEditor", PANEL, "DFrame")

LS_ReplacementEditor = LS_ReplacementEditor or nil

concommand.Add("longsword_replacement_editor", function()
    if not IsValid(LS_ReplacementEditor) then
        LS_ReplacementEditor = vgui.Create("longswordReplacementEditor", nil, "LS_ReplacementEditor")
    end
end)