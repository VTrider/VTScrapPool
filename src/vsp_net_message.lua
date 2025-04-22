--[[
=======================================
*   VT's Scrap Pool
*   
*   Net Messages Enum
=======================================
--]]

local enum = require("vsp_enum")

local net_message = enum.make_enum(
    "async_request",
    "resolve_future",
    "remote_delete"
)

net_message.vsp = 'v'

return net_message