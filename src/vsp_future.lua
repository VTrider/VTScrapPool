--[[
=======================================
*   VT's Scrap Pool
*   
*   Futures Module
*
*   A future represents the result of
*   an asynchrounous operation
*
*   Required Event Handlers:
*   - Update(dt)
=======================================
--]]

local object = require("vsp_object")
local set = require("vsp_set")

local vsp_future = {}
do
    --- @class future : object
    --- @field completed boolean
    --- @field result any
    --- @field listener function
    local future = object.make_class("future")

    local callback_listeners = set.make_set()

    function future:__dynamic_initializer()
        self.completed = false
        self.result = nil
        self.listener = nil
    end

    --- Constructs an empty future object 
    --- @return future
    function vsp_future.make_future()
        return future:new()
    end

    --- Returns the result of the future (if it exists)
    --- @return any | nil
    function future:get()
        return self.result
    end

    --- Check to see if the future has been completed
    --- @return boolean
    function future:peek()
        return self.completed
    end

    --- Assigns a callback to the future that will automatically get
    --- called when the future resolves
    --- @param callback any
    --- @return self
    function future:listen(callback)
        if self.listener then return self end
        self.listener = callback
        callback_listeners:insert(self)
        return self
    end

    local function listen_all_callbacks()
        for future in callback_listeners:iterator() do
            if future:peek() then
                local result = future:get()
                future.listener(result)
                callback_listeners:remove(future)
            end
        end
    end

    function vsp_future.Update(dt)
        listen_all_callbacks()
    end
end
return vsp_future