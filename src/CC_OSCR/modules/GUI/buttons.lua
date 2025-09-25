local Button = {}
Button.__index = Button

-- Helper for windows
local function translateToLocalCoordinates(parent, absoluteX, absoluteY)
  if parent and parent.getPosition then
    local winX, winY = parent.getPosition()
    return absoluteX - winX + 1, absoluteY - winY + 1
  end
  return absoluteX, absoluteY
end

function Button.new(
  parent,
  text,
  startPosX,
  startPosY,
  textColor,
  bgColor,
  accentColor,
  borderRadius,
  onClick
  --style,
)
  -- Sets to provided values or defaults
  local newButton = setmetatable({
    parent     = parent,
    label      = text or "text",
    x          = startPosX or 1,
    y          = startPosY or 1,
    color      = textColor or colors.white,
    background = bgColor or colors.red,
    alt        = accentColor or colors.gray,
    border     = borderRadius or 0,
    isHovered  = false,
    isPressed  = false,
    onClick    = onClick or function() end,
    --look = style or "plain" -- "plain" or "stylish" (so far),
    --onHover = onHover
  }, Button)

  return newButton
end

function Button:containsPoint(pointX, pointY)
  local leftSide   = self.x - self.border
  local rightSide  = self.x + #self.label + self.border - 1
  local topSide    = self.y - self.border
  local bottomSide = self.y + self.border

  return pointX >= left and pointX <= right and pointY >= top and pointY <= bottom
end

function Button:draw()
  local background = self.background

  if self.isHovered then background = self.alt end
  if self.isPressed then background = colors.gray end

  local width = #self.label

  utils.fillRectangle(
    self.parent,
    self.x,
    self.y,
    width,
    1,
    background,
    self.border,
    self.alt
  )

  self:writeLabel()
end

function Button:writeLabel()
  terminal = self.parent
  terminal.setBackgroundColor(self.background)
  terminal.setTextColor(self.color)
  terminal.setCursorPos(self.x, self.y)
  terminal.write(self.label)
  terminal.setBackgroundColor(colors.black)
end

function Button:handleEvent(eventData)
  if eventName == "mouse_click" then
    local x, y = eventData[3], eventData[4]

    if self:containsPoint(x, y) then
      self.isPressed, self.isHovered = true, true
    else
      self.isPressed, self.isHovered = false, false
    end
    self:draw()

  elseif eventName == "mouse_up" then
    local x, y = eventData[3], eventData[4]
    local wasPressed = self.isPressed

    self.isPressed = false
    self.isHovered = self:containsPoint(x, y)
    self.draw()

    if wasPressed and self.isHovered then
      self.onClick(self)
    end
  end
end

return Button