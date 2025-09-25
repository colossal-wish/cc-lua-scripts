-- vi.lua
-- Usage: vi <filename>

local filename = ...
if not filename then
	print("Usage: vi <filename>")
	return
end

local lines = {}
if fs.exists(filename) then
	local f = fs.open(filename, "r")
	for line in f.readAll():gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	f.close()
end
if #lines == 0 then lines = { "" } end

local cursor = { x = 1, y = 1 }
local insertMode = false

local function redraw()
	term.clear()
	term.setCursorPos(1, 1)
	for i, line in ipairs(lines) do
		print(line)
	end
	term.setCursorPos(cursor.x, cursor.y)
end

local function save()
	local f = fs.open(filename, "w")
	f.write(table.concat(lines, "\n"))
	f.close()
end

redraw()
while true do
	local event, key = os.pullEvent("key")
	if key == keys.esc then
		if insertMode then
			insertMode = false
		else
			print("Save changes? (y/n)")
			local e, k = os.pullEvent("key")
			if k == keys.y then save() end
			break
		end
	elseif key == keys.i then
		insertMode = true
	elseif key == keys.up then
		cursor.y = math.max(1, cursor.y - 1)
		cursor.x = math.min(#lines[cursor.y] + 1, cursor.x)
	elseif key == keys.down then
		cursor.y = math.min(#lines, cursor.y + 1)
		cursor.x = math.min(#lines[cursor.y] + 1, cursor.x)
	elseif key == keys.left then
		cursor.x = math.max(1, cursor.x - 1)
	elseif key == keys.right then
		cursor.x = math.min(#lines[cursor.y] + 1, cursor.x + 1)
	elseif insertMode then
		if key == keys.backspace then
			if cursor.x > 1 then
				lines[cursor.y] = lines[cursor.y]:sub(1, cursor.x - 2) .. lines[cursor.y]:sub(cursor.x)
				cursor.x = cursor.x - 1
			elseif cursor.y > 1 then
				local prev = lines[cursor.y - 1]
				cursor.x = #prev + 1
				lines[cursor.y - 1] = prev .. lines[cursor.y]
				table.remove(lines, cursor.y)
				cursor.y = cursor.y - 1
			end
		elseif key == keys.enter then
			local rest = lines[cursor.y]:sub(cursor.x)
			lines[cursor.y] = lines[cursor.y]:sub(1, cursor.x - 1)
			table.insert(lines, cursor.y + 1, rest)
			cursor.y = cursor.y + 1
			cursor.x = 1
		else
			local char = keys.getName(key)
			if #char == 1 then
				lines[cursor.y] = lines[cursor.y]:sub(1, cursor.x - 1) .. char .. lines[cursor.y]:sub(cursor.x)
				cursor.x = cursor.x + 1
			end
		end
	end
	redraw()
end
