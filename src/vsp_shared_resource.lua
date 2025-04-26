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
local object= require("vsp_object")
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

    local function make_shared_nav(h)
        local pos = GetPosition(h)
        local name = GetObjectiveName(h)

        net.remove_sync_object(h)

        net.async(net.all_players, "build_async_my_team", "apcamr", pos, name)

        local h = exu.BuildAsyncObject("apcamr", GetTeamNum(GetPlayerHandle()), pos)

        SetObjectiveName(h, name)

        return shared_object:new(h)
    end

    --- Makes an existing game object shared. Shared object creation is synchronized via lock.
    --- @param h any
    function vsp_shared_resource.make_shared(h)
        local result = future.make_future()
        distributed_lock.lock_guard(shared_object.lock, function ()
            if GetClassLabel(h) == "camerapod" then
                result:resolve(make_shared_nav(h))
            end
        end)
        return result
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