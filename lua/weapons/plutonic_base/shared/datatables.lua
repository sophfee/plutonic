--      Copyright (c) 2022-2023, Nick S. All rights reserved      --
-- Plutonic is a project built for Landis Games. --

-- [ File Details ] --
-- Purpose: Datatables setup, misc.

function SWEP:SetupDataTables()
	
	-- QUESTION:
	-- Could we migrate to SYNC vars, if Longsword is running in the impulse Framework (or derived)?
	-- Could provide a decent bump in performance. (Nick S.)
	
	self:NetworkVar("Bool",   0, "Ironsights")
	self:NetworkVar("Bool",   1, "Reloading")
	self:NetworkVar("Bool",   2, "Bursting")
	self:NetworkVar("String", 0, "CurAttachment")
	self:NetworkVar("Float",  1, "IronsightsRecoil")
	self:NetworkVar("Float",  2, "Recoil")
	self:NetworkVar("Float",  3, "ReloadTime")
	self:NetworkVar("Float",  4, "NextIdle")

	if self.ExtraDataTables then
		self.ExtraDataTables(self)
	end
end
