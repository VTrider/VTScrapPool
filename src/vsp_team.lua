--[[
=======================================
*   VT's Scrap Pool
*   
*   Team Module
=======================================
--]]

local net = require("vsp_net")
local object= require("vsp_object")
local set = require("vsp_set")

local vsp_team = {}
do
    --- @type team | nil
    local my_team = nil

    function vsp_team.get_me()
        return GetTeamNum(GetPlayerHandle())
    end

    --- @return team | nil
    function vsp_team.get_my_team()
        return my_team
    end

    --- @class team : object
    --- @field team_nums set
    local team = object.make_class("team")

    function team:team(name, ...)
        self.name = name
        -- Map assigned team numbers for players (1, 2, 3, 4... etc.)
        self.team_nums = set.make_set(...)
        self.player_count = self.team_nums:size()
    end

    function team:get_player_count()
        return self.player_count
    end

    --- Makes a team object
    --- @param name string identifier for the team
    --- @param ... integer team nums
    --- @return team
    function vsp_team.make_team(name, ...)
        return team:new(name, ...)
    end

    function vsp_team.leave_team()
        my_team = nil
    end

    function team:do_ally()
        for i in self.team_nums:iterator() do
            for j in self.team_nums:iterator() do
                Ally(i, j)
            end
            break -- we only need one iteration to ally everybody
        end
    end
end
return vsp_team