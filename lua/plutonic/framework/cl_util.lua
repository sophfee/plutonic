--- The core level functionality of Plutonic.
-- @module Framework

--- Rotates a point around another point.
-- @realm client
-- @vector pos The position of the point to rotate.
-- @angle ang The angle of the point to rotate.
-- @vector point The point to rotate around.
-- @vector offset The offset of the point to rotate.
-- @angle offset_ang The angle of the offset of the point to rotate.
-- @treturn vector The rotated position.
-- @treturn angle The rotated angle.
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