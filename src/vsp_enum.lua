--[[
=======================================
*   VT's Scrap Pool
*   
*   Enum Module
*
*   Good for representing constants
*   when their value doesn't necesarily
*   matter, only the name
=======================================
--]]

local vsp_enum = {}
do
    --- Note these aren't specialized to the proper type (integer and string)
    --- because it causes erroneous "undefined field" warnings from lua langauge
    --- server.

    ---@alias enum table<any>
    ---@alias string_enum table<any>

    --- Makes an enum with numeric values
    --- @param ... any keys
    --- @return enum
    function vsp_enum.make_enum(...)
        local result = {}
        local params = {...}
        for key, value in pairs(params) do
            result[value] = key
        end
        return result
    end

    --- Makes an enum with string values
    --- @param ... any
    --- @return string_enum
    function vsp_enum.make_string_enum(...)
        local result = {}
        local params = {...}
        for _, value in pairs(params) do
            result[value] = value
        end
        return result
    end
end
return vsp_enum