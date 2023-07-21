AddCSLuaFile()
SWEP.Base = "plutonic_base"
function SWEP:Reload()
	if not self:CanReload() then return end
	self:PlayAnim(ACT_SHOTGUN_RELOAD_START)
	self:GetOwner():DoReloadEvent()
	self:QueueIdle()
	self:SetReloading(true)
	self:SetReloadTime(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
	if self.ReloadSound then
		self:EmitSound(self.ReloadSound)
	end

	hook.Run("LongswordWeaponReload", self:GetOwner(), self)
end

function SWEP:InsertShell()
	self:SetClip1(self:Clip1() + 1)
	self:GetOwner():RemoveAmmo(1, self:GetPrimaryAmmoType())
	self:PlayAnim(ACT_VM_RELOAD)
	self:QueueIdle()
	self:SetReloadTime(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
	if self.ReloadShellSound then
		self:EmitSound(self.ReloadShellSound)
	end
end

function SWEP:ReloadThink()
	if self:GetReloadTime() > CurTime() then return end
	if self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) > 0 and not self:GetOwner():KeyDown(IN_ATTACK) then
		self:InsertShell()
	else
		self:FinishReload()
	end
end

function SWEP:FinishReload()
	self:SetReloading(false)
	self:PlayAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self:SetReloadTime(CurTime() + self:GetOwner():GetViewModel():SequenceDuration())
	self:QueueIdle()
	if self.PumpSound then
		self:EmitSound(self.PumpSound)
	end
end