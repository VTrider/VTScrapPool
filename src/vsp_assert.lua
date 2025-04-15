--[[
=======================================
*   VT's Scrap Pool
*   
*   Assertions and Errors Module
=======================================
--]]

local vsp_assert = {}
do
    setmetatable(vsp_assert, { __call = assert })

    --- Assert local player is hosting
    function vsp_assert.hosting()
        assert(IsHosting() "VSP: Must be host")
    end

    function vsp_assert.typecheck(value, expected_type)
        assert(type(value) == expected_type, "VSP: expected " .. expected_type .. " got " .. type(value))
    end

    function vsp_assert.required_arg(arg)
        assert(arg, "VSP: Missing required argument")
    end
end
return vsp_assert