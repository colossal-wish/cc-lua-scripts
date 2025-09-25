-- Entirely Vibecoded

-- ========= PRELUDE: Modal + Accelerating Popup Storm =========
math.randomseed(os.epoch("utc"))

local function clamp(v, a, b) if v < a then return a elseif v > b then return b else return v end end

local function centerText(win, y, s)
  local w = select(1, win.getSize())
  win.setCursorPos(math.max(1, math.floor((w - #s)/2) + 1), y)
  win.write(s)
end

local function drawBox(win, title, colorFrame, colorFill, colorTitle)
  local w,h = win.getSize()
  -- Fill
  win.setBackgroundColor(colorFill); win.setTextColor(colors.white)
  for y=1,h do win.setCursorPos(1,y); win.write(string.rep(" ", w)) end
  -- Frame
  win.setTextColor(colorFrame)
  win.setCursorPos(1,1);   win.write("+" .. string.rep("-", w-2) .. "+")
  for y=2,h-1 do
    win.setCursorPos(1,y); win.write("|")
    win.setCursorPos(w,y); win.write("|")
  end
  win.setCursorPos(1,h);   win.write("+" .. string.rep("-", w-2) .. "+")
  -- Title bar
  win.setBackgroundColor(colorFrame); win.setTextColor(colorTitle)
  win.setCursorPos(2,1); win.write((" %s "):format(title:sub(1, math.max(0, w-8))))
  win.setBackgroundColor(colorFill); win.setTextColor(colors.white)
end

local POP_LINES = {
  "Quantum Mainframe ERROR: 0x%08X",
  "Click to CLAIM your red pill voucher!",
  "Firewall caught concept-injection: 0x%08X",
  "Memory Leak in Dream Kernel (PID %d)",
  "License Expired: WAKING UP PROTOCOL",
  "GPU Stall @ glyph tile %d — apply patch?",
  "Chronometer drift %d%% — resync required",
  "Agent detected on port %d — quarantine?",
  "Defragging simulacra cache… %d%%",
  "Out of Belief. Insert More.",
  "Reality adapter not present (pid %d)",
}

local function randLine()
  local i = math.random(#POP_LINES)
  local t = POP_LINES[i]
  -- Fill any %X/%d with plausible values
  return t:format(
    math.random(0, 0xFFFFFFFF),
    math.random(100, 99999),
    math.random(0, 8191),
    math.random(0, 100),
    math.random(1, 65535),
    math.random(0, 100),
    math.random(100, 99999)
  )
end

-- Spawn a single popup window at (sx,sy)
local function spawnPopup(parent, sx, sy, ww, hh, title, body, style)
  local win = window.create(parent, sx, sy, ww, hh, true)
  drawBox(win, title, style.frame, style.fill, style.title)
  -- Draw body (soft wrap to 2 lines)
  win.setBackgroundColor(style.fill); win.setTextColor(colors.white)
  local inner = ww - 4
  local line1 = body:sub(1, math.max(0, inner))
  local line2 = body:sub(inner+1, 2*inner)
  win.setCursorPos(2,3); win.write(line1)
  if #line2 > 0 and hh >= 5 then win.setCursorPos(2,4); win.write(line2) end
  return {win=win, x=sx, y=sy, w=ww, h=hh}
end

-- Accelerating popup storm:
-- 1) First popup is centered.
-- 2) Subsequent popups spawn with a delay that shrinks each time (ease-in).
-- 3) Stops after `count` popups are on screen.
local function popupStorm(opts)
  opts = opts or {}
  local total = opts.count or 24
  local w,h   = term.getSize()
  local parent = term.current()
  local palette = {
    {frame=colors.gray,    fill=colors.lightGray, title=colors.black},
    {frame=colors.yellow,  fill=colors.black,     title=colors.yellow},
    {frame=colors.blue,    fill=colors.lightBlue, title=colors.white},
    {frame=colors.green,   fill=colors.black,     title=colors.lime},
    {frame=colors.magenta, fill=colors.black,     title=colors.pink},
    {frame=colors.red,     fill=colors.black,     title=colors.white},
  }

  local popups = {}

  -- 1) Centered first popup
  do
    local ww = clamp(math.floor(w*0.6), 24, w-2)
    local hh = 7
    local sx = math.floor((w - ww)/2) + 1
    local sy = math.floor((h - hh)/2) + 1
    local style = palette[math.random(#palette)]
    local title = "System Notice #1"
    local body  = randLine()
    table.insert(popups, spawnPopup(parent, sx, sy, ww, hh, title, body, style))
  end

  -- 2) Accelerating spawns until `total`
  local spawned = 1
  while spawned < total do
    spawned = spawned + 1

    -- Ease-in delay: starts slower, speeds up
    -- start_delay -> end_delay over N spawns using quadratic ease
    local start_delay = opts.start_delay or 0.55
    local end_delay   = opts.end_delay   or 0.06
    local t = (spawned-2) / math.max(1, total-2)  -- 0..1 over the remaining spawns
    local ease = t*t                              -- quadratic ease-in
    local delay = start_delay + (end_delay - start_delay) * ease
    sleep(delay)

    -- Random geometry
    local ww = math.random(18, math.max(20, math.floor(w*0.55)))
    local hh = math.random(5, 9)
    local sx = clamp(math.random(1, w-ww+1), 1, math.max(1, w-ww+1))
    local sy = clamp(math.random(1, h-hh+1), 1, math.max(1, h-hh+1))
    local style = palette[math.random(#palette)]
    local title = ("System Notice #%d"):format(spawned)
    local body  = randLine()

    table.insert(popups, spawnPopup(parent, sx, sy, ww, hh, title, body, style))
  end

  -- Optional brief hold so the user can absorb the chaos
  sleep(opts.hold or 0.8)
end

-- Centered modal with Yes / No buttons (mouse + keyboard).
-- Returns true if Yes clicked/chosen. (No triggers reboot per your spec.)
local function exitPrompt()
  local w,h = term.getSize()
  local mw, mh = math.max(36, math.floor(w*0.6)), 9
  local mx = math.floor((w - mw)/2) + 1
  local my = math.floor((h - mh)/2) + 1
  local win = window.create(term.current(), mx, my, mw, mh, true)

  drawBox(win, "Exit the Matrix", colors.gray, colors.black, colors.white)
  win.setTextColor(colors.white); win.setBackgroundColor(colors.black)
  centerText(win, 3, "Do you want to exit the Matrix?")
  centerText(win, 4, "(You may not be ready.)")

  local function drawBtn(x, y, label, bg, fg)
    win.setBackgroundColor(bg); win.setTextColor(fg)
    win.setCursorPos(x, y); win.write(" " .. label .. " ")
    win.setBackgroundColor(colors.black); win.setTextColor(colors.white)
  end

  local yesLabel, noLabel = " Yes ", " No "
  local gap = 6
  local yBtn = mh - 2
  local xYes = math.floor((mw - (#yesLabel + #noLabel + gap))/2) + 1
  local xNo  = xYes + #yesLabel + gap

  drawBtn(xYes, yBtn, yesLabel, colors.lime, colors.black)
  drawBtn(xNo,  yBtn, noLabel,  colors.red,  colors.white)

  while true do
    local ev, a,b,c = os.pullEvent()
    if ev == "key" then
      if a == keys.enter or a == keys.y then win.setVisible(false); return true end
      if a == keys.n or a == keys.escape then
        win.setVisible(false)
        term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear()
        term.setCursorPos(1, math.floor(h/2)); centerText(term, math.floor(h/2), "Remain ignorant")
        sleep(2)
        os.reboot()
      end
    elseif ev == "mouse_click" and a == 1 then
      local gx, gy = b, c
      if gy >= my and gy <= my+mh-1 and gx >= mx and gx <= mx+mw-1 then
        local lx, ly = gx - mx + 1, gy - my + 1
        if ly == yBtn and lx >= xYes and lx <= xYes + #yesLabel + 1 then
          win.setVisible(false); return true
        elseif ly == yBtn and lx >= xNo and lx <= xNo + #noLabel + 1 then
          win.setVisible(false)
          term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear()
          term.setCursorPos(1, math.floor(h/2)); centerText(term, math.floor(h/2), "Remain ignorant")
          sleep(2)
          os.reboot()
        end
      end
    end
  end
end

-- Orchestrator: show modal; on Yes -> popup storm; on No -> reboot (handled inside).
-- Returns after the storm so you can start your matrix rain.
local function runPrelude()
  term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear()
  local yes = exitPrompt()
  if yes then
    term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear()
    popupStorm({ count = 22, start_delay = 0.6, end_delay = 0.05, hold = 0.8 })
  end
  -- screen left as-is; your rain can clear/redraw as needed
end
-- ========= END PRELUDE =========

runPrelude()

shell.run("OSCR/programs/fun/theMatrix")
