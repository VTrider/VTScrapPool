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

local functional = require("vsp_functional")
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

    --- @alias position_t Handle | string | Vector | Matrix 

    --- Gets the vector position from various data types that store a position
    --- @nodiscard
    --- @param x position_t handle, matrix, vector, path, or table/object position
    --- @param y? integer path point if path
    --- @return any vector
    function vsp_utility.get_any_position(x, y)
        -- Lua language server is super fked with the type inference here so
        -- I'm not going to bother with type and cast annotations
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

    --- This function has been moved to vsp_functional, this alias will be removed in the future
    --- @deprecated
    vsp_utility.required_param = functional.required_param

    local post_start = false

    --- Returns whether or not Start() has been called yet, as long as vsp is the first
    --- module loaded in Start()
    --- @return boolean
    function vsp_utility.post_start()
        return post_start
    end

    --- Returns a sequence of values from a first and last integer (both inclusive)
    --- If only one param is provided it will be from 1 to the provided param (last).
    --- @param first_or_last integer
    --- @param last? integer
    --- @return integer ...
    function vsp_utility.sequence(first_or_last, last)
        local sequence = {}
        if last then
            for i = first_or_last, last, 1 do
                sequence[#sequence+1] = i
            end
        else
            for i = 1, first_or_last, 1 do
                sequence[#sequence+1] = i
            end
        end
        return unpack(sequence)
    end

    function vsp_utility.PreStart()
        post_start = true
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
