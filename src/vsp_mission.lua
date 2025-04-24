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
    --- @return any
    function vsp_mission.get_current_mission()
        return current_mission
    end

    function mission:mission()
        self.states = {}
        self.states.null_state = {
            update = function (state, dt) end,
            enter_callback = function (state) end,
            exit_callback = function (state) end,
            var = {},
            event_listeners = {}
        }
        self.initial_state = nil
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
    --- @param update? fun(state: table, dt: number)
    --- @param enter_callback? fun(state: table)
    --- @param exit_callback? fun(state: table)
    --- @return mission
    function mission:define_state(id, update, enter_callback, exit_callback)
        self.states[id] = {
            update = update or function (state, dt) end,
            enter_callback = enter_callback or function (state) end,
            exit_callback = exit_callback or function (state) end,
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

        self.current_state:exit_callback()

        self.current_state = self.states[new_state]

        self.current_state:enter_callback()
    end

    function mission:set_initial_state(state)
        self.initial_state = state
    end

    --- Defines a per-state event listener for event handlers
    --- (CreateObject etc)
    --- @param state any state id to attach listener
    --- @param what string name of the event handler
    --- @param func fun(...: any)
    function mission:define_event_listener(state, what, func)
        assert(self.states[state], string.format("VSP: Requested state %s does not exist", state))
        assert(what ~= "Start", "VSP: Start event listeners are forbidden, just use Start()")
        assert(what ~= "Update", "VSP: Update event listeners are forbidden, use the state update function")

        self.states[state].event_listeners[what] = self.states[state].event_listeners[what] or {}
        table.insert(self.states[state].event_listeners[what], func)
    end

    --- Defines a global event listener. Use this SPARINGLY because it can quickly devolve
    --- to voodoo code. If you find yourself storing condition variables to activate/deactivate
    --- global listeners that's a sign to refactor the mission script.
    --- @param what string name of the event handler
    --- @param func fun(...: any)
    function mission:define_global_listener(what, func)
        assert(what ~= "Start", "VSP: Start global listeners are forbidden, just use Start()")
        self.global_listeners[what] = self.global_listeners[what] or {}
        table.insert(self.global_listeners[what], func)
    end

    --- Builds a single object (this is just here so that it works in both SP and MP)
    --- @param ... any build object params
    function mission:build_single_object(...)
        return BuildObject(...)
    end

    --- Build multiple objects around the given area
    --- @param odfname string
    --- @param teamnum integer
    --- @param count integer
    --- @param position any
    --- @return table handles
    function mission:build_multiple_objects(odfname, teamnum, count, position)
        local return_handles = {}
        local max_radius = 10 * count
        for i = 1, count do
            local h = self:build_single_object(odfname, teamnum, GetPositionNear(position, 10, max_radius))
            table.insert(return_handles, h)
        end
        return return_handles
    end

    --- Immediately succeeds the mission
    --- @param filename string
    function mission:succeed(filename)
        SucceedMission(GetTime(), filename)
    end

    --- Immediately fails the mission
    --- @param filename string
    function mission:fail(filename)
        SucceedMission(GetTime(), filename)
    end

    function mission:do_state(dt)
        self.current_state:update(dt)
    end

    function vsp_mission.Start()
        if not current_mission then return end

        assert(current_mission.initial_state, "VSP: Initial mission state is undefined")
        current_mission:change_state(current_mission.initial_state)

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
        if not current_mission then return end
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