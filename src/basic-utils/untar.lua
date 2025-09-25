-- untar.lua
-- Usage: untar <tarfile> [outdir]
-- Extracts uncompressed tar archives.

local tarFile = ...
if not tarFile then
	print("Usage: untar <tarfile> [outdir]")
	return
end
local outDir = select(2, ...) or "."

local function trim(s) return s:match("^(.-)%s*$") end

local function oct2dec(o)
	local n = 0
	for i = 1, #o do
		local c = o:sub(i, i)
		if c:match("[0-7]") then
			n = n * 8 + tonumber(c)
		end
	end
	return n
end

local f = fs.open(tarFile, "rb")
if not f then error("Cannot open " .. tarFile) end

while true do
	local header = f:read(512)
	if not header or header == string.rep("\0", 512) then break end
	local name = trim(header:sub(1, 100))
	if name == "" then break end
	local size = oct2dec(header:sub(125, 136))
	local typeflag = header:sub(157, 157)
	local outPath = fs.combine(outDir, name)

	if typeflag == "5" then
		fs.makeDir(outPath)
	elseif typeflag == "0" or typeflag == "\0" then
		fs.makeDir(fs.getDir(outPath))
		local out = fs.open(outPath, "wb")
		local remaining = size
		while remaining > 0 do
			local chunk = math.min(remaining, 512)
			out.write(f:read(chunk))
			remaining = remaining - chunk
		end
		out.close()
		-- Skip padding to next 512-byte boundary
		local skip = (512 - (size % 512)) % 512
		if skip > 0 then f:read(skip) end
	else
		-- skip other types
		local skip = math.ceil(size / 512) * 512
		if skip > 0 then f:read(skip) end
	end
end

f.close()
print("Done.")
