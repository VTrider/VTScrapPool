--[[
=======================================
*   VT's Scrap Pool
*
*   Functional Helpers Module
*
*   Many methods in this library use
*   a functional interface, this module
*   has utilities related to that
=======================================
--]]

local vsp_functional = {}
do
    --- Helper to verify the existance of and type check incoming parameters to a function 
    --- @param param any the value of the param
    --- @param name string name of the param
    --- @param typename string a built in type as used in the type() function
    --- @param who? string the name of the caller ie. "VSP"
    --- @return any the original param if successful
    function vsp_functional.required_param(param, name, typename, who)
        who = who or "VSP"
        assert(param, string.format("%s: Missing required param %s", who, name))
        if typename ~= "any" then
            assert(type(param) == typename, string.format("%s: Expected type %s for required param %s, got %s", who, typename, name, type(param)))
        end
        return param
    end

    function vsp_functional.parameter_pack()
        
    end

    --- Compose multiple filter functions into one for methods that require
    --- a filter when you need many fine grained filters
    --- @param ... fun(param)
    function vsp_functional.compose_filters(...)
        local filters = {...}
        return function (param)
            for _, filter in ipairs(filters) do
                if not filter(param) then return end
            end
        end
    end
end
return vsp_functional

