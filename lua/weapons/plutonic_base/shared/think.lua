function SWEP:IdleThink()
	if self:GetNextIdle() == 0 then return end

	if CurTime() > self:GetNextIdle() then
		self:SetNextIdle( 0 )
		self:SendWeaponAnim( self:Clip1() > 0 and ACT_VM_IDLE or ACT_VM_IDLE_EMPTY )
	end
end

function SWEP:Think()

	if CLIENT then
		self:ViewmodelThink()
		self:OffsetThink()
	end

	self:IronsightsThink()
	self:RecoilThink()
	self:IdleThink()
	if self.CustomThink then
		self.CustomThink(self)
	end

	if self:GetBursting() then self:BurstThink() end
	if self:GetReloading() then self:ReloadThink() end

	if not CLIENT then
		return
	end



	local attach = self:GetCurAttachment()
	self.KnownAttachment = self.KnownAttachment or ""
	
	if self.KnownAttachment != attach and attach != "" then
		self.KnownAttachment = attach
		self:SetupModifiers(attach)
	elseif self.KnownAttachment != attach then
		self:RollbackModifiers(self.KnownAttachment)
		self.KnownAttachment = attach
	end
end

function SWEP:RecoilThink()
	self:SetRecoil( math.Clamp( self:GetRecoil() - FrameTime() * (self.Primary.RecoilRecoveryRate or 1.4), 0, self.Primary.MaxRecoil or 1 ) )
end

function SWEP:BurstThink()
	if self.Burst and (self.nextBurst or 0) < CurTime() then
		self:TakePrimaryAmmo(1)

		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self:CalculateSpread())

		self:AddRecoil()
		self:ViewPunch()

		self:EmitSound(self.Primary.Sound)

		self.Burst = self.Burst - 1

		if self.Burst < 1 then
			self:SetBursting(false)
			self.Burst = nil
		else
			self.nextBurst = CurTime() + self.Primary.Delay
		end	
	end
end

-- ADS noises
sound.Add({
	name = "Plutonic.ADS.In",
	sound = {
		"weapons/ins2/uni/uni_ads_in_01.wav",
		"weapons/ins2/uni/uni_ads_in_02.wav",
		"weapons/ins2/uni/uni_ads_in_03.wav",
		"weapons/ins2/uni/uni_ads_in_04.wav",
		"weapons/ins2/uni/uni_ads_in_05.wav",
		"weapons/ins2/uni/uni_ads_in_06.wav"
	},
	level = 60,
	channel = CHAN_AUTO,
	pitch = {95,105}
})

sound.Add({
	name = "Plutonic.ADS.Out",
	sound = {
		"weapons/ins2/uni/uni_ads_out_01.wav"
	},
	level = 60,
	channel = CHAN_AUTO,
	pitch = {95,105}
})

function SWEP:IronsightsThink()
	if (self.CanDecreaseBlowback or 0) < CurTime() then
		self:SetIronsightsRecoil( math.Clamp( self:GetIronsightsRecoil() - (FrameTime() * 600), 0, 1) )
	end

	if not self:CanIronsight() then
		self:SetIronsights( false )
		return
	end

	if self.Owner:KeyDown( IN_ATTACK2 ) and not self:GetIronsights() then
		self:SetIronsights( true )
		self:EmitSound("Plutonic.ADS.In")
	elseif not self.Owner:KeyDown( IN_ATTACK2 ) and self:GetIronsights() then
		self:SetIronsights( false )
		self:EmitSound("Plutonic.ADS.Out")
	end
end
function SWEP:ReloadThink()
	if self:GetReloadTime() < CurTime() then self:FinishReload() end
end