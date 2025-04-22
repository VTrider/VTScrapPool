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

local enum = {}
do
    --- Makes an enum with numeric values
    --- @param ... any keys
    --- @return table enum
    function enum.make_enum(...)
        local result = {}
        local params = {...}
        for key, value in pairs(params) do
            result[value] = key
        end
        return result
    end

    --- Makes an enum with string values
    --- @param ... any
    --- @return table
    function enum.make_string_enum(...)
        local result = {}
        local params = {...}
        for _, value in pairs(params) do
            result[value] = value
        end
        return result
    end
end
return enum