-- touch.lua
-- Usage: touch <filename>

local filename = ...
if not filename then
  print("Usage: touch <filename>")
  return
end

if fs.exists(filename) then
  -- update time (optional, just open/close)
  local f = fs.open(filename,"a")
  f.close()
else
  -- create new empty file
  local f = fs.open(filename,"w")
  f.close()
end
