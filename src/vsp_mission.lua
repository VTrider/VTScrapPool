--[[
=======================================
*   VT's Scrap Pool
*   
*   Mission Module
=======================================
--]]

local object = require("vsp_object")
local set = require("vsp_set")

local vsp_mission = {}
do
    --- @class mission : object
    local mission = object.make_class("mission")

    --- @class mission
    local current_mission = nil

    function vsp_mission.get_current_mission()
        return current_mission
    end

    function mission:mission()
        if current_mission then return current_mission end

        self.states = {}
        self.states.null_state = {
            execute = function(state, dt) return true end,
            enter_callback = function(state) return true end,
            exit_callback = function(state) return true end
        }
        self.current_state = self.states.null_state
        self.var = {}

        current_mission = self
    end

    --- Creates or gets the mission instance
    --- @return mission
    function vsp_mission.make_mission()
        return mission:new()
    end

    --- Initializes a new mission state, does not change the current state
    --- @param id any
    --- @param execute function
    --- @param enter_callback function
    --- @param exit_callback function
    --- @return mission
    function mission:new_state(id, execute, enter_callback, exit_callback)
        self.states[id] = {
            execute = execute,
            enter_callback = enter_callback or function(state) return true end,
            exit_callback = exit_callback or function(state) return true end
        }
        return self
    end

    -- DO NOT RETURN SELF
    function mission:change_state(new_state)
        self = self or current_mission
        if self.current_state_id == new_state then return end
        DisplayMessage("changing state to " .. tostring(new_state))
        self.current_state_id = new_state

        self.current_state.exit_callback(self.current_state)

        self.current_state = self.states[new_state]

        self.current_state.enter_callback(self.current_state)
    end

    mission.initial_state = mission.change_state

    function mission:do_state(dt)
        self.current_state.execute(self.current_state, dt)
    end

    function vsp_mission.Update(dt)
        Ally(1, 2)
        if not current_mission then return end
        current_mission:do_state(dt)
    end

    vsp_mission.mission_class = mission
end
return vsp_mission