--[[
=======================================
*   VT's Scrap Pool
*   
*   Barrier Module
*
*   Network synchronization object to
*   wait for all clients to reach a
*   certain point before proceding
*
*	Required Event Handlers:
*	- Update(dt)
=======================================
--]]

local net_player = require("vsp_net_player")
local net = require("vsp_net")
local object = require("vsp_object")

local vsp_barrier = {}
do
    --- @class barrier : object
    local barrier = object.make_class("barrier")

    local barriers = {}

    local next_barrier_id = 1

    function barrier:barrier(expected, callback, ...)
        self.id = next_barrier_id
        next_barrier_id = next_barrier_id + 1
        self.waiting = false
        if IsHosting() then
            self.callback = callback
            self.params = {...}
            self.expected = expected or net_player.get_player_count()
            barriers[self.id] = self
        end
    end

    function vsp_barrier.make_barrier(expected, callback, ...)
        return barrier:new(expected, callback, ...)
    end

    function barrier:arrive()
        if net.is_singleplayer_or_solo() then
            self.callback(unpack(self.params))
        end
    end
    
end
return vsp_barrier