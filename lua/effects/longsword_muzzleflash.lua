function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local wpn = data:GetEntity()

    if !IsValid(wpn) then return end

    local muzzle = wpn.MuzzleEffect or wpn.IronsightsMuzzleFlash

    local att = data:GetAttachment() or 1

    local wm = false
	
	local Owner = wpn:GetOwner()
    if (LocalPlayer():ShouldDrawLocalPlayer() or Owner != LocalPlayer()) and !wpn.AlwaysWM then
        wm = true
        att = 1
    end

    if !wm then
        return
    end

    pos = (wpn:GetAttachment(att) or {}).Pos
    ang = (wpn:GetAttachment(att) or {}).Ang

    if gmmuzzle then
        if muzzle then
            if !pos then return end

            local fx = EffectData()

            fx:SetOrigin(pos)
            fx:SetEntity(parent)
            fx:SetAttachment(att)
            fx:SetNormal((ang or Angle(0, 0, 0)):Forward())
            fx:SetStart(pos)
            fx:SetScale(1)

            util.Effect(muzzle, fx)
        end
    else
        if muzzle then
            ParticleEffectAttach(muzzle, PATTACH_POINT_FOLLOW, wpn, att)
        end
    end

    if !pos then return end

    local light = DynamicLight(self:EntIndex())
    local clr =  wpn.MuzzleFlashColor or Color(244, 209, 66)
     if (light) then
        light.Pos = pos
        light.r = clr.r
        light.g = clr.g
        light.b = clr.b
        light.Brightness = 2
        light.Decay = 2500
        light.Size = Owner == LocalPlayer() and 256 or 128
        light.DieTime = CurTime() + 0.1
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
    return false
end