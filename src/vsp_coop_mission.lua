--[[
=======================================
*   VT's Scrap Pool
*   
*   Coop Mission Module
*
*   Multiplayer safe wrapper for
*   missions. Automatically handles
*   synchronization.
*
*   Required Event Handlers:
*   - Start()
*   - Update(dt)
*   - CreateObject(h)
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
    vsp_coop_mission.enemy_team = 15

    --- @class coop_mission : mission, object
    local coop_mission = object.make_class("coop_mission", mission.mission_class)

    function coop_mission:coop_mission(team)
        self:super(true)

        self.team = team
        self.spawn_directions = {}

        self.team:do_ally()
    end

    --- Makes a coop mission instance with the given team
    --- @param team team
    --- @return coop_mission
    function vsp_coop_mission.make_coop(team)
        return coop_mission:new(team)
    end

    net.set_function("coop_change_state", coop_mission:super().change_state)

    --- Synchronized, authoritative state change. Will work regardless
    --- of hosting status and propagate the state change to all clients.
    --- @param new_state any state id
    function coop_mission:change_state(new_state)
        if self.current_state_id == new_state then return end
        for player_id in self.team.team_nums:iterator() do
            net.async(player_id, "coop_change_state", nil, new_state)
        end
        self:super().change_state(self, new_state)
    end

    local apply_my_spawn_direction = function () end

    --- Sets the direction the given player will be facing when the mission starts.
    --- @param player number team number
    --- @param direction any vector direction
    function coop_mission:set_spawn_direction(player, direction)
        self.spawn_directions[player] = direction

        apply_my_spawn_direction = function ()
            local me = GetPlayerHandle()
            local pos = GetPosition(me)
            SetTransform(me, BuildDirectionalMatrix(pos, self.spawn_directions[team.get_me()]))
        end
    end

    net.set_function("set_remote_lives", exu.SetLives)

    local apply_starting_lives = function () end

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

    local apply_starting_recyclers = function (h) return end

    function coop_mission:set_starting_recyclers(state)
        if state == false then
            apply_starting_recyclers = function (h)
                if GetClassLabel(h) == "recycler" then
                    util.defer(net.remove_sync_object, h)
                end
            end
        end
    end
    
    -- these two functions may not be necessary idk
    net.set_function("coop_sync_var", function (name, value)
        assert(mission.get_current_mission().var, "fucked")
        mission.get_current_mission().var[name] = value
        return name
    end)

    -- not tested
    function coop_mission:sync_var(name, value)
        local result
        for player_id in self.team.team_nums:iterator() do
            local f = net.async(player_id, "coop_sync_var", name, value)
            if player_id ~= GetTeamNum(GetPlayerHandle()) then
                result = f
            end
        end
        self.var[name] = value
        return result
    end

    net.set_function("make_shared_satellite", function ()
        local s_power = exu.BuildAsyncObject("abspow", GetTeamNum(GetPlayerHandle()), GetPosition(GetPlayerHandle()) + (math3d.east * 1000))
        local comm_tower = exu.BuildAsyncObject("abcomm", GetTeamNum(GetPlayerHandle()), GetPosition(GetPlayerHandle()) + (math3d.east * 1000))
        Hide(s_power)
        Hide(comm_tower)
    end)

    -- todo refactor
    local function apply_shared_satellite()
        for obj in AllObjects() do
            if not IsRemote(obj) and GetClassLabel(obj) == "commtower" then
                net.async(net.all_players, "make_shared_satellite")
                break
            end
        end
    end

    function vsp_coop_mission.Start()
        apply_my_spawn_direction()
        apply_starting_lives()
        apply_shared_satellite()
    end

    function vsp_coop_mission.Update(dt)

    end

    function vsp_coop_mission.CreateObject(h)
        apply_starting_recyclers(h)
    end
end
return vsp_coop_mission