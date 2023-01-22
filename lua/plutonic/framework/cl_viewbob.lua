local abs,
	min,
	max,
	clamp,
	sin,
	cos,
	rad,
	deg,
	pi,
	pi2,
	round,
	Curtime,
	Frametime,
	Realtime,
	vec,
	ang,
	lerp,
	lerpAngle,
	lerpVector,
	approach =

	math.abs,
	math.min,
	math.max,
	math.Clamp,
	math.sin,
	math.cos,
	math.rad,
	math.deg,
	math.pi,
	math.pi * 2,
	math.Round,
	CurTime,
	FrameTime,
	RealTime,
	Vector,
	Angle,
	Lerp,
	LerpAngle,
	LerpVector,
	math.Approach

lerpSpeed = 0

function Plutonic.Framework.ViewModelBob(self, pos, ang)

	if self.CustomBob then
		return self:CustomBob(pos, ang)
	end

	local rt = Realtime()

	self.VMBobCycle = self.VMBobCycle or 0

	

	local alpha2 = sin(rt * 8.4 * 1.7 ) * (self.VMBobCycle)
	local alpha = sin(rt * 8.4 * 1 ) * self.VMBobCycle

	alpha = lerp(lerpSpeed, alpha, alpha2)
	alpha = (alpha / 3) + 0.5

	local bob = Plutonic.Interpolation.VectorBezierCurve(alpha, self.vBobIn, self.vBobMid, self.vBobOut)
	local abob = Plutonic.Interpolation.AngleBezierCurve(alpha, self.aBobIn, self.aBobMid, self.aBobOut)

	-- add a slight roll to the weapon
	--ang:RotateAroundAxis(ang:Forward(), alpha * -3)
	

	if self:GetIronsights() then
		bob = bob * ( self.VMIronsights * .08)
		abob = abob * (self.VMIronsights * .04)
	end

	bob = bob / lerp(lerpSpeed, 1, 1.7)
	abob = abob / lerp(lerpSpeed, 1, 1.7)

	pos = pos + ang:Right() * bob.x * self.VMBobCycle
	pos = pos + ang:Forward() * bob.y * self.VMBobCycle
	pos = pos + ang:Up() * bob.z * self.VMBobCycle
	local ovel = self.Owner:GetVelocity()
	local move = vec(ovel.x, ovel.y, 0)
	local vel = move:GetNormalized()
	local rd = self.Owner:GetRight():Dot(vel)
	local fd = (self.Owner:GetForward():Dot(vel) + 1) / 2

	self.VMRDBEF = self.VMRDBEF or 0 -- VM Right Direction Better Effect

	-- Additional effect on sidestepping
	self.VMRDBEF = lerp(Frametime() * 2.9, self.VMRDBEF, vel:Length2DSqr())

	ang:RotateAroundAxis(ang:Right(), abob.p * self.VMBobCycle)
	ang:RotateAroundAxis(ang:Forward(), abob.r * self.VMBobCycle)
	ang:RotateAroundAxis(ang:Up(), abob.y * self.VMBobCycle)

	ang:RotateAroundAxis(ang:Forward(), self.VMRDBEF * cos(rt * 8.4 * 1.7))
	ang:RotateAroundAxis(ang:Right(), (self.VMRDBEF / -8) * sin(rt * 8.4 * 1.7))

	--pos = pos + ang:Up() * (self.VMRDBEF / 18) * cos(rt * 8.4 * 1.7) * self.VMBobCycle

	-- added sin/cos effects, they add a nice effect to the weapon bobbing
	local alper = self:GetIronsights() and self.VMRDBEF / 8 or  self.VMRDBEF

	--[[pos = pos + ang:Right() * (alper / 11) * sin(rt * 8.4 * 1.7) * self.VMBobCycle
	pos = pos + ang:Forward() * (-alper * .59) * cos(rt * 8.4 * 1.7) * self.VMBobCycle

	ang:RotateAroundAxis(ang:Right(), (alper / 3) * sin(rt * 8.4 * 1.7) * self.VMBobCycle)
	ang:RotateAroundAxis(ang:Forward(), (-alper ) * cos(rt * 8.4 * 1.7 + 94.3) * self.VMBobCycle)
	ang:RotateAroundAxis(ang:Up(), (alper / -2) * sin(rt * 8.4 * 1.7 + 94.3) * self.VMBobCycle)
]]
	return pos, ang

end