--[[
=======================================
*   VT's Scrap Pool
*   
*   Shared Resource Module
=======================================
--]]

local distributed_lock = require("vsp_distributed_lock")
local future = require("vsp_future")
local net = require("vsp_net")
local object = require("vsp_object")
local set = require("vsp_set")
local team = require("vsp_team")

local exu = require("exu")

local vsp_shared_resource = {}
do
    local scrap_storage_values = {
        recycler = 20,
        factory = 10,
        armory = 5,
        constructor = 10,
        silo = 20
    }

    local scrap_shared = false
    
    vsp_shared_resource.local_scrap_capacity = 0

    net.set_function("send_remote_scrap", function (amount)
        -- exu.MessageBox(string.format("Got request for %d scrap", amount))
        exu.AddScrapSilent(GetTeamNum(GetPlayerHandle()), amount)
    end)

    function vsp_shared_resource.make_scrap_shared()
        if net.is_singleplayer_or_solo () then return end
        scrap_shared = true
    end

    local function do_shared_scrap(team, amount)
        if scrap_shared == false then return end
        if team ~= GetTeamNum(GetPlayerHandle()) then return end
        net.async(nil, "send_remote_scrap", amount)
        -- exu.MessageBox(string.format("Send %d scrap", amount))
    end

    --- This class describes a game object that is shared between
    --- multiple players across the network.
    --- @class shared_object : object
    local shared_object = object.make_class("shared_object")

    shared_object.shared_handles = {}
    shared_object.lock = distributed_lock.make_lock()

    function shared_object:shared_object(h)
        self.handle = h
    end

    function shared_object:get_handle()
        return self.handle
    end

    net.set_function("build_async_my_team", function (odfname, pos, name)
        local result = exu.BuildAsyncObject(odfname, GetTeamNum(GetPlayerHandle()), pos)
        if name then
            SetObjectiveName(result, name)
        end
    end)

    net.set_function("client_request_shared_object", function (h)
        assert(IsHosting(), "VSP: Non host processing shared object request")


    end)

    --- TODO: fix this shit

    --- comment
    --- @param h any
    --- @return future<shared_object>
    local function make_shared_nav(h)
        local result = future.make_future()
        if IsHosting() then
            if shared_object.shared_handles[h] then
                result:resolve(shared_object.shared_handles[h])
            else
                local pos = GetPosition(h)
                local name = GetObjectiveName(h)
                net.remove_sync_object(h)       
                net.async(net.all_players, "build_async_my_team", "apcamr", pos, name)
                local h = exu.BuildAsyncObject("apcamr", GetTeamNum(GetPlayerHandle()), pos)
                SetObjectiveName(h, name)

                local shared = shared_object:new(h)

                shared_object.shared_handles[h] = shared
                result:resolve(shared)
            end
        else
            net.async(net.host_id, "client_request_shared_object", h):wait(function (h)
                result:resolve(h)
            end)
        end

        return result   
    end

    net.set_function("make_shared_nav", make_shared_nav)

    --- comment
    --- @param h any
    --- @return future<shared_object>
    local function make_shared_satellite(h)
        return shared_object:new()
    end

    --- Makes an existing game object shared. Shared object creation is synchronized via lock.
    --- @param h any handle
    --- @return future<shared_object>
    function vsp_shared_resource.make_shared(h)
        local final_result = future.make_future()
        shared_object.lock:try_lock():wait(function (acquired)
            if acquired then
                local shared_object_future
                if GetClassLabel(h) == "camerapod" then
                    shared_object_future = make_shared_nav(h)
                elseif GetClassLabel(h) == "commtower" then
                    shared_object_future = make_shared_satellite(h)
                else
                    error("VSP: unknown object type for shared object")
                end
                shared_object_future:wait(function (result)
                    final_result:resolve(result)
                end)
            end
        end)
        return final_result
    end

    --- Directly constructs a shared object.
    --- @param odfname string
    --- @param pos any
    --- @return future
    function vsp_shared_resource.build_shared_object(odfname, pos)
        local obj = exu.BuildSyncObject(odfname, GetTeamNum(GetPlayerHandle()), pos)
        return vsp_shared_resource.make_shared(obj)
    end

    function vsp_shared_resource.Start()

    end

    function vsp_shared_resource.CreateObject(h)

    end

    function vsp_shared_resource.DeleteObject(h)
        
    end

    function vsp_shared_resource.AddScrap(team, amount)
        do_shared_scrap(team, amount)
    end
end
return vsp_shared_resource