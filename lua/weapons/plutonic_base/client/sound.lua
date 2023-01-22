--      Copyright (c) 2022-2023, Nick S. All rights reserved      --
-- Plutonic is a project built for Landis Games. --

net.Receive("Longsword.EmitSound", function()
	local entity = net.ReadEntity()
	local owner = net.ReadEntity()
	local snd = net.ReadString()

	if owner == LocalPlayer() then
		local shouldPlay = impulse and impulse.GetSetting("view_thirdperson") or true

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

	if shouldPlay and inside then
		
		Entity( srcEntity ):EmitSound( snd, 140, 100, 0.4, CHAN_WEAPON, SND_NOFLAGS, 1 )
		
	elseif shouldPlay and not inside then
		local ent = Entity( srcEntity )
		if ent:GetPos():DistToSqr(LocalPlayer():GetPos()) > 6000^2 then
			Entity( srcEntity ):EmitSound( snd, 140, 100, 1, CHAN_WEAPON, SND_NOFLAGS, 1 )
		end
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
	if inside then
		self:EmitSound( self.Primary.Sound, 140, 100, 1, CHAN_WEAPON, SND_NOFLAGS, 104)
	else
		self:EmitSound( self.Primary.Sound, 140, 100, 1, CHAN_WEAPON, SND_NOFLAGS, 21)
	end
end