--[[
=======================================
*   VT's Scrap Pool
*   
*   Polymorphic Helpers Module
=======================================
--]]

local vsp_polymorphic = {}
do
    --- Gets the vector position from various data types that store a position
    --- @nodiscard
    --- @param x any handle, matrix, vector, path, or table/object position
    --- @param y? integer path point if path
    --- @return any vector
    function vsp_polymorphic.get_position(x, y)
        if type(x) == "userdata" then
            if x.posit_x then -- matrix case
                return SetVector(x.posit_x, x.posit_y, x.posit_z)
            elseif x.x then -- vector case (passthrough)
                return x
            else
                return GetPosition(x) -- handle case
            end
        elseif type(x) == "string" then -- path case
            return GetPosition(x, y)
        elseif type(x) == "table" then -- table or object case (all VSP objects with a position will use the .position field)
            if x.position then
                return x.position
            else
                error("VSP: Table or object does not contain position")
            end
        else
            error("VSP: Unknown type for position")
        end
    end
end
return vsp_polymorphic