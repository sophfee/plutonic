--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

-- [ File Details ]
-- Purpose: Loads all files to their correct clients.
-- Todo: N/A

-- Shared Files (for Server)
include("shared/base.lua")
include("shared/datatables.lua")
include("shared/anim.lua")
include("shared/attachment.lua")
include("shared/spread.lua")
include("shared/think.lua")
include("shared/worldmodel.lua")
include("shared/reload.lua")

-- ServerSide Files
include("server/sound.lua")
include("server/echo.lua")

-- Shared Files (for Client)
AddCSLuaFile("shared/base.lua")
AddCSLuaFile("shared/datatables.lua")
AddCSLuaFile("shared/anim.lua")
AddCSLuaFile("shared/attachment.lua")
AddCSLuaFile("shared/spread.lua")
AddCSLuaFile("shared/think.lua")
AddCSLuaFile("shared/worldmodel.lua")
AddCSLuaFile("shared/reload.lua")

-- ClientSide Files
AddCSLuaFile("client/viewmodel.lua")
AddCSLuaFile("client/sound.lua")
AddCSLuaFile("client/fov.lua")
AddCSLuaFile("client/replacement.lua")
AddCSLuaFile("client/debug.lua")
AddCSLuaFile("client/crosshair.lua")
AddCSLuaFile("client/echo.lua")
print("[Longsword²] Longsword² weapon base loaded. Version 2.0 Copyright 2019-2022 Jake Green (vin) and Nick S. (urnotnick)")