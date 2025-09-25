-- Somewhat vibecoded

-- Settings
local length = 20 -- The length of the tail
local theme = "g" -- The color theme, green, red, blue, or rainbow (rain)
local vector = {0, 1} -- The direction of the fall
local backgroundColor = "f" -- In blit format
local tailEnds = true


-- Variables and Preset Tables
local width, height = term.getSize()
local dx, dy = vector[1], vector[2]

local characters = {
  "A","B","C","D","E","F","G",
  "H","I","J","K","L","M","N","O","P",
  "Q","R","S","T","U","V","W","X","Y","Z",
  "1","2","3","4","5","6","7","8","9",
  -- May be useable but sometimes break, may be an unusable symbol in there
  --"!", "\"", "#", "$", "%", "&", "(", ")", "*", "+", ",", "-", ".", "/",
  --":", ";", "<", "=", ">", "?", "@", "[", "]", "^", "_", "{", "|", "}", "~"
}

local themeGreen = {"5","d","8","7"} -- lime, green, light grey, grey
local themeBlue = {"3","b","8","7"} -- light blue, blue, light grey, grey
local themeRed = {"e","1","4","8","7"} -- red, orange, yellow, light grey, grey
local themeRainbow = {"e","1","4","d","b","a","2","8","7"} -- red, orange, yellow, green, blue, purple, magenta, light grey, grey

local drops = {} -- Table holding all the active "drops"


-- Helper Functions
local function getTableLength(table) -- the format "#table" only counts the values if they are in order and non-nil (for some reason)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

local function buildTailBlit(colorTable)
  local tail, m = {}, #colorTable
  if length <= m then
    for i = 1, length do tail[i] = colorTable[i] end
  else
    for i = 1, length do
      local idx = 1 + math.floor((i / length) * m)
      if idx > m then idx = m end
      tail[i] = colorTable[idx]
    end
  end
  return tail
end

local function onScreen(x, y)
  return x >= 1 and x <= width and y >= 1 and y <= height
end

-- Establishing some initial variables using functions for reuse
local tailBlit

if theme == "g" then
  tailBlit = buildTailBlit(themeGreen)
elseif theme == "b" then
  tailBlit = buildTailBlit(themeBlue)
elseif theme == "r" then
  tailBlit = buildTailBlit(themeRed)
elseif theme == "rain" then
  tailBlit = buildTailBlit(themeRainbow)
end

-- Operation functions
local function getRandomChar() return characters[math.random(getTableLength(characters))] end -- Get a random character from the list

local function spawnHead() -- Spawn head positions just off-screen so they flow in
  local x, y

  -- choose a random entry point on the entering edge, just off-screen
  if dy > 0 then y = -length elseif dy < 0 then y = height + length else y = math.random(1, height) end
  if dx > 0 then x = -length elseif dx < 0 then x = width  + length else x = math.random(1, width)  end

  -- orthogonal jitter for variety
  if dx == 0 and dy ~= 0 then
    x = math.random(1, width)                         -- vertical: random column
  elseif dy == 0 and dx ~= 0 then
    y = math.random(1, height)                        -- horizontal: random row
  else
    -- diagonal: pick a random intercept along the entering edge
    if dy > 0 and dx > 0 then        -- down-right: top or left edge
      if math.random() < 0.5 then x = math.random(-width, width); y = -length
      else y = math.random(-length, height); x = -length end
    elseif dy > 0 and dx < 0 then    -- down-left: top or right edge
      if math.random() < 0.5 then x = math.random(-width, 2 * width); y = -length
      else y = math.random(-length, height); x = width + length end
    elseif dy < 0 and dx > 0 then    -- up-right: bottom or left edge
      if math.random() < 0.5 then x = math.random(-width, width); y = height + length
      else y = math.random(1, height + length); x = -length end
    elseif dy < 0 and dx < 0 then    -- up-left: bottom or right edge
      if math.random() < 0.5 then x = math.random(1, 2 * width); y = height + length
      else y = math.random(1, height + length); x = width + length end
    end
  end

  return x, y
end

local function createDrop()
  local x, y = spawnHead()
  table.insert(drops, { x, y, { getRandomChar() } })
end

local function fullyPastScreen(x, y, n)
  -- n = #lastChars
  if dy > 0 then return y - (n - 1) > height end          -- moving down
  if dy < 0 then return y + (n - 1) < 1      end          -- moving up
  if dx > 0 then return x - (n - 1) > width  end          -- moving right
  if dx < 0 then return x + (n - 1) < 1      end          -- moving left
  return false
end

local function updateLastChars(last, newChar) -- Add a character to the list of last characters and make sure the length is not longer than it needs to be
  last[#last + 1] = newChar
  while #last > length do table.remove(last, 1) end
  return last
end

local function blitChar(x, y, char, blit) -- Blits a character at a position
  if onScreen(x,y) and char then
    term.setCursorPos(x, y)
    term.blit(char, blit, backgroundColor)
  end
end

local function drawDrop(drop) -- Draws a drop from head to tail at its current position
  local x, y, lastChars = drop[1], drop[2], drop[3]
  local n = #lastChars

  blitChar(x, y, lastChars[n], "0")

  for age = 1, n - 1 do
    local px = x - dx * age
    local py = y - dy * age
    local ch = lastChars[n - age]
    local fg = tailBlit[math.min(age, #tailBlit)]   -- palette has no white
    blitChar(px, py, ch, fg)
  end

  -- Optional: clear one past the tail end
  if tailEnds then
    local clearX = x - dx * n
    local clearY = y - dy * n
    blitChar(clearX, clearY, " ", backgroundColor)
  end
end

local function clearTailEnd(x, y, n)
  local clearX = x - dx * n
  local clearY = y - dy * n
  if onScreen(clearX, clearY) then
    term.setCursorPos(clearX, clearY)
    term.blit(" ", backgroundColor, backgroundColor)
  end
end

local function updateDrops() -- Draws the next frame of all drops
  for i = #drops, 1, -1 do
    local d = drops[i]
    d[1], d[2] = d[1] + dx, d[2] + dy           -- advance head
    updateLastChars(d[3], characters[math.random(#characters)])

    if fullyPastScreen(d[1], d[2], #d[3]) then
      -- wipe the last trailing cell once more in case it’s visible
      if tailEnds then
        clearTailEnd(d[1], d[2], #d[3])
      end
      table.remove(drops, i)
    else
      drawDrop(d)
    end
  end
end


-- Main Loop
while true do
  width, height = term.getSize()
  createDrop()
  updateDrops()
  sleep(0.01)
end
