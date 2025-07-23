--[[
=======================================
*   VT's Scrap Pool
*
*   Time Module
=======================================
--]]

local object = require("vsp_object")
local set = require("vsp_set")

local vsp_time = {}
do
    function vsp_time.minutes(count)
        return count * 60.0
    end

    --- @class timer : object
    local timer = object.make_class("timer")

    --- @type set<timer>
    local all_timers = set.make_set()

    function timer:timer(duration, looping, callback, ...)
        self.duration = duration
        self.looping = looping or false
        self.callback = callback
        self.params = { ... }

        self.elapsed_time = 0.0
        self.active = false

        all_timers:insert(self)
    end

    --- Makes a timer that starts paused
    --- @param duration number
    --- @param looping boolean
    --- @param callback function
    --- @param ... any params
    --- @return timer
    function vsp_time.make_timer(duration, looping, callback, ...)
        return timer:new(duration, looping, callback, ...)
    end

    function timer:start()
        self.elapsed_time = 0.0
        self.active = true
        return self
    end

    function timer:stop()
        self.active = false
        all_timers:remove(self)
        return self
    end

    function timer:pause()
        self.active = false
        return self
    end

    function timer:resume()
        self.active = true
        return self
    end

    function timer:reset()
        self.elapsed_time = 0.0
        return self
    end

    function timer:is_active()
        return self.active
    end

    function timer:get_ratio()
        return self.elapsed_time / self.duration
    end

    function timer:__update(dt)
        if not self.active then return end

        self.elapsed_time = self.elapsed_time + dt

        if self.elapsed_time >= self.duration then
            self.callback(unpack(self.params))
            if self.looping then
                self:reset()
            else
                self:stop()
            end
        end
    end

    local function update_all_timers(dt)
        for timer in all_timers:iterator() do
            timer:__update(dt)
        end
    end

    function vsp_time.Update(dt)
        update_all_timers(dt)
    end
end
return vsp_time

