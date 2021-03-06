---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local type = type
local ipairs = ipairs
local io = { open = io.open }
local setmetatable = setmetatable
local math = { floor = math.floor }
local table = { insert = table.insert }
local string = {
    match = string.match,
    gmatch = string.gmatch
}
-- }}}


-- Disk I/O: provides I/O statistics for requested storage devices
module("vicious.dio")


-- Initialise function tables
local disk_usage = {}
local disk_total = {}

-- {{{ Disk I/O widget type
local function worker(format, disk)
    -- Get /proc/diskstats
    local f = io.open("/proc/diskstats")
    local disk_lines = {}

    for line in f:lines() do
        if string.match(line, "("..disk..")%s") then
            -- Todo: find a way to do this
            --for stat in string.gmatch(line, "%s([%d]+)") do
            --    table.insert(disk_lines, stat)
            --end
            --
            -- Skip first two matches
            local stat = string.gmatch(line, "%s([%d]+)")
            stat()
            stat()
            -- Store the rest
            for i = 1, 11 do
                table.insert(disk_lines, stat())
            end
        end
    end
    f:close()

    -- Ensure tables are initialized correctly
    while #disk_total < #disk_lines do
        table.insert(disk_total, 0)
    end

    local diff_total  = {}

    for i, v in ipairs(disk_lines) do
        -- Diskstats are absolute, substract our last reading
        diff_total[i] = v - disk_total[i]

        -- Store totals
        disk_total[i] = v
    end

    -- Calculate I/O
    disk_usage["{raw}"] = diff_total[7] + diff_total[3]
    -- Divide "sectors read" by 2 and 1024 to get KB and MB
    disk_usage["{kb}"] = math.floor(diff_total[7] + diff_total[3])/2
    disk_usage["{mb}"] = math.floor((diff_total[7] + diff_total[3])/10.24)/100

    return disk_usage
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
