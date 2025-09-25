-- curl-lite.lua
-- Usage: curl-lite <url> [output_file]

local url, outFile = ...
if not url then
	print("Usage: curl-lite <url> [output_file]")
	return
end

if not http then
	error("HTTP API not enabled in ComputerCraft config")
end

local response = http.get(url)
if not response then
	print("Failed to fetch: " .. url)
	return
end

local data = response.readAll()
response.close()

if outFile then
	local f = fs.open(outFile, "w")
	f.write(data)
	f.close()
	print("Saved to " .. outFile)
else
	print(data)
end
