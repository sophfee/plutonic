/**************************************************************************/
/*	cl_init.lua											      		  	  */
/**************************************************************************/
/*                      This file is a part of PLUTONIC                   */
/*                              (c) 2022-2023                             */
/*                  Written by Sophie (github.com/sophfee)                */
/**************************************************************************/
/* Copyright (c) 2022-2023 Sophie S. (https://github.com/sophfee)         */
/* Copyright (c) 2019-2021 Jake Green (https://github.com/vingard)        */
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

-- [ Shared Files Load First ] --
include("shared/base.lua")
include("shared/datatables.lua")
include("shared/anim.lua")
include("shared/attachment.lua")
include("shared/spread.lua")
include("shared/think.lua")
include("shared/worldmodel.lua")
include("shared/reload.lua")
-- [ Now Load Client Specific Files ] --
include("client/viewmodel.lua")
include("client/sound.lua")
include("client/fov.lua")
include("client/debug.lua")
include("client/crosshair.lua")
include("client/ammoindicator.lua")
include("client/attachment.lua")
Plutonic.Constants.Logo = [[////////////////////////////////////////////////////////
  _____  _     _    _ _______ ____  _   _ _____ _____ 
 |  __ \| |   | |  | |__   __/ __ \| \ | |_   _/ ____|
 | |__) | |   | |  | |  | | | |  | |  \| | | || |     
 |  ___/| |   | |  | |  | | | |  | | . ` | | || |     
 | |    | |___| |__| |  | | | |__| | |\  |_| || |____ 
 |_|    |______\____/   |_|  \____/|_| \_|_____\_____|
                                                      
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

Plutonic is a project built for Landis Games.
Version: 1.2.0
Build: 365

////////////////////////////////////////////////////////]]
Plutonic.Constants.LogoColor = Color(10, 120, 255)
Plutonic.Constants.LogoTextColor = Color(255, 200, 0)
for i, line in ipairs(string.Explode("\n", Plutonic.Constants.Logo)) do
	if i >= 10 and i <= 13 then
		MsgC(Plutonic.Constants.LogoTextColor, line .. "\n")
	else
		MsgC(Plutonic.Constants.LogoColor, line .. "\n")
	end
end

function SWEP:OnReloaded()
	self:Initialize()

	-- Refresh attachments
	for att, equipped in pairs(self.EquippedAttachments) do
		if equipped then
			self.Attachments[att].ModSetup(self, att, true)
		end
	end
end