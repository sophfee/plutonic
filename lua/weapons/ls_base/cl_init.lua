--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

if (SERVER) then
	AddCSLuaFile()
	return
end

-- [ Shared Files Load First ] --
include("/shared/datatables.lua")

-- [ Now Load Client Specific Files ] --
include("/client/viewmodel.lua")
