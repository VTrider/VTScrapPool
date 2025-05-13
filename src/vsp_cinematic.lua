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

local barrier = require("vsp_barrier")
local net = require("vsp_net")
local net_player = require("vsp_net_player")

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

    --- Host variables
    local skip_vote_count = 0
    local skip_successful = false

    --- Sets the camera to a finished state if it's not already,
    --- also shows the scoreboard in multiplayer
    --- @return unknown
    function vsp_cinematic.try_finish()
        if is_cinematic_playing then
            is_cinematic_playing = false
            exu.SetShowScoreboard(true)
            skip_successful = false
            return CameraFinish()
        end
        return false
    end

    --- Client local variable
    local i_vote_skip = false

    net.set_function("reset_skip_votes", function ()
        i_vote_skip = false
    end)

    local function vote_skip(who)
        assert(net.is_hosting(), "VSP: Non host handled cinematic skip vote")

        skip_vote_count = skip_vote_count + 1
        net.display_message_all_clients(string.format("%s voted to skip - %d/%d", who, skip_vote_count, net_player.get_player_count()))

        if skip_vote_count >= net_player.get_player_count() then
            skip_successful = true
            skip_vote_count = 0
            i_vote_skip = false
            net.async(net.all_players, "reset_skip_votes")
            net.display_message_all_clients("Vote successful - skipping")
        end
    end

    net.set_function("client_vote_skip", vote_skip)

    local function try_skip()
        if net.is_hosting() then
            if not i_vote_skip then
                vote_skip(net_player.get_my_name())
                i_vote_skip = true
            end
        else
            if not i_vote_skip then
                net.async(net.host_id, "client_vote_skip", net_player.get_my_name())
                i_vote_skip = true
            end
        end
        i_vote_skip = true
    end

    function vsp_cinematic.skipped()
        if not is_cinematic_playing then return end

        if net.is_singleplayer_or_solo() then
            return CameraCancelled()
        end

        if CameraCancelled() then
            try_skip()
        end

        return skip_successful
    end
end
return vsp_cinematic