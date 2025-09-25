-- OS Info

local width, height = term.getSize()

local utils = {}

utils.OSCR = "OSCR v0.4.1"
utils.OSCRBlit = "11db0888888"
utils.defaultTextColor = colors.orange
utils.defaultBackgroundColor = colors.black

function utils.getOSInfo()
  return utils.OSCR, utils.OSCRBlit
end

function utils.setDefaultColors()
  term.setBackgroundColor(utils.defaultBackgroundColor)
  term.setTextColor(utils.defaultTextColor)
end

function utils.getReadableRealTime()
  local time = os.date("%A %d %B %Y")
  return time
end

function utils.clearScreen( bgcolor, textColor )
  if bgcolor then
    term.setBackgroundColor(bgcolor)
  end

  if textColor then
    term.setTextColor(textColor)
  end

  term.clear()
end

function utils.getScreenCenter()
  local halfX = width / 2
  local halfY = height / 2
  return halfX, halfY
end

local function getTextLocation(parent, text, location)
  local w, h = parent.getSize()
  local cX = w / 2
  local cY = h / 2
  local length = #text
  local offset = #text / 2

  if location == "tl" then -- Top Left
    return 1, 1
  elseif location == "tc" then -- Top Center
    return cX - offset, 1
  elseif location == "tr" then -- Top Right
    return w - length, 1
  elseif location == "ml" then -- Middle Left
    return 1, cY
  elseif location == "mc" then -- Middle Center
    return cX - offset, cY
  elseif location == "mr" then -- Middle Right
    return w - length, cY
  elseif location == "bl" then -- Bottom Left
    return 1, h
  elseif location == "bc" then -- Bottom Center
    return cX - offset, h
  elseif location == "br" then -- Bottom Right
    return w - length, h
  end
end

function utils.placeTextAtLocation(
  parent,
  text,
  location,
  blit,
  blitPattern,
  blitBackground,
  offsetX,
  offsetY
)
  local x, y = getTextLocation(parent, text, location)
  local offX = offsetX or 0
  local offY = offsetY or 0

  parent.setCursorPos(x + offX, y + offY)

  if blit then
    parent.blit(text, blitPattern, blitBackground)
  else
    parent.write(text)
  end
end

function utils.writeCenteredText( y, text )
  local x = math.floor((width - #text) / 2) -- Get start pos of string
  term.setCursorPos(x,y)
  term.write(text)
end

function utils.fillRectangle(parent, x, y, w, h, insideColor, border, outsideColor)
  local termBackground = parent.getBackgroundColor()

  local function fill(xPos, yPos, width, height)
    for row = 0, height - 1 do
      parent.setCursorPos(xPos, yPos + row)
      parent.write(string.rep(" ", width))
    end
  end

  if border then
    parent.setBackgroundColor(outsideColor)
    fill(x - border, y - border, w + (border * 2), h + (border * 2))
    parent.setBackgroundColor(insideColor)
    fill(x, y, w, h)
  else
    parent.setBackgroundColor(insideColor)
    fill(x, y, w, h)
  end

  parent.setBackgroundColor(termBackground)
end

return utils
