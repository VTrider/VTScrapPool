--[[
=======================================
*   VT's Scrap Pool
*   
*   Object Manager Module
*
*   Tracks all objects efficiently
*   per update and powers modules that
*   require AllObjects()
*
*   Required Event Handlers:
*   - Update(dt)
=======================================
--]]

local future = require("vsp_future")
local set = require("vsp_set")

local vsp_object_manager = {}
do
    local registered_listeners = set.make_set()

    function vsp_object_manager.new_listener(callable)
        assert(type(callable) == "function", "VSP: Listener must be a function")
        registered_listeners:insert(callable)
    end

    function vsp_object_manager.delete_listener(callable)
        registered_listeners:remove(callable)
    end

    --- A list of objects that were in the game at Start()
    --- @type table
    local start_objects = {}
    local post_start = false
    local pre_start_obj_requests = {} -- handles people calling pre-start

    --- Returns a future with a table of handles of the objects that existed at game
    --- Start(). Calls after Start() will be immediately usable, calling before Start()
    --- loose in the script will return an unresolved future you will have to wait() on.
    --- @return future<table<userdata>>
    function vsp_object_manager.get_start_objects()
        local objects = future.make_future()

        if post_start then
            objects:resolve(start_objects)
        else
            pre_start_obj_requests[#pre_start_obj_requests+1] = objects
        end

        return objects
    end

    local function DispatchObjects()
        for object in AllObjects() do
            for listener in registered_listeners:iterator() do
                listener(object)
            end
        end
    end

    -- This will be called first before any other library start functions
    function vsp_object_manager.PreStart()
        for object in AllObjects() do
            start_objects[#start_objects+1] = object
        end
        -- Fulfill start object requests that happened before Start()
        for _, request in ipairs(pre_start_obj_requests) do
            request:resolve(start_objects)
        end
        post_start = true
    end

    function vsp_object_manager.Update(dt)
        DispatchObjects()
    end
end
return vsp_object_manager