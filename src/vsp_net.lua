--[[
=======================================
*   VT's Scrap Pool
*   
*   Net Module
*
*   Handles networked and asynchronous
*   operations
*
*   Required Event Handlers:
*   - Receive(from, type, ...)
=======================================
--]]

local future = require("vsp_future")
local net_message = require("vsp_net_message")
local net_player = require("vsp_net_player")

local exu = require("exu")

local vsp_net = {}
do
    vsp_net.host_id = 1

    --- User defined table of network functions,
    --- this circumvents to "no functions" restriction
    --- of Send()
    --- @type table <string, function> 
    local function_table = {}

    --- Makes a name and function pair to be used remotely
    --- @param name string function name
    --- @param func function
    function vsp_net.set_function(name, func)
        function_table[name] = func
    end

    --- Retrieves the corresponding function pair from its string name
    --- @param name string
    --- @return function
    function vsp_net.get_function(name)
        return function_table[name]
    end

    --- @type table <number, future> 
    local async_tasks = {}
    local next_task_id = 1

    --- Dispatches asynchrounous call to the given player (or all players),
    --- returns a future that may contain a result
    --- @async
    --- @param who integer | nil net ID
    --- @param func_string string function to call from the net functions table
    --- @param ... any function parameters
    --- @return future
    function vsp_net.async(who, func_string, ...)
        local task_id = next_task_id
        next_task_id = next_task_id + 1

        local result = future.make_future()
        async_tasks[task_id] = result

        Send(who, net_message.vsp, net_message.async_request, task_id, func_string, ...)

        return result
    end

    --- Automatically fetches the result of the future when it's
    --- available by passing it as a parameter to the callback
    --- @async
    --- @param who integer | nil net ID
    --- @param callback function callback to process result
    --- @param func_string string net function
    --- @param ... any params
    --- @return future
    function vsp_net.async_callback(who, callback, func_string, ...)
        local result = vsp_net.async(who, func_string, ...)
        return result:listen(callback)
    end

    --- Processes remote request and resolves the future
    --- @param from integer player net ID
    --- @param task_id integer async task ID
    --- @param func function function to acquire the data
    --- @param ... any params
    local function resolve_future(from, task_id, func, ...)
        local result = func(...)
        Send(from, net_message.vsp, net_message.resolve_future, task_id, nil, result) -- nil for the "function" since we reuse the same Receive params
    end

    function vsp_net.Receive(from, type, message, task_id, func_string, ...)
        if type ~= net_message.vsp then return end -- only handle VSP messages
        if from == exu.GetMyNetID() then return end -- Don't talk to yourself

        if message == net_message.async_request then
            resolve_future(from, task_id, vsp_net.get_function(func_string), ...)
        end

        if message == net_message.resolve_future then
            local future = async_tasks[task_id]
            future.result = ...
            future.completed = true
        end
    end
end
return vsp_net