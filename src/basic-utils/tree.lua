-- tree.lua
-- Usage: tree [path]

local path = ...
path = path or ""
local function draw(dir, prefix)
	local list = fs.list(dir)
	table.sort(list)
	for i, name in ipairs(list) do
		local full = fs.combine(dir, name)
		local last = (i == #list)
		local branch = last and "└─ " or "├─ "
		print(prefix .. branch .. name)
		if fs.isDir(full) then
			draw(full, prefix .. (last and "   " or "│  "))
		end
	end
end

print(path == "" and "/" or path)
draw(path, "")
