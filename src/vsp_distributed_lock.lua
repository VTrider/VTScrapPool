--[[
=======================================
*   VT's Scrap Pool
*   
*   Distributed Lock Module
*
*   Network synchronization object to
*   protect shared data
*
*   Use this to ensure that only one
*   player can access a resource or
*   function at a time (changing mission
*   state in coop for example).
=======================================
--]]

local future = require("vsp_future")
local net = require("vsp_net")
local object = require("vsp_object")
local util = require("vsp_util")

local vsp_distributed_lock = {}
do
    --- @class distributed_lock : object
    --- @field locked boolean
    --- @field id any
    local distributed_lock = object.make_class("distributed_lock")

    --- @type table <any, distributed_lock>
    local locks = {}

    local function try_lock_internal(id)
        if not IsHosting() then
            print(debug.traceback())
            error("VSP: non host called try_lock_internal")
        end
        assert(locks[id], string.format("VSP: Lock of id %d does not exist", id))
        local lock = locks[id]

        if lock.locked == false then
            lock.locked = true
            return true
        else
            return false
        end
    end

    local function unlock_internal(lock_id)
        local lock = locks[lock_id]
        lock.locked = false
    end

    net.set_function("try_lock_internal", try_lock_internal)
    net.set_function("unlock_internal", unlock_internal)

    local next_lock_id = 1

    function distributed_lock:distributed_lock()
        -- only the host stores state information,
        -- clients only have methods to request it from the host
        self.id = next_lock_id
        next_lock_id = next_lock_id + 1
        if IsHosting() then
            self.locked = false
            locks[self.id] = self
        end
    end

    --- Creates a distributed lock, the host is authoritative
    --- @return distributed_lock
    function vsp_distributed_lock.make_lock()
        return distributed_lock:new()
    end

    --- Tries to acquire the lock, returns a future with true if
    --- it succeeeds, otherwise false if the lock is in use
    --- @return future<boolean> acquired
    function distributed_lock:try_lock()
        if IsHosting() then
            -- Returns a completed future so the result can be
            -- handled the same no matter if the local player is
            -- hosting or not
            local result = future.make_future()
            result:resolve(try_lock_internal(self.id))
            return result
        else
            return net.async(net.host_id, "try_lock_internal", self.id)
        end
    end

    -- function distributed_lock:retry_lock(callback, ...)
    --     if IsHosting() then
    --         local result = future.make_future()
    --         result:resolve(try_lock_internal(self.id))
    --         if result:get() == true then
    --             callback(...)
    --         else            
    --             util.defer(distributed_lock.retry_lock, self, callback, ...)
    --         end
    --     else
    --         net.async(net.host_id, "try_lock_internal", self.id):wait(function (result)
    --             if result:get() == true then
    --                 callback(...)
    --             else
    --                 util.defer(distributed_lock.retry_lock, self, callback, ...)
    --             end
    --         end)
    --     end
    -- end

    --- Unlocks the lock, use carefully since there's nothing stopping
    --- you from unlocking when another client is using the lock.
    function distributed_lock:unlock()
        if IsHosting() then
            unlock_internal(self.id)
        else
            net.async(net.host_id, "unlock_internal", self.id)
        end
    end

    --- Executes the callback within the context of a lock. UNSAFE to use
    --- if the function executes asynchronously, use try_lock() instead and
    --- wait until you get a result to unlock.
    --- @param lock distributed_lock
    --- @param callback function
    --- @param ... any callback params
    function vsp_distributed_lock.lock_guard(lock, callback, ...)
        local params = {...}
        lock:try_lock():wait(function (acquired)
            if acquired then
                callback(unpack(params))
                lock:unlock()
            end
        end)
    end
end
return vsp_distributed_lock