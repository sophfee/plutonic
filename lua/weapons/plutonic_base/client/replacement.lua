--      Copyright (c) 2022-2023, Nick S. All rights reserved      --
-- Plutonic is a project built for Landis Games. --

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

plutonic_ReplacementEditor = plutonic_ReplacementEditor or nil

concommand.Add("longsword_replacement_editor", function()
    if not IsValid(plutonic_ReplacementEditor) then
        plutonic_ReplacementEditor = vgui.Create("longswordReplacementEditor", nil, "plutonic_ReplacementEditor")
    end
end)