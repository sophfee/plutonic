-- Separating for my fucking brains sake.
function SWEP:CanReload()
	if self.Owner:IsNPC() then
		return self:Clip1() < self.Primary.ClipSize
		and not self:GetReloading() and self:GetNextPrimaryFire() < CurTime()
	end

	return self:Ammo1() > 0 and (self:Clip1() > 0 and self:Clip1() < self.Primary.ClipSize + 1 or self:Clip1() < self.Primary.ClipSize )
		and not self:GetReloading() and self:GetNextPrimaryFire() < CurTime()
end

function SWEP:Reload()
	if not self:CanReload() then return end

	self.Owner:DoReloadEvent()

	if not self.DoEmptyReloadAnim or self:Clip1() != 0 then
		self:PlayAnim(ACT_VM_RELOAD)
	else
		self:PlayAnim(ACT_VM_RELOAD_EMPTY)
	end
	self:QueueIdle()

	if self.ReloadSound then 
		self:EmitSound(Sound(self.ReloadSound))
	elseif self.OnReload then
		self.OnReload(self)
	end

	if self.ReloadWorldSound then
		if SERVER then self:EmitWorldSound(self.ReloadWorldSound) end 
	end

	self:SetReloading( true )
	self:SetReloadTime( CurTime() + self.Owner:GetViewModel():SequenceDuration() )

	hook.Run("LongswordWeaponReload", self.Owner, self)
end



function SWEP:FinishReload()
	self:SetReloading( false )

    local amount

    -- one in the chamber
    if self:Clip1() == 0 then
        amount = math.min( self:GetMaxClip1() - self:Clip1(), self:Ammo1() )
    else
        amount = math.min( (self:GetMaxClip1() + 1) - self:Clip1(), self:Ammo1() )
    end

	self:SetClip1( self:Clip1() + amount )
	self.Owner:RemoveAmmo( amount, self:GetPrimaryAmmoType() )
end