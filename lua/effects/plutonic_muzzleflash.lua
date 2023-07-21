function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local wpn = data:GetEntity()
    if not IsValid(wpn) then return end
    local muzzle = wpn.MuzzleEffect or wpn.IronsightsMuzzleFlash
    local att = data:GetAttachment() or 1
    local wm = false
    local Owner = wpn:GetOwner()
    if (LocalPlayer():ShouldDrawLocalPlayer() or Owner ~= LocalPlayer()) and not wpn.AlwaysWM then
        wm = true
        att = 1
    end

    pos = (wpn:GetAttachment(att) or {}).Pos
    ang = (wpn:GetAttachment(att) or {}).Ang
    if gmmuzzle then
        if muzzle and wm then
            if not pos then return end
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
        if muzzle and wm then
            ParticleEffectAttach(muzzle, PATTACH_POINT_FOLLOW, wpn, att)
        end
    end

    if not pos then return end
    local light = DynamicLight(self:EntIndex())
    local clr = wpn.MuzzleFlashColor or Color(244, 209, 66)
    if light then
        light.Pos = pos
        light.r = clr.r
        light.g = clr.g
        light.b = clr.b
        light.Brightness = wpn.MuzzleFlashBrightness or 4
        light.Decay = 5000
        light.Size = Owner == LocalPlayer() and (wpn.MuzzleFlashLocalSize or wpn.MuzzleFlashSize or 128) or (wpn.MuzzleFlashSize or 128)
        light.DieTime = CurTime() + 0.1
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
    return false
end