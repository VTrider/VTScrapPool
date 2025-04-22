--[[
=======================================
*   VT's Scrap Pool
*   
*   Mission Module
*
*   Simple state machine for
*   singleplayer missions
*
*   Required Event Handlers:
*   - Start()
*   - Update(dt)
*   - CreateObject(h)
=======================================
--]]

local object = require("vsp_object")

local vsp_mission = {}
do
    --- @class mission : object
    local mission = object.make_class("mission")

    --- @class mission
    local current_mission = nil

    --- Gets the current mission instance if it exists
    --- @return mission
    function vsp_mission.get_current_mission()
        return current_mission
    end

    function mission:mission()
        self.states = {}
        self.states.null_state = {
            execute = function(state, dt) return true end,
            enter_callback = function(state) return true end,
            exit_callback = function(state) return true end,
            var = {},
            event_listeners = {}
        }
        self.current_state = self.states.null_state
        self.var = {}
        self.global_listeners = {}

        current_mission = self
    end

    --- Creates or gets the mission instance
    --- @return mission
    function vsp_mission.make_mission()
        if current_mission then return current_mission end
        return mission:new()
    end

    --- Initializes a new mission state, does not change the current state
    --- @param id any
    --- @param execute fun(state: table, dt: number)
    --- @param enter_callback fun(state: table)
    --- @param exit_callback fun(state: table)
    --- @return mission
    function mission:define_state(id, execute, enter_callback, exit_callback)
        self.states[id] = {
            execute = execute,
            enter_callback = enter_callback or function(state) return true end,
            exit_callback = exit_callback or function(state) return true end,
            var = {},
            event_listeners = {}
        }
        return self
    end

    --- Changes the state of the mission
    --- @param new_state any state id
    function mission:change_state(new_state)
        -- when this is called by a remote player self will not be sent over the net,
        -- so use your own mission instance which should be in sync if set up properly
        self = self or current_mission
        if self.current_state_id == new_state then return end

        assert(self.states[new_state], "VSP: Requested state is undefined")

        DisplayMessage("changing state to " .. tostring(new_state))

        self.current_state_id = new_state

        self.current_state.exit_callback(self.current_state)

        self.current_state = self.states[new_state]

        self.current_state.enter_callback(self.current_state)
    end

    --- Alias for change state to better specify the
    --- first state of the mission
    mission.initial_state = mission.change_state

    --- Defines a per-state event listener for event handlers
    --- (CreateObject etc)
    --- @param state any state id to attach listener
    --- @param what string name of the event handler
    --- @param func fun(...: any)
    function mission:define_event_listener(state, what, func)
        assert(self.states[state], "VSP: State does not exist")
        assert(what ~= "Start", "VSP: Start event listeners are forbidden, just use Start()")
        assert(what ~= "Update", "VSP: Update event listeners are forbidden, use the state update function")

        self.states[state].event_listeners[what] = self.states[state].event_listeners[what] or {}
        table.insert(self.states[state].event_listeners[what], func)
    end

    function mission:define_global_listener(what, func)
        assert(what ~= "Start", "VSP: Start global listeners are forbidden, just use Start()")
        self.global_listeners[what] = self.global_listeners[what] or {}
        table.insert(self.global_listeners[what], func)
    end

    function mission:do_state(dt)
        self.current_state.execute(self.current_state, dt)
    end

    function vsp_mission.Start()
        -- some initialization will break if done before Start()
        -- is called, so we need to track that
        current_mission.post_start = true
    end

    function vsp_mission.Update(dt)
        if not current_mission then return end
        current_mission:do_state(dt)

        if current_mission.global_listeners.Update then
            for _, listener in ipairs(current_mission.global_listeners.Update) do
                listener(dt)
            end
        end
    end

    function vsp_mission.CreateObject(h)
        if not current_mission.post_start then return end

        if current_mission.current_state.event_listeners.CreateObject then
            for _, listener in ipairs(current_mission.current_state.event_listeners.CreateObject) do
                listener(h)
            end
        end

        if current_mission.global_listeners.CreateObject then
            for _, listener in ipairs(current_mission.global_listeners.CreateObject) do
                listener(h)
            end
        end
    end

    vsp_mission.mission_class = mission
end
return vsp_mission