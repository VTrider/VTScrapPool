--[[
=======================================
*   VT's Scrap Pool
*   
*   Set Module
=======================================
--]]

local object = require("vsp_object")

local vsp_set = {}
do
    --- @class set : object
    --- @field data table
    --- @field data_count number
    local set = object.make_class("set")

    function set:set(...)
        self.data = {}

        local items = {...}
        for _, value in pairs(items) do
            self.data[value] = true
        end

        self.data_count = #items
    end

    --- Set constructor
    --- @param ... any values
    --- @return set
    function vsp_set.make_set(...)
        return set:new(...)
    end

    --- Inserts element(s) into the set
    --- @param ... any
    --- @return self
    function set:insert(...)
        local items = {...}
        for _, value in pairs(items) do
            self.data[value] = true
        end
        self.data_count = self.data_count + #items
        return self
    end

    --- Removes element(s) from the set
    --- @param ... any elemment(s) to remove
    function set:remove(...)
        local items = {...}
        for _, value in pairs(items) do
            self.data[value] = nil
        end
        self.data_count = self.data_count - #items
    end

    --- @param value any
    --- @return boolean
    function set:contains(value)
        return self.data[value] == true
    end

    --- @return integer
    function set:size()
        return self.data_count
    end

    --- Returns the set's contents as a regular table
    --- @return table
    function set:get_table()
        local t = {}
        for value, _ in pairs(self.data) do
            t[#t+1] = value
        end
        return t
    end

    --- Iterator to use like pairs()
    --- @return function
    --- @return table
    --- @return nil
    function set:iterator()
        return next, self.data, nil
    end

    --- Makes the table use weak references
    function set:make_weak()
        setmetatable(self.data, { __mode = 'k' })
    end

    function set:tostring()
        local out_string = "{ "
        for item in self:iterator() do
            out_string = out_string .. item .. ", "
        end
        out_string = out_string .. '}'
        return out_string
    end
end
return vsp_set