-- cat.lua
-- Usage: cat <file1> [file2 ...]
-- https://raw.githubusercontent.com/colossal-wish/cc-lua-scripts/refs/heads/main/src/basic-utils/cat.lua

-- improve to process relative paths properly.
-- search working dir by default.

if not ... then
  print("Usage: cat <file1> [file2 ...]")
  return
end

local args = {...}

for _, filename in ipairs(args) do
  if fs.exists(filename) then
    local f = fs.open(filename,"r")
    print(f.readAll())
    f.close()
  else
    print("cat: file not found: "..filename)
  end
end
