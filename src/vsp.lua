--[[
=======================================
*   VT's Scrap Pool
*   
*   Combined Header
*
*   Make sure to include all of the
*   event handlers in your map script.
*   They must be called FIRST before
*   your own to ensure proper function.
=======================================
--]]
local vsp = {}
do
    vsp.cinematic         = require("vsp_cinematic")
    vsp.distributed_lock  = require("vsp_distributed_lock")
    vsp.enum              = require("vsp_enum")
    vsp.future            = require("vsp_future")
    vsp.holographic       = require("vsp_holographic")
    vsp.math3d            = require("vsp_math3d")
    vsp.net_message       = require("vsp_net_message")
    vsp.net_player        = require("vsp_net_player")
    vsp.net               = require("vsp_net")
    vsp.object_service    = require("vsp_object_service")
    vsp.object            = require("vsp_object")
    vsp.odf               = require("vsp_odf")
    vsp.pair              = require("vsp_pair")
    vsp.selection         = require("vsp_selection")
    vsp.set               = require("vsp_set")
    vsp.shared_resource   = require("vsp_shared_resource")
    vsp.time              = require("vsp_time")
    vsp.utility           = require("vsp_utility")
    vsp.zone              = require("vsp_zone")

    function vsp.Start()
        vsp.object_service.PreStart()

        vsp.shared_resource.Start()
    end

    function vsp.Update(dt)
        vsp.utility.PreUpdate(dt)

        vsp.future.Update(dt)
        vsp.holographic.Update(dt)
        vsp.object_service.Update(dt)
        vsp.time.Update(dt)
    end

    function vsp.CreateObject(h)
        vsp.shared_resource.CreateObject(h)
    end

    function vsp.DeleteObject(h)
    end

    function vsp.CreatePlayer(id, name, team)
        vsp.net_player.CreatePlayer(id, name, team)
    end

    function vsp.DeletePlayer(id, name, team)
        vsp.net_player.DeletePlayer(id, name, team)
    end

    function vsp.Receive(from, type, ...)
        vsp.net.Receive(from, type, ...)
    end

    function vsp.AddScrap(team, amount)
        vsp.shared_resource.AddScrap(team, amount)
    end
end
return vsp