--[[
=======================================
*   VT's Scrap Pool
*   
*   3D Math Module
=======================================
--]]

local vsp_math3d = {}
do
    function vsp_math3d.get_right(x)
        local matrix = x or GetTransform(x)
        return SetVector(matrix.right_x, matrix.right_y, matrix.right_z)
    end

    function vsp_math3d.get_up(x)
        local matrix = x or GetTransform(x)
        return SetVector(matrix.up_x, matrix.up_y, matrix.up_z)
    end

    function vsp_math3d.get_front(x)
        local matrix = x or GetTransform(x)
        return SetVector(matrix.front_x, matrix.front_y, matrix.front_z)
    end

    function vsp_math3d.get_posit(x)
        local matrix = x or GetTransform(x)
        return SetVector(matrix.posit_x, matrix.posit_y, matrix.posit_z)
    end

    --- Gets the angle in radians between two vectors
    --- @param v any
    --- @param w any
    --- @return number
    function vsp_math3d.get_angle(v, w)
        return math.acos(DotProduct(v, w) / (Length(v) * Length(w)))
    end

end
return vsp_math3d