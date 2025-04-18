--[[
=======================================
*   VT's Scrap Pool
*   
*   Utilities Module
*
*   Things that don't fit in any other
*   category
=======================================
--]]

local vsp_util = {}
do
    local remove_queue = {}

    function vsp_util.deferred_remove(h)
        table.insert(remove_queue, h)
    end

    function vsp_util.Update(dt)
        if #remove_queue > 0 then
            RemoveObject(table.remove(remove_queue))
        end
    end
end
return vsp_util