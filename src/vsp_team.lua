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

    --- @return team|nil
    function vsp_team.get_my_team()
        return my_team
    end

    --- @class team : object
    --- @field team_nums set
    local team = object.make_class("team")

    function vsp_team.make_team(...)
        local self = setmetatable({}, { __index = vsp_team })

        -- Map assigned team numbers for players (1, 2, 3, 4... etc.)
        self.team_nums = set.make_set(...)

        return self
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