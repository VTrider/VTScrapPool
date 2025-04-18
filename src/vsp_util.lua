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

local vsp_util = {}
do
    local deferred_queue = {}

    --- Defers a function call until the next update,
    --- makes certain functions safe to use in the
    --- stock event handlers like CreateObject()
    --- @param func function
    --- @param ... any
    --- @return future
    function vsp_util.defer(func, ...)
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
    function vsp_util.defer_for(duration, func, ...)
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

    function vsp_util.Update(dt)
        if #deferred_queue > 0 then
            local func = table.remove(deferred_queue)
            func()
        end
    end
end
return vsp_util