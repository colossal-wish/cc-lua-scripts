-- A base object class for any interactable GUI elements
-- All elements should have:
--   starting x & y coordinates (top left corner)
--   width and height
--   onClick, onRelease, onDrag, onHover functions


return function(name)
  local name = name
  local objectType = "object"
  local isEnabled = false
  local parent
  local x, y, w, h = 0, 0, 0, 0

  local object = {
    getName = function(self)
      return name
    end,

    getType = function(self)
      return objectType
    end,

    getEnabled = function(self)
      return isEnabled
    end,

    getParent = function(self)
      return parent
    end,

    getPosition = function(self)
      return x, y, w, h
    end,

    enable = function(self)
      isEnabled = true
      return self
    end,

    disable = function(self)
      isEnabled = false
      return self
    end,

    remove = function(self)
      if (parent ~= nil) then
        parent:removeChild(self)
      end
      self:updateDraw()
      return self
    end,

    setPosition = function(self)

    onClick = function(self, ...)
      for _,v in pairs(table.pack(...))do
        if(type(v)=="function")then
          self:registerEvent("mouse_click", v)
        end
      end
      return self
    end
  }
