--[[
=======================================
*   VT's Scrap Pool
*   
*   Cinematics Module
*
*   Protected wrappers for the stock
*   cinematic functions that
*   additionally hide your scoreboard
*   in multiplayer.
=======================================
--]]

local exu = require("exu")

local vsp_cinematic = {}
do
    local is_cinematic_playing = false

    --- Sets the camera to the ready state if it's not already ready,
    --- also hides the scoreboard in multiplayer
    --- @return boolean
    function vsp_cinematic.try_ready()
        if not is_cinematic_playing then 
            is_cinematic_playing = true
            exu.SetShowScoreboard(false)
            return CameraReady()
        end
        return false
    end

    --- Sets the camera to a finished state if it's not already,
    --- also shows the scoreboard in multiplayer
    --- @return unknown
    function vsp_cinematic.try_finish()
        if is_cinematic_playing then
            is_cinematic_playing = false
            exu.SetShowScoreboard(true)
            return CameraFinish()
        end
        return false
    end

    function vsp_cinematic.try_skip()
        if is_cinematic_playing then
            
        end
    end
end
return vsp_cinematic