-- A base object class for any interactable GUI elements
-- All elements should have:
--   starting x & y coordinates (top left corner)
--   width and height
--   a unique name
--   onClick, onClickUp functions
--   events tied to it and registerEvent / removeEvent functions
--   draw, redraw, and remove functions
--   onScroll function
--   link to the custom event system
--   an object type
--   a enabled / disabled state

return function(name, GUIHandler) -- Factory function to create the prototype
  assert(GUIHandler~=nil, "Cannot find GUI handler. Object: "..name) -- Errors out if no handler present

  registeredEvents = {} -- Holds os.pull event listners

  local objectType = "Object"
  local isEnabled = true -- Wether the element is greyed out or not
  local parent
  local x, y, w, h

  local object { -- Set of object functions
    -- Getters
    getType = function(self)
      return objectType
    end,
    getName = function(self)
      return name
    end,
    getEnabled = function(self)
      return isEnabled
    end,
    getParent = function(self)
      return parent
    end,
    getEvents = function(self)
      return registeredEvents
    end,
    getLocation = function(self)
      return x, y, w, h
    end,

    -- Setters / Toggles
    toggle = function(self)
      isEnabled = not isEnabled
      return self
    end,
    setParent = function(self, newParent)
      if newParent ~= nil then
        self:remove()
        newParent:addChild(self)
        parent = newParent
      end
      return self
    end,
    setLocation = function(self, posX, posY, width, height)
      x, y, w, h = posX, posY, width, height
      self:draw()
    end,

    -- Utility
    remove = function(self)
      if parent ~=nil then
        parent:removeChild(self)
      end
      self:redraw()
      return self
    end,
    draw = function(self)

    end,
    redraw = function(self)

    end,

    -- Events
    registerEvent = function(self)

    end,
    removeEvent = function(self)

    end,
    onClick = function(self, ...)

    end,
    onClickUp = function(self, ...)

    end,
    onScroll = function(self, ...)

    end,
  }

  object.__index = object -- Sets up inheritance
  return object -- Return the object once created
end