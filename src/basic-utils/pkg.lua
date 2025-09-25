-- pkg.lua
-- Usage:
--   pkg install <name> <url>
--   pkg update <name>
--   pkg list

local configFile = "/.pkgdb"
local db = fs.exists(configFile) and textutils.unserialize(fs.open(configFile, "r").readAll()) or {}

local function save()
	local f = fs.open(configFile, "w")
	f.write(textutils.serialize(db))
	f.close()
end

local cmd, arg1, arg2 = ...
if cmd == "install" and arg1 and arg2 then
	print("Downloading " .. arg1 .. " ...")
	if not http then error("HTTP not enabled") end
	local r = http.get(arg2)
	if not r then error("Download failed") end
	local f = fs.open(arg1, "w")
	f.write(r.readAll())
	f.close()
	r.close()
	db[arg1] = arg2
	save()
	print("Installed " .. arg1)
elseif cmd == "update" and arg1 then
	local url = db[arg1]
	if not url then error("Not installed") end
	print("Updating " .. arg1 .. " ...")
	local r = http.get(url)
	if not r then error("Download failed") end
	local f = fs.open(arg1, "w")
	f.write(r.readAll())
	f.close()
	r.close()
	print("Updated " .. arg1)
elseif cmd == "list" then
	for k, v in pairs(db) do print(k .. " -> " .. v) end
else
	print("Usage:\n pkg install <name> <url>\n pkg update <name>\n pkg list")
end
