_G.utils = dofile("/OSCR/utils.lua") -- Sets utils to be used globally without require
_G.guiUtils = dofile("/OSCR/guiUtils.lua")

local width, height = term.getSize()
local screen = peripheral.find("monitor") or term.current()
term.redirect(screen)

-- Displays OS info
utils.clearScreen(32768, 2)
utils.placeTextAtLocation(
  screen,
  utils.OSCR,
  "bc",
  true,
  utils.OSCRBlit,
  string.rep("f", #utils.OSCR)
)

-- Writes current date
local days = os.day("ingame")
local time = textutils.formatTime(os.time("ingame"), false)
local timeString = "Day: " .. days .. " | Time: " .. time
local blitPattern = "11111" .. string.rep("0", #tostring(days)) .. "171111111" .. string.rep("0", #time)

utils.placeTextAtLocation(
  screen,
  timeString,
  "tc",
  true,
  blitPattern,
  string.rep("f", #timeString)
)

-- Loading bar
local glyph = " "
local loading = "Loading..."
local segments = 20
local barInside = string.rep(glyph, segments)

local centerX, centerY = utils.getScreenCenter()
local offset = segments / 2

utils.placeTextAtLocation(screen, loading, "mc", false)

term.setCursorPos(centerX - offset, centerY + 1)
term.setBackgroundColor(32)
textutils.slowPrint(barInside)

-- Finish
utils.clearScreen(32768, 1)
term.setCursorPos(1, 1)
shell.run("OSCR/programs/fun/matrixPrelude")
