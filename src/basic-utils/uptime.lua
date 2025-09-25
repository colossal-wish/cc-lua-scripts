-- uptime.lua

local sec = os.clock()
local h = math.floor(sec / 3600)
local m = math.floor((sec % 3600) / 60)
local s = math.floor(sec % 60)
print(string.format("Uptime: %02dh:%02dm:%02ds", h, m, s))
