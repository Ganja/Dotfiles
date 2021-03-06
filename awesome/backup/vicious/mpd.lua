---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
--  * (c) Wicked, Lucas de Vries
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local string = { find = string.find }
-- }}}


-- Mpd: provides the currently playing song in MPD
module("vicious.mpd")


-- {{{ MPD widget type
local function worker(format)
    -- Get data from mpc
    local f = io.popen("ncmpcpp")
    local np = f:read("*line")
    f:close()

    -- Check if it's stopped, off or not installed
    if np == nil
    or (string.find(np, "MPD_HOST") or string.find(np, "volume:")) then
        return {"Stopped"}
    end

    -- Sanitize the song name
    local nowplaying = helpers.escape(np)

    -- Don't abuse the wibox, truncate
    nowplaying = helpers.truncate(nowplaying, 30)

    return {nowplaying}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
