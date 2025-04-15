--[[
=======================================
*   VT's Scrap Pool
*   
*   Net Players Module
*
*   Handles tracking players in a game
*   and related operations
=======================================
--]]

local object = require("vsp_object")

local vsp_net_player = {}
do
    --- @class net_player : object
    local net_player = object.make_class("net_player")

    net_player.player_list = {}

    function net_player:__dynamic_initializer(id, name, team)
        self.id = id
        self.name = name
        self.team = team
    end

    function vsp_net_player.make_player(id, name, team)
        return net_player:new(id, name, team)
    end

    function vsp_net_player.CreatePlayer(id, name, team)
        -- exu.MessageBox("Created player of ID " .. id .. " " .. name)
        net_player.player_list[id] = vsp_net_player.make_player(id, name, team)
    end

    function vsp_net_player.DeletePlayer(id, name, team)
        net_player.player_list[id] = nil
    end
end
return vsp_net_player