--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --


-- [ Shared Files Load First ] --
include("shared/base.lua")
include("shared/datatables.lua")
include("shared/anim.lua")
include("shared/attachment.lua")
include("shared/spread.lua")
include("shared/think.lua")
include("shared/worldmodel.lua")

-- [ Now Load Client Specific Files ] --
include("client/viewmodel.lua")
include("client/sound.lua")
include("client/fov.lua")
include("client/replacement.lua")
include("client/debug.lua")
include("client/crosshair.lua")


print("[Longsword²] Longsword² weapon base loaded. Version 2.0 Copyright 2019-2022 Jake Green (vin) and Nick S. (urnotnick)")