--[[
=======================================
*   VT's Scrap Pool
*   
*   Satellite Manager Module
*
*   Tracks satellite buildings and
*   allows for shared usage in a team
*   
*   Required Event Handlers:
*   - Update(dt)
*   - CreateObject(h)
*   - DeleteObject(h)
=======================================
--]]

local net_player = require("vsp_net_player")
local object_manager = require("vsp_object_manager")
local team = require("vsp_team")

local vsp_satellite_manager = {}
do
    --- @param start_objects future<table<userdata>>
    local function init_state(start_objects)
        local objects = start_objects:get()
        for _, object in ipairs(objects) do
            
        end
    end



    function vsp_satellite_manager.Start()
        init_state(object_manager.get_start_objects())
    end

    function vsp_satellite_manager.Update(dt)

    end

    function vsp_satellite_manager.CreateObject(h)

    end

    function vsp_satellite_manager.DeleteObject(h)

    end
end
return vsp_satellite_manager