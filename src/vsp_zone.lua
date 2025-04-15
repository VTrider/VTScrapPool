--[[
=======================================
*   VT's Scrap Pool
*   
*   Zones Module
*
*   Advanced paths and fancy zone tools
=======================================
--]]

local object = require("vsp_object")

local vsp_zone = {}
do
    --- @class basic_zone : object
    local basic_zone = object.make_class("basic_zone")

    --- Abstract base zone constructor
    ---@return any
    function basic_zone.make_basic()
        local self = basic_zone:new()
        return self
    end

    --- Abstract method
    function basic_zone:is_inside()
        self:abstract("is_inside")
    end

    --- @class circle_zone : basic_zone, object
    --- @field center any vector
    --- @field radius number
    --- @field height number
    local circle_zone = object.make_class("circle_zone", basic_zone)

    --- Makes a circular zone with optional max height (default infinite) 
    --- @param center userdata vector
    --- @param radius number
    --- @param height? number
    --- @return circle_zone
    function vsp_zone.make_circle(center, radius, height)
        --- @class circle_zone
        local self = basic_zone.make_basic()
        self:inherit(circle_zone)

        assert(type(center) == "userdata")
        assert(radius)

        self.center = center
        self.radius = radius
        self.height = height or math.huge

        return self
    end

    function circle_zone:get_runtime_class()
        return "hi"
    end

    --- Check if a point is inside the circle zone
    --- @param point any vector, handle, or path
    function circle_zone:is_inside(point)
        local pos = GetPosition(point) or point
        return Distance2D(pos, self.center) < self.radius
    end

    --- @class sphere_zone : basic_zone, object
    --- @field center any vector
    --- @field radius number
    local sphere_zone = object.make_class("sphere_zone")

    --- Makes a spherical zone
    --- @param center userdata vector
    --- @param radius any
    --- @return sphere_zone
    function vsp_zone.make_sphere(center, radius)
        --- @class sphere_zone
        local self = basic_zone.make_basic()
        self:inherit(sphere_zone)

        assert(type(center) == "userdata")
        assert(radius)

        self.center = center
        self.radius = radius

        return self
    end

    --- Check if a point is inside the sphere zone
    --- @param point any vector, handle, or path
    --- @return boolean
    function sphere_zone:is_inside(point)
        local pos = GetPosition(point) or point
        return Distance3D(pos, self.center) < self.radius
    end

end
return vsp_zone