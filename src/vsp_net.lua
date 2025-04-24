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
local math3d = require("vsp_math3d")
local net_message = require("vsp_net_message")
local net_player = require("vsp_net_player")
local util = require("vsp_util")

local exu = require("exu")

local vsp_net = {}
do
    vsp_net.host_id = 1
    vsp_net.all_players = 0 -- for use in functions that use Send()

    --- User defined table of network functions,
    --- this circumvents to "no functions" restriction
    --- of Send()
    --- @type table <string, function> 
    local function_table = {}

    --- Makes a name and function pair to be used remotely
    --- @param name string function name
    --- @param func function
    function vsp_net.set_function(name, func)
        if function_table[name] then
            error("VSP: Function is in use or reserved")
        end
        function_table[name] = func
    end

    --- Retrieves the corresponding function pair from its string name.
    --- Falls back to globals if not found:
    --- (NOT RECOMMENDED TO USE GLOBALS OTHER THAN STOCK FUNCTIONS)
    --- @param name string
    --- @return function
    function vsp_net.get_function(name)
        if function_table[name] then
            return function_table[name]
        elseif _G[name] then -- fallback to global if not registered
            return _G[name]
        else
            error("VSP: Function not registered or global")
        end
    end

    --- Gets if the current session is singleplayer or if it's multiplayer
    --- with only one player (the host)
    --- @return boolean
    function vsp_net.is_singleplayer_or_solo()
        return not IsNetGame() or net_player.get_player_count() == 1
    end

    --- @type table <number, future> 
    local async_tasks = {}
    local next_task_id = 1

    --- Dispatches an asynchrounous call to the given player (or all players),
    --- returns a future that may contain a result, or a table of futures (one for each player)
    --- if you sent the request to all players (nil or 0 or net.all_players)
    --- @async
    --- @param who integer | nil net ID
    --- @param func_string string function to call from the net functions table
    --- @param ... any function parameters
    --- @return future | table <integer, future>
    function vsp_net.async(who, func_string, ...)
        if vsp_net.is_singleplayer_or_solo() then
            local result = future.make_future()
            return result:resolve(vsp_net.get_function(func_string)(...))
        end

        local result

        if who == nil or who == vsp_net.all_players then
            for i = 1, net_player.get_player_count() do
                local task_id = next_task_id
                next_task_id = next_task_id + 1
        
                local f = future.make_future()
                async_tasks[task_id] = f

                result = {}
                table.insert(result, f)
        
                Send(i, net_message.vsp, net_message.async_request, task_id, func_string, ...)
            end
        else
            local task_id = next_task_id
            next_task_id = next_task_id + 1
    
            result = future.make_future()
            async_tasks[task_id] = result
    
            Send(who, net_message.vsp, net_message.async_request, task_id, func_string, ...)
        end

        return result
    end

    --- Automatically fetches the result of the asynchrounous call
    --- when it's available by passing it as a parameter to the callback.
    --- If there are multiple results (i.e. you sent a request to all players)
    --- they will all be sent to the same callback.
    --- @async
    --- @param who integer | nil net ID
    --- @param callback function callback to process result
    --- @param func_string string net function
    --- @param ... any params
    function vsp_net.async_callback(who, callback, func_string, ...)
        local result = vsp_net.async(who, func_string, ...)
        if type(result) == "table" then
            future.wait_all(result, callback)
        else
            result:wait(callback)
        end
    end

    --- Removes an object for all players without showing any explosions
    --- @param h lightuserdata handle
    function vsp_net.remove_sync_object(h)
        if vsp_net.is_singleplayer_or_solo() then
            RemoveObject(h)
            return
        end
        
        if GetClassLabel(h) == "recycler" then
            if IsRemote(h) then return end
            SetTeamNum(h, 0)
            SetPosition(h, GetPosition(h) + (math3d.east * 1000))
            util.defer_for(15, function () -- this is too much voodoo
                local max_pilots = GetMaxPilot(GetTeamNum(GetPlayerHandle()))
                local max_scraps = GetMaxScrap(GetTeamNum(GetPlayerHandle()))
                local cur_pilots = GetPilot(GetTeamNum(GetPlayerHandle()))
                local cur_scraps = GetScrap(GetTeamNum(GetPlayerHandle()))

                RemoveObject(h)

                SetMaxPilot(GetTeamNum(GetPlayerHandle()), max_pilots)
                SetMaxScrap(GetTeamNum(GetPlayerHandle()), max_scraps)
                SetPilot(GetTeamNum(GetPlayerHandle()), cur_pilots)
                exu.AddScrapSilent(GetTeamNum(GetPlayerHandle()), cur_scraps - GetScrap(GetTeamNum(GetPlayerHandle())))
            end)
            return
        end
        if IsHosting() then
            vsp_net.async_callback(vsp_net.all_players, function () RemoveObject(h) end, "RemoveObject", h)
        else
            Send(vsp_net.host_id, net_message.vsp, net_message.remote_delete, h)
        end
    end

    --- Begin wait_for_all_clients code:

    local is_waiting = false -- each client has their own instance of this
    local wait_counter = 0 -- the host owns this variable
    local waiting_callback = function (...) end
    local waiting_callback_params = {}

    local function try_execute_waiting_function()
        if wait_counter == net_player.get_player_count() then
            vsp_net.async(vsp_net.all_players, "reset_wait")
            is_waiting = false
            wait_counter = 0
            waiting_callback(unpack(waiting_callback_params))
        end
    end

    vsp_net.set_function("try_wait", function ()
        assert(IsHosting(), "VSP: Non host processing wait request, something went wrong")
    
        wait_counter = wait_counter + 1

        try_execute_waiting_function()
    end)

    vsp_net.set_function("reset_wait", function ()
        is_waiting = false
    end)

    --- Waits for all clients to acknowledge the signal before
    --- executing the callback. (Barrier sync)
    --- @param callback function
    --- @param ... any callback params
    function vsp_net.wait_for_all_clients(callback, ...)
        if vsp_net.is_singleplayer_or_solo() then callback(...) end

        if not is_waiting then
            if IsHosting() then
                waiting_callback = callback
                waiting_callback_params = {...}
                wait_counter = wait_counter + 1
            else
                vsp_net.async(vsp_net.host_id, "try_wait")
            end
            is_waiting = true
        end

        if IsHosting() then
            try_execute_waiting_function()
        end
    end
    
    --- Begin Receive helpers:

    --- Processes remote request and resolves the future
    --- @param from integer player net ID
    --- @param task_id integer async task ID
    --- @param func_string string function to acquire the data
    --- @param ... any params
    local function resolve_future(from, task_id, func_string, ...)
        local func = vsp_net.get_function(func_string)
        local result = func(...)

        Send(from, net_message.vsp, net_message.resolve_future, task_id, result)
    end

    local function get_resolved_future(task_id, result)
        -- Only handle the first result back from passing nil to async (not recommended due to race condition)
        if not async_tasks[task_id] then return false end

        assert(async_tasks[task_id], "VSP: Task ID has no associated future")
        local future = async_tasks[task_id]

        future.result = result
        future.completed = true

        async_tasks[task_id] = nil
    end

    local function do_remote_delete(h)
        vsp_net.async_callback(vsp_net.all_players, function () RemoveObject(h) end, "RemoveObject", h)
    end

    function vsp_net.Receive(from, type, message, ...)
        if type ~= net_message.vsp then return false end -- only handle VSP messages
        if from == exu.GetMyNetID() then return false end -- Don't talk to yourself
        
        if message == net_message.async_request then
            resolve_future(from, ...)
            return true
        end

        if message == net_message.resolve_future then
            get_resolved_future(...)
            return true
        end

        if message == net_message.remote_delete then
            do_remote_delete(...)
            return true
        end
    end
end
return vsp_net