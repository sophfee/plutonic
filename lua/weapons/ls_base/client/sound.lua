--      Copyright (c) 2022, Nick S. All rights reserved      --
-- Longsword2 is a project built upon Longsword Weapon Base. --

net.Receive("Longsword.EmitSound", function()
	local entity = net.ReadEntity()
	local owner = net.ReadEntity()
	local snd = net.ReadString()

	if owner == LocalPlayer() then
		local shouldPlay = impulse.GetSetting("view_thirdperson")

		if shouldPlay then
			entity:EmitSound(snd)
		end
	else
		entity:EmitSound(snd)
	end
end)
net.Receive("Longsword.Echo", function()
	local srcInside = net.ReadBool()
	local v__srcPos = net.ReadVector() 
	local srcEntity = net.ReadUInt(16)
	local snd = net.ReadString()

	local tr = util.TraceLine({
        start = LocalPlayer():EyePos(),
        endpos = LocalPlayer():EyePos() + Vector(0, 0, 10000),
        filter = function(ent)
            if ent:IsPlayer() then 
                return false 
            end

            return true
        end
    })

    local inside = true

    if tr.HitSky then
        inside = false
    end

	local shouldPlay = true

	if not inside and sourceInside then
		shouldPlay = false
	end

	if shouldPlay and inside then
		Entity( srcEntity ):EmitSound( snd, 140, 100, 0.4 )
	elseif shouldPlay and not inside then
		Entity( srcEntity ):EmitSound( snd, 140, 100, 1 )
	end
end)


function SWEP:InternalEchoHandle()

	--if not self.Reverb.Primary.Enabled then return end

	if not IsValid(self.Owner) then return end

	local tr = util.TraceLine({
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + Vector(0, 0, 10000),
        filter = function(ent)
            if ent:IsPlayer() then 
                return false 
            end

            return true
        end
    })

    local inside = true

    if tr.HitSky then
        inside = false
    end

	self:PrimaryEcho(inside)
end

function SWEP:PrimaryEcho(inside)
	surface.PlaySound(inside and self.Reverb.Primary.Indoor or self.Reverb.Primary.Outdoor)
end