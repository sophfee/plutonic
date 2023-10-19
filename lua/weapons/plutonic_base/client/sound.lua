/**************************************************************************/
/*	client/sound.lua													  */
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


local passthroughMaterials = {
	[MAT_GRATE] = true,
	[MAT_GLASS] = true,
	[MAT_FLESH] = true
}

net.Receive(
	"Longsword.EmitSound",
	function()
		local entity = net.ReadEntity()
		local owner = net.ReadEntity()
		local snd = net.ReadString()
		local dsp = 0
		if not IsValid(entity) then return end -- Edge case where entity is invalid
		if owner == LocalPlayer() then
			local shouldPlay = impulse and impulse.GetSetting("view_thirdperson", false)
			if shouldPlay then
				entity:EmitSound(snd, nil, nil, nil, nil, nil, dsp)
			end
		else
			if not IsValid(owner) then return end
			local tr = util.TraceLine(
				{
					start = LocalPlayer():EyePos(),
					endpos = LocalPlayer():EyePos() + Vector(0, 0, 10000),
					filter = function(ent)
						if ent:IsPlayer() then return false end

						return true
					end
				}
			)

			local inside = true
			if tr.HitSky and not passthroughMaterials[tr.MatType] then
				inside = false
			end

			-- trace to the owner
			tr = util.TraceLine(
				{
					start = LocalPlayer():EyePos(),
					endpos = owner:EyePos(),
					mask = MASK_BLOCKLOS
				}
			)

			local rHit = tr.Hit
			if tr.HitEntity == owner then
				rHit = false
			end

			if tr.Hit == LocalPlayer() then
				rHit = false
			end

			local sourceInSameRoom = false
			local rtr = util.TraceLine(
				{
					start = owner:EyePos(),
					endpos = owner:EyePos() + Vector(0, 0, 10000),
					mask = MASK_BLOCKLOS
				}
			)

			if rtr.HitSky and (not inside) then
				sourceInSameRoom = true
			end

			if rHit and not sourceInSameRoom and owner:GetPos():DistToSqr(LocalPlayer():GetPos()) < 900 ^ 2 then
				rHit = false
			end

			if rHit and inside then
				dsp = 31
			elseif inside then
				dsp = 0
			elseif rHit then
				dsp = 124
			else
				dsp = 0
			end

			entity:EmitSound(snd, nil, nil, nil, nil, nil, dsp)
		end
	end
)

net.Receive(
	"Longsword.Echo",
	function()
		local _ = net.ReadBool()
		local __ = net.ReadVector()
		local srcEntity = net.ReadUInt(16)
		local snd = net.ReadString()
		local tr = util.TraceLine(
			{
				start = LocalPlayer():EyePos(),
				endpos = LocalPlayer():EyePos() + Vector(0, 0, 10000),
				filter = function(ent)
					if ent:IsPlayer() then return false end

					return true
				end
			}
		)

		local inside = true
		if tr.HitSky then
			inside = false
		end

		local shouldPlay = true
		if shouldPlay and inside then
			Entity(srcEntity):EmitSound(snd, 140, 100, 0.4, CHAN_WEAPON, SND_NOFLAGS, 1)
		elseif shouldPlay and not inside then
			local ent = Entity(srcEntity)
			if ent:GetPos():DistToSqr(LocalPlayer():GetPos()) > 6000 ^ 2 then
				Entity(srcEntity):EmitSound(snd, 140, 100, 1, CHAN_WEAPON, SND_NOFLAGS, 1)
			end
		end
	end
)

function SWEP:InternalEchoHandle()
	--if not self.Reverb.Primary.Enabled then return end
	if not IsValid(self:GetOwner()) then return end
	local tr = util.TraceLine(
		{
			start = self:GetOwner():EyePos(),
			endpos = self:GetOwner():EyePos() + Vector(0, 0, 10000),
			filter = function(ent)
				if ent:IsPlayer() then return false end

				return true
			end
		}
	)

	local inside = true
	if tr.HitSky then
		inside = false
	end

	self:PrimaryEcho(inside)
end

function SWEP:PrimaryEcho(inside)
	if inside then
		self:EmitSound(self.Primary.Sound, 140, 100, 1, CHAN_WEAPON, SND_NOFLAGS, 104)
	else
		self:EmitSound(self.Primary.Sound, 140, 100, 1, CHAN_WEAPON, SND_NOFLAGS, 21)
	end
end