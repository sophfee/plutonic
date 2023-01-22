function Plutonic.Framework.RotateAroundPoint(pos, ang, point, offset, offset_ang)

    local mat = Matrix()
    mat:SetTranslation(pos)
    mat:SetAngles(ang)

    mat:Translate(point)

    local rot_mat = Matrix()
    rot_mat:SetAngles(offset_ang)
    rot_mat:Invert()
    mat:Mul(rot_mat)

    mat:Translate(-point)

    mat:Translate(offset)
	
    return mat:GetTranslation(), mat:GetAngles()
end