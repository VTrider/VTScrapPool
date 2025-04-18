--[[
=======================================
*   VT's Scrap Pool
*   
*   Cinematics Module
=======================================
--]]

local exu = require("exu")

local vsp_cinematic = {}
do
    local is_cinematic_playing = false

    function vsp_cinematic.try_ready()
        if not is_cinematic_playing then 
            is_cinematic_playing = true
            exu.SetShowScoreboard(false)
            return CameraReady()
        end
        return false
    end

    function vsp_cinematic.try_finish()
        if is_cinematic_playing then
            is_cinematic_playing = false
            exu.SetShowScoreboard(true)
            return CameraFinish()
        end
        return false
    end
end
return vsp_cinematic