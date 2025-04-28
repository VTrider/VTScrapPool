--[[
=======================================
*   VT's Scrap Pool
*   
*   Object Oriented Programming Module
*
*   General OOP and class helpers
=======================================
--]]

local vsp_object = {}
do
    --- @class object
    --- @field __runtime_class string
    --- @field __parent table parent class
    local object = {}
    object.__index = object
    object.__runtime_class = "object"
    object.__parent = nil

    --- Class table initializer, inherits object
    --- @generic T
    --- @param name string name for runtime inspection
    --- @param parent? table parent class 
    --- @return T
    function vsp_object.make_class(name, parent)
        local self = {}
        self.__index = self
        self.__runtime_class = name
        self.__parent = parent or object
        setmetatable(self, { __index = parent or object,
                             __tostring = object.tostring })
        return self
    end

    --- Polymorphic initializer, inherits parent functions and forwards arguments
    --- to the class's constructor function
    --- @generic T : object
    --- @return T
    function object:new(...)
        local object = setmetatable({}, { __index = self,
                                          __tostring = self.tostring })
        object.__runtime_class = self:instanceof()

        assert(type(object[object.__runtime_class]) == "function", string.format("VSP: Class %s is missing constructor", object:instanceof()))

        object[object.__runtime_class](object, ...) -- Call constructor

        return object
    end

    --- Call the parent class constructor or method
    --- @generic T : object
    --- @param ... any
    --- @return T | any
    function object:super(...)
        if ... then
            -- MUST USE the "this" self not the parent's self (colon syntax)
            -- in order to allow for base clase containers to use the right
            -- overridden functions
            self.__parent[self.__parent.__runtime_class](self, ...)
            return
        else
            return self.__parent
        end
    end

    --- Gets the name of the class that the object is an instance of
    --- @return string
    function object:instanceof()
        return self.__runtime_class or "unknown"
    end

    --- Call in abstract method body to prevent usage
    --- @param func_string string name of the abstract method
    function object:abstract(func_string)
        error(string.format("VSP: Attempted to call abstract method %s:%s", self:instanceof(), func_string))
    end

    function object:object(...)
        self:abstract("object")
    end

    --- @return string
    function object:tostring()
        return string.format("VSP: Instance of class %s", self:instanceof())
    end

    --- Gets if the given data is an object
    --- @param o any
    --- @return boolean
    function vsp_object.is_object(o)
        return o.__runtime_class ~= nil
    end
end
return vsp_object