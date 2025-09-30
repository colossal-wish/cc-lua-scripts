-- pkg.lua
local primarySource = "https://raw.githubusercontent.com/colossal-wish/cc-lua-scripts/main/src/"

local configFile = fs.combine("/", ".pkgdb")
local db = fs.exists(configFile) and textutils.unserialize(fs.open(configFile, "r").readAll()) or {}

local function save()
	local f = fs.open(configFile, "w")
	f.write(textutils.serialize(db))
	f.close()
end

local function download(url)
	if not http then error("HTTP API not enabled") end
	local r = http.get(url)
	if not r then return nil end
	local content = r.readAll()
	r.close()
	return content
end

-- Parse version string like "1.0.2" into {1,0,2}
local function parseVersion(v)
	local t = {}
	for num in v:gmatch("%d+") do
		table.insert(t, tonumber(num))
	end
	return t
end

-- Compare versions: returns true if v1 < v2
local function isOlder(v1, v2)
	local a, b = parseVersion(v1), parseVersion(v2)
	for i = 1, math.max(#a, #b) do
		local n1, n2 = a[i] or 0, b[i] or 0
		if n1 < n2 then return true end
		if n1 > n2 then return false end
	end
	return false
end

local function installPackage(name, url, visited)
	visited = visited or {}
	if visited[name] then error("Circular dependency detected: " .. name) end
	visited[name] = true

	url = url or primarySource .. "packages/" .. name .. "/package.lua"
	print("Fetching metadata for " .. name .. " ...")
	local content = download(url)
	if not content then error("Failed to fetch " .. name) end

	local func, err = load(content, "package:" .. name, "t", {})
	if not func then error("Failed to load package.lua: " .. err) end
	local meta = func()
	if not meta or not meta.version then error("Invalid package metadata for " .. name) end

	-- install dependencies first
	if meta.dependencies then
		for _, dep in ipairs(meta.dependencies) do
			local depName = dep:match("^[^>=<]+")
			local depUrl = nil
			installPackage(depName, depUrl, visited)
		end
	end

	-- check if installed
	local installed = db[name]
	if installed and not isOlder(installed.version, meta.version) then
		print(name .. " is up-to-date (v" .. installed.version .. ")")
		return
	end

	-- download and save the package
	print("Installing " .. name .. " v" .. meta.version .. " ...")
	local pkgData = download(meta.url or url)
	local f = fs.open(name, "w")
	f.write(pkgData)
	f.close()

	db[name] = { url = meta.url or url, version = meta.version }
	save()
	print("Installed " .. name .. " v" .. meta.version)
end

local function remove(name)
	if not db[name] then error("Package not installed: " .. name) end
	if fs.exists(name) then fs.delete(name) end
	db[name] = nil
	save()
	print("Removed " .. name)
end

local function list()
	if next(db) == nil then
		print("No packages installed.")
	else
		for k, v in pairs(db) do
			print(k .. " v" .. v.version .. " -> " .. v.url)
		end
	end
end

-- main
local cmd, arg1, arg2 = ...
if cmd == "install" and arg1 then
	installPackage(arg1, arg2)
elseif cmd == "update" and arg1 then
	installPackage(arg1)
elseif cmd == "remove" and arg1 then
	remove(arg1)
elseif cmd == "list" then
	list()
else
	print("Usage:\n pkg install <name> [url]\n pkg update <name>\n pkg remove <name>\n pkg list")
end
