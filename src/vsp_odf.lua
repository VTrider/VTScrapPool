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

    function odf:odf(file_name)
        local handle = OpenODF(file_name)
        assert(handle, "VSP: Invalid ODF file name")
        self.handle = handle
    end

    function vsp_odf.open(file_name)
        return odf:new(file_name)
    end

    function odf:get_bool(section, label, default)
        return GetODFBool(self.handle, section, label, default)
    end

    function odf:get_int(section, label, default)
        return GetODFInt(self.handle, section, label, default)
    end

    function odf:get_float(section, label, default)
        return GetODFFloat(self.handle, section, label, default)
    end

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