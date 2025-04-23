--[[
=======================================
*   VT's Scrap Pool
*   
*   Distributed Lock Module
*
*   Synchronization object to protect
*   shared network data
*
*   This may or may not be necessary
*   for shared scrap and stuff
*   depending on if race conditions
*   are encountered in normal gameplay
=======================================
--]]

local future = require("vsp_future")
local net = require("vsp_net")
local object = require("vsp_object")
local set = require("vsp_set")

local exu = require("exu")

local vsp_distributed_lock = {}
do
    --- @class distributed_lock : object
    --- @field locked boolean
    --- @field id number
    local distributed_lock = object.make_class("distributed_lock")

    --- @type table <number, distributed_lock>
    local locks = {}

    local function try_lock_internal(id)
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

    local lock_requests = set.make_set()

    --- Creates a distributed lock, only the host is allowed to manage them
    --- @param id any
    --- @return distributed_lock | nil
    function vsp_distributed_lock.make_lock(id)
        if not IsHosting() then return nil end

        --- @class distributed_lock
        local self = distributed_lock:new()

        self.locked = false
        self.id = id
        
        locks[id] = self

        return self
    end

    --- Tries to acquire the lock, returns a future with true if
    --- it succeeeds, otherwise false if the lock is in use
    --- @param id any
    --- @return table future
    function distributed_lock.try_lock(id)
        exu.MessageBox("try lock")
        if IsHosting() then
            -- Returns a completed future so the result can be
            -- handled the same no matter if the local player is
            -- hosting or not
            local result = future.make_future()
            result.result = try_lock_internal(id)
            result.completed = true
            return result
        else
            return net.async(net.host_id, "try_lock_internal", id)
        end
    end

    function distributed_lock.unlock(lock_id)
        exu.MessageBox("unlock")
        if IsHosting() then
            unlock_internal(lock_id)
        else
            net.async(net.host_id, "unlock_internal", lock_id)
        end
    end

    function distributed_lock.Update(dt)
        for lock in lock_requests:iterator() do
            
        end
    end
end
return vsp_distributed_lock