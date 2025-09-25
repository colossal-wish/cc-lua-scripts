-- grep.lua
-- Usage: grep <pattern> <file>

local pattern, filename = ...
if not pattern or not filename then
	print("Usage: grep <pattern> <file>")
	return
end

if not fs.exists(filename) then
	print("File does not exist: " .. filename)
	return
end

local f = fs.open(filename, "r")
local lineNum = 0
for line in f.readAll():gmatch("[^\r\n]+") do
	lineNum = lineNum + 1
	if line:find(pattern) then
		print(lineNum .. ":" .. line)
	end
end
f.close()
