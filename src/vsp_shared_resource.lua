--[[
=======================================
*   VT's Scrap Pool
*   
*   Shared Resource Module
=======================================
--]]

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