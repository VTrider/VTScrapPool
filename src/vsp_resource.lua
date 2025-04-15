--[[
=======================================
*   VT's Scrap Pool
*   
*   Custom Resource Module
=======================================
--]]

local object = require("vsp_object")

local vsp_resource = {}
do
    --- @class resource : object
    --- @field name string
    --- @field amount number
    --- @field min number
    --- @field max number
    local resource = object.make_class("resource")

    function resource:__dynamic_initializer(name, amount, min, max)
        self.name = name
        self.amount = amount
        self.min = min
        self.max = max
    end

    function vsp_resource.make_resource(name, amount, min, max)
        return resource:new(name, amount, min, max)
    end

    -- resource.scrap = resource.make_resource("scrap")
    -- resource.pilots = resource.make_resource("pilots")

    function resource:add(amount)
        if self.amount + amount > self.max then return end
        self.amount = self.amount + amount
        return self
    end

    function resource:remove(amount)
        if self.amount - amount < self.min then return end
        self.amount = self.amount - amount
        return self
    end

    function resource:get_ratio()
        return self.amount / self.max
    end

    vsp_resource.resource = resource
end
return vsp_resource