--[[
=======================================
*   VT's Scrap Pool
*   
*   3D Math Module
=======================================
--]]

local vsp_math3d = {}
do
    vsp_math3d.north = SetVector(0, 0, 1)
    vsp_math3d.east = SetVector(1, 0, 0)
    vsp_math3d.south = SetVector(0, 0, -1)
    vsp_math3d.west = SetVector(-1, 0, 0)

    vsp_math3d.up = SetVector(0, 1, 0)
    vsp_math3d.down = SetVector(0, -1, 0)

    --- SetMatrix() with fixed parameter order
    --- @return any matrix
    function vsp_math3d.set_matrix(right_x, right_y, right_z,
        up_x, up_y, up_z,
        front_x, front_y, front_z,
        posit_x, posit_y, posit_z)
    return SetMatrix(up_x, up_y, up_z, right_x, right_y, right_z, front_x, front_y, front_z, posit_x, posit_y, posit_z)
    end

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

    --- Checks if two vectors are occluded by terrain or other
    --- walkable floor objects
    --- @param origin Vector
    --- @param dest Vector
    function vsp_math3d.is_occluded(origin, dest)
        local dir = Normalize(dest - origin)
        local steps = math.floor(Length(dest - origin))
        local pos = origin
        for _ = 1, steps do
            local floor_height = GetFloorHeightAndNormal(pos)
            pos = pos + dir
            if floor_height < 0 then return true end -- height < 0 is below ground, or inside of occluding terrain/objects
        end
        return false
    end

end
return vsp_math3d
