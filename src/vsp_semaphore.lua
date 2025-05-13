--[[
=======================================
*   VT's Scrap Pool
*   
*   Semaphore Module
*
*   A counting semaphore is a signaling
*   object that may be useful in
*   networked scenarios
=======================================
--]]

local future = require("vsp_future")
local net = require("vsp_net")
local object = require("vsp_object")

local vsp_semaphore = {}
do
    --- @class semaphore : object
    local semaphore = object.make_class("semaphore")

    local semaphores = {}

    local next_semaphore_id = 1

    local function try_acquire_internal(id)
        assert(semaphores[id], string.format("VSP: Semaphore of id %d does not exist", id))

        local s = semaphores[id]
        
        if s.counter == 0 then
            return false
        else
            s.counter = s.counter - 1
            assert(s.counter >= 0, "VSP: Semaphore counter dropped below 0")
            return true
        end
    end

    local function release_internal(id)
        assert(semaphores[id], string.format("VSP: Semaphore of id %d does not exist", id))

        local s = semaphores[id]
        s.counter = s.counter + 1
        assert(s.counter >= s.permits, "VSP: Semaphore counter exceeds number of permits")
    end

    net.set_function("try_acquire_internal", try_acquire_internal)
    net.set_function("release_internal", release_internal)

    function semaphore:semaphore(permits)
        self.id = next_semaphore_id
        next_semaphore_id = next_semaphore_id + 1
        if IsHosting() then
            self.permits = permits
            self.counter = self.permits
            semaphores[self.id] = self
        end
    end

    --- Makes a semaphore with the given amount of permits
    --- @param permits integer
    --- @return semaphore
    function vsp_semaphore.make_semaphore(permits)
        return semaphore:new(permits)
    end

    --- Tries to acquire a permit, returns a future that's true
    --- if it succeeds or false if there are none available
    --- @return future
    function semaphore:try_acquire()
        if IsHosting() then
            local result = future.make_future()
            result.result = try_acquire_internal(self.id)
            result.completed = true
            return result
        else
            return net.async(net.host_id, "try_acquire_internal", self.id)
        end
    end

    --- Releases a permit
    function semaphore:release()
        if IsHosting() then
            release_internal(self.id)
        else
            net.async(net.host_id, "release_internal", self.id)
        end
    end

    --- @class binary_semaphore : semaphore, object
    local binary_semaphore = object.make_class("binary_semaphore", semaphore)

    function binary_semaphore:binary_semaphore()
        self:super(1)
    end

    --- Makes a binary semaphore with a single permit
    --- @return binary_semaphore
    function vsp_semaphore.make_binary_semaphore()
        return binary_semaphore:new()
    end
end
return vsp_semaphore