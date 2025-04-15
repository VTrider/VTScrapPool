--[[
=======================================
*   VT's Scrap Pool
*   
*   Shared Resource Module
=======================================
--]]

local assert = require("vsp_assert")
local net = require("vsp_net")
local object= require("vsp_object")
local resource = require("vsp_resource")
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

    --- @class shared_resource : resource, object
    local shared_resource = object.make_class("shared_resource", resource.resource)

    vsp_shared_resource.local_scrap_capacity = 0

    net.set_function("send_remote_scrap", function (amount)
        exu.MessageBox(string.format("Got request for %d scrap", amount))
        exu.AddScrapSilent(GetTeamNum(GetPlayerHandle()), amount)
    end)

    local function enumerate_producers()
        local total = 0
        if GetRecyclerHandle() then total = total + scrap_storage_values.recycler end
        if GetFactoryHandle() then total = total + scrap_storage_values.factory end
        if GetArmoryHandle() then total = total + scrap_storage_values.armory end
        if GetConstructorHandle() then total = total + scrap_storage_values.constructor end
        return total
    end

    local function update_max_scrap(h)
        local cap = vsp_shared_resource.local_scrap_capacity
        if h == GetRecyclerHandle() then
            cap = cap + scrap_storage_values.recycler
        elseif h == GetFactoryHandle() then
            cap = cap + scrap_storage_values.factory
        elseif h == GetArmoryHandle() then
            cap = cap + scrap_storage_values.armory
        elseif h == GetConstructorHandle() then
            cap = cap + scrap_storage_values.constructor
        else
            return
        end
    end

    function shared_resource:__dynamic_initializer(name, amount, min, max, team)
        self:super(name, amount, min, max)

        self.team = team
        self.shared_pool = amount
    end

    function vsp_shared_resource.make_shared(name, amount, min, max, team)
        return shared_resource:new(name, amount, min, max, team)
    end

    local function do_shared_scrap(team, amount)
        if team ~= GetTeamNum(GetPlayerHandle()) then return end
        net.async(nil, "send_remote_scrap", amount)
        exu.MessageBox(string.format("Send %d scrap", amount))
    end

    function vsp_shared_resource.Start()
        if IsHosting() then
            
        end
        vsp_shared_resource.local_scrap_capacity = enumerate_producers()
    end

    function vsp_shared_resource.CreateObject(h)
        update_max_scrap(h)
    end

    function vsp_shared_resource.DeleteObject(h)
        
    end

    function vsp_shared_resource.AddScrap(team, amount)
        do_shared_scrap(team, amount)
    end
end
return vsp_shared_resource