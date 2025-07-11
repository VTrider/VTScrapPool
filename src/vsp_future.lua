--[[
=======================================
*   VT's Scrap Pool
*   
*   Future Module
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
    --- @field listener fun(result: any) | nil
    local future = object.make_class("future")

    local callback_listeners = set.make_set()

    function future:future()
        self.completed = false
        self.result = nil
        self.listener = nil
    end

    --- Constructs an empty future object 
    --- @generic T
    --- @nodiscard
    --- @return future<T>
    function vsp_future.make_future()
        return future:new()
    end

    --- Returns the result of the future (if it exists)
    --- @generic T
    --- @nodiscard
    --- @return T
    function future:get()
        return self.result
    end

    --- Check to see if the future has been completed
    --- @nodiscard
    --- @return boolean
    function future:peek()
        return self.completed
    end

    --- Fills the result of the future and marks it as completed.
    --- @generic T
    --- @param result T
    --- @return self
    function future:resolve(result)
        self.result = result
        self.completed = true
        return self
    end

    --- Assigns a callback to the future that will automatically get
    --- called with the result as its first parameter when the future resolves.
    --- @generic T
    --- @param callback fun(result: T)
    --- @return self
    function future:wait(callback)
        if self.listener then return self end

        -- Call back immediately if the result is available
        if self:peek() then
            callback(self:get())
            return self
        end

        self.listener = callback
        callback_listeners:insert(self)

        return self
    end

    future.listen = future.wait

    --- Waits for all futures in a table to be completed before passing a table
    --- of results to the callback
    --- @generic T
    --- @param future_table table must be a contiguous "array" table
    --- @param callback fun(results: table<integer, T>)
    function vsp_future.wait_all(future_table, callback)
        local results = {}
        local completed = 0
        local total = #future_table

        for i, future in ipairs(future_table) do
            future:wait(function (result)
                results[i] = result
                completed = completed + 1
                if completed == total then
                    callback(results)
                end
            end)
        end
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