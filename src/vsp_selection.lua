--[[
=======================================
*   VT's Scrap Pool
*   
*   Selection Module
*
*   Fancy selection utilities
=======================================
--]]

local odf = require("vsp_odf")
local set = require("vsp_set")

local exu = require("exu")

local vsp_selection = {}
do
    --- Creates a filter function from the given unit
    --- @param selectable lightuserdata handle
    --- @return function filter
    function vsp_selection.match_unit(selectable)
        local target_odf = GetOdf(selectable)
        return function (selectable)
            return target_odf == GetOdf(selectable)
        end
    end

    --- Creates a type (offense, defense, utility etc) filter function from the given unit
    --- @param selectable lightuserdata handle
    --- @return function filter
    function vsp_selection.match_type(selectable)
        local class_label = GetClassLabel(selectable)
        return function (selectable)
            
        end
    end

    vsp_selection.default_chain_tolerance = 50.0

    --- Chain selects all units within the given tolerance that match the given filter
    --- 
    --- The filter function should return a boolean based off the handle input, it can
    --- also return a closure that will be constructed by the factory function with the
    --- first selectable unit as its parameter, this is necessary if you want the filter
    --- to maintain a state between recursive calls (like tracking the initial odf for example)
    --- @param selectable lightuserdata handle
    --- @param tolerance? number | nil distance in meters to chain the selection to the next unit
    --- @param filter_function? fun(selectable: lightuserdata): boolean | function custom filter to apply to the selectable handles4
    --- @return table selected table of selected units (empty if the selection fails) 
    function vsp_selection.chain_select(selectable, tolerance, filter_function)
        if not IsCraft(selectable) then return {} end -- This guarantees the unit will be selectable

        tolerance = tolerance or vsp_selection.default_chain_tolerance
        filter_function = filter_function or function (selectable) return true end

        local result = filter_function(selectable)
        if result == false then return {} end

        -- If the filter function returns a closure, initialize the state and
        -- use the closure as the new filter
        if type(result) == "function" then
            filter_function = result
            if not filter_function(selectable) then return {} end
        end

        exu.SelectNone()
        local visited = set.make_set()

        function recursive_case(selectable, tolerance, filter_function, visited, unit_odf)
            -- Don't select enemy units
            if GetTeamNum(selectable) ~= GetTeamNum(GetPlayerHandle()) then return end

            -- Apply the filter function
            if not filter_function(selectable) then return end

            if visited:contains(selectable) then return end
            visited:insert(selectable)

            exu.SelectAdd(selectable)
            StartSound("mnu_next.wav")

            for object in ObjectsInRange(tolerance, selectable) do
                if IsCraft(object) then
                    recursive_case(object, tolerance, filter_function, visited, unit_odf)
                end
            end
        end
        recursive_case(selectable, tolerance, filter_function, visited, unit_odf)

        return visited:get_table()
    end
end
return vsp_selection
