-- df.lua

local total, used = fs.getSize("/") , 0
local function walk(path)
  for _, name in ipairs(fs.list(path)) do
    local full = fs.combine(path,name)
    if fs.isDir(full) then
      walk(full)
    else
      used = used + #fs.open(full,"r").readAll()
    end
  end
end
walk("/")

local free = total - used
print(string.format("Total: %d bytes\nUsed: %d bytes\nFree: %d bytes", total, used, free))
