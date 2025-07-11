--[[
=======================================
*   VT's Scrap Pool
*   
*   Utilities Module
*
*   Things that don't fit in any other
*   category
=======================================
--]]

local future = require("vsp_future")
local time = require("vsp_time")

local vsp_utility = {}
do
    local deferred_queue = {}

    --- Defers a function call until the next update,
    --- makes certain functions safe to use in the
    --- stock event handlers like CreateObject()
    --- @param func function
    --- @param ... any
    --- @return future
    function vsp_utility.defer(func, ...)
        local result = future.make_future()
        local params = {...}
        table.insert(deferred_queue, function ()
            result.result = func(unpack(params))
            result.completed = true
        end)
        return result
    end

    --- Defers a function call until the next update,
    --- plus the given number of time in seconds
    --- @param duration number
    --- @param func function
    --- @param ... any
    --- @return future
    function vsp_utility.defer_for(duration, func, ...)
        local result = future.make_future()
        local params = {...}
        local resolve_result = function (...)
            result.result = func(unpack(params))
            result.completed = true
        end
        table.insert(deferred_queue, function ()
            time.make_timer(duration, false, resolve_result):start()
        end)
        return result
    end

    --- Gets the vector position from various data types that store a position
    --- @nodiscard
    --- @param x any handle, matrix, vector, path, or table/object position
    --- @param y? integer path point if path
    --- @return any vector
    function vsp_utility.get_any_position(x, y)
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

    function vsp_utility.get_line_number()
        local info = debug.getinfo(2, "l")
        return info.currentline
    end

    --- Special update function that will run before all other
    --- VSP update functions in order to properly defer function
    --- calls
    function vsp_utility.PreUpdate(dt)
        if #deferred_queue > 0 then
            local func = table.remove(deferred_queue)
            func()
        end
    end
end
return vsp_utility