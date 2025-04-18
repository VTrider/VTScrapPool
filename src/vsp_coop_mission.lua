--[[
=======================================
*   VT's Scrap Pool
*   
*   Coop Mission Module
=======================================
--]]

local math3d = require("vsp_math3d")
local mission = require("vsp_mission")
local net = require("vsp_net")
local object = require("vsp_object")
local team = require("vsp_team")
local util = require("vsp_util")

local vsp_coop_mission = {}
do
    --- @class coop_mission : mission, object
    local coop_mission = object.make_class("coop_mission", mission.mission_class)

    function coop_mission:coop_mission(team)
        self:super(true)

        self.team = team
        self.spawn_directions = {}

        self.team:do_ally()
    end

    function vsp_coop_mission.make_coop(team)
        return coop_mission:new(team)
    end

    net.set_function("coop_change_state", coop_mission:super().change_state)

    function coop_mission:change_state(new_state)
        for player_id in self.team.team_nums:iterator() do
            net.async(player_id, "coop_change_state", nil, new_state)
        end
        DisplayMessage("coop change state")
        self:super().change_state(self, new_state)
    end

    --- @type function
    local apply_my_spawn_direction

    function coop_mission:set_spawn_direction(player, direction)
        self.spawn_directions[player] = direction

        apply_my_spawn_direction = function ()
            local me = GetPlayerHandle()
            local pos = GetPosition(me)
            SetTransform(me, BuildDirectionalMatrix(pos, self.spawn_directions[team.get_me()]))
        end
    end

    net.set_function("set_remote_lives", exu.SetLives)

    --- @type function
    local apply_starting_lives

    --- Sets the life count for the current mission
    --- @param count number
    function coop_mission:set_life_count(count)
        apply_starting_lives = function () -- this is hacky but it works lol, SetLives needs to be called in Start or post
            if not IsHosting() then return end
            for player_id in self.team.team_nums:iterator() do
                net.async(player_id, "set_remote_lives", count)
            end
            exu.SetLives(count)
        end
    end

    function vsp_coop_mission.Start()
        apply_my_spawn_direction()
        apply_starting_lives()
    end

    function vsp_coop_mission.Update(dt)

    end

    function vsp_coop_mission.CreateObject(h)
        if IsRemote(h) then return end
        if GetClassLabel(h) == "recycler" then
            util.defer(net.remove_sync_object, h)
        end
    end
end
return vsp_coop_mission