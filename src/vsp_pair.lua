--[[
=======================================
*   VT's Scrap Pool
*   
*   Pair Module
*
*   Simple structure to store two
*   objects as a single unit
=======================================
--]]

local object = require("vsp_object")

local vsp_pair = {}
do
    --- @class pair : object
    local pair = object.make_class("pair")

    function pair:pair(first, second)
        self.first = first
        self.second = second
    end

    --- Make a pair object
    --- @generic T
    --- @generic U
    --- @nodiscard
    --- @param first? `T`
    --- @param second? `U`
    --- @return pair <T, U>
    function vsp_pair.make_pair(first, second)
        return pair:new(first, second)
    end
end
return vsp_pair