--local buttons = require("buttons")

local headerWindow = {}
headerWindow.__index = headerWindow

function headerWindow.new(x, y, w, h, title, parentScreen)
  local parent = parentScreen or term.current()
  local window = window.create(parent, x, y, w, h, false)

  local self = setmetatable({
    parent = parent,
    window = window,
    x = x, y = y, w = w, h = h,
    title = title or "Window",
    dragging = false, ox = 0, oy = 0,
    closed = false
  }, headerWindow)

  self:draw()
  return self
end

function headerWindow:draw()
  local window, w, h, title = self.window, self.w, self.h, self.title
  local titleStartX = (w / 2) - (#title / 2)

  window.setBackgroundColor(colors.white)
  window.clear()

  window.setBackgroundColor(colors.blue)
  window.clearLine(1)

  window.setCursorPos(titleStartX, 1)
  window.write(title)

  -- TODO: Use the button API instead
  window.setCursorPos(w, 1)
  window.setBackgroundColor(colors.red)
  window.write("X")

  window.setVisible(true)
  window.redraw()
end

return headerWindow






