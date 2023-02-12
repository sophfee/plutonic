
function SWEP:CalculateSpread()
	local spread = self.Primary.Cone

	if self.Owner:IsNPC() then
		return spread
	end

	local maxSpeed = self.LoweredPos and self.Owner:GetWalkSpeed() or self.Owner:GetRunSpeed()

	spread = spread + self.Primary.Cone * math.Clamp( self.Owner:GetVelocity():Length2D() / maxSpeed, 0, self.Spread.VelocityMod )
	spread = spread + self:GetRecoil() * self.Spread.RecoilMod

	if not self.Owner:IsOnGround() then
		spread = spread * self.Spread.AirMod
	end

	if self.Owner:IsOnGround() and self.Owner:Crouching() then
		spread = spread * self.Spread.CrouchMod
	end

	if self:GetIronsights() then
		spread = spread * (self.Spread.IronsightsMod or 1)
	end

	spread = math.Clamp( spread, self.Spread.Min, self.Spread.Max )

	if CLIENT then
		self.LastSpread = Lerp(FrameTime() * 8, self.LastSpread or 0, spread)
	end

	return spread
end

function SWEP:AddRecoil()
	self:SetRecoil( math.Clamp( self:GetRecoil() + self.Primary.Recoil * 0.4, 0, self.Primary.MaxRecoil or 1 ) )
	self:DoRecoil()
end

SWEP.Primary.RecoilSide = 1
SWEP.Primary.RecoilUp = 1
SWEP.Primary.RecoilDown = 1

function SWEP:DoRecoil()
	local recoil = self:GetRecoil()

	local maxUp = self.Primary.RecoilUp * recoil
	local maxDown = self.Primary.RecoilDown * recoil
	local maxSide = self.Primary.RecoilSide * recoil

	local side = math.Rand( -maxSide, maxSide )
	local up = math.Rand( -maxDown, maxDown )

	self.Owner:ViewPunch( Angle( up, side, side * .34 ) )
end