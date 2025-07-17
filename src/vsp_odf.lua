--[[
=======================================
*   VT's Scrap Pool
*   
*   ODF Module
*
*   Better ODF interface
=======================================
--]]

local object = require("vsp_object")
local set = require("vsp_set")

local vsp_odf = {}
do
    --- @class odf : object
    --- @field handle userdata
    local odf = object.make_class("odf")

    odf.offense_class_labels = set.make_set(
        "apc",
        "walker",
        "wingman"
    )

    odf.defense_class_labels = set.make_set(
        "howitzer",
        "minelayer",
        "turrettank"
    )

    odf.utility_class_labels = set.make_set(
        "scavenger",
        "tug"
    )

    --- @type table<string, odf>
    local odf_cache = {}

    function odf:odf(string_name)
        local handle = OpenODF(string_name)
        assert(handle, "VSP: Invalid ODF file name")
        self.handle = handle
    end

    --- Opens the odf of the given name or of the object passed in.
    --- Caches opened odfs for greater efficiency.
    --- @param file_or_handle string | userdata
    --- @return odf
    function vsp_odf.open(file_or_handle)
        local string_name
        if type(file_or_handle) == "userdata" then
            string_name = GetOdf(file_or_handle)
        else
            string_name = file_or_handle
        end

        if odf_cache[string_name] then
            return odf_cache[string_name]
        end

        return odf:new(string_name)
    end

    --- Gets a boolean value
    --- @param section? string
    --- @param label string
    --- @param default? boolean
    --- @return boolean
    function odf:get_bool(section, label, default)
        return GetODFBool(self.handle, section, label, default)
    end

    --- Gets an integer value
    --- @param section? string
    --- @param label string
    --- @param default? integer
    --- @return integer
    function odf:get_int(section, label, default)
        return GetODFInt(self.handle, section, label, default)
    end

    --- Gets a float value
    --- @param section? string
    --- @param label string
    --- @param default? number
    --- @return number
    function odf:get_float(section, label, default)
        return GetODFFloat(self.handle, section, label, default)
    end

    --- Gets a string value
    --- @param section? string
    --- @param label string
    --- @param default? string
    --- @return string
    function odf:get_string(section, label, default)
        return GetODFString(self.handle, section, label, default)
    end

    function odf.is_offensive(h)
        return odf.offense_class_labels:contains(GetClassLabel(h))
    end

    function odf.is_defensive(h)
        
    end

    function odf.is_utility(h)
        
    end

    function odf.is_equal(h, j)
        return IsOdf(h, GetOdf(j))
    end
end
return vsp_odf