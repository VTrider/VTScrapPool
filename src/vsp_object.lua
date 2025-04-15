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
    --- to the class's initializer function
    --- @generic T : object
    --- @return T
    function object:new(...)
        local object = setmetatable({}, { __index = self,
                                          __tostring = self.tostring })
        object.__runtime_class = self:instanceof()

        object:__dynamic_initializer(...)

        return object
    end

    --- Call the parent class constructor or method
    --- @generic T
    --- @param ... any
    --- @return T | nil
    function object:super(...)
        if ... then
            -- MUST USE the "this" self not the parent's self (colon syntax)
            -- in order to allow for base clase containers to use the right
            -- overridden functions
            self.__parent.__dynamic_initializer(self, ...)
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

    function object:__dynamic_initializer(...)
        self:abstract("__dynamic_initializer")
    end

    --- @return string
    function object:tostring()
        return string.format("VSP: Instance of class %s", self:instanceof())
    end
end
return vsp_object