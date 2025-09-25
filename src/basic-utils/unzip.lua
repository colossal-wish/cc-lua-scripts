-- unzip.lua
-- Usage: unzip <zipfile> [outdir]

local zipFile = ...
if not zipFile then
    print("Usage: unzip <zipfile> [outdir]")
    return
end

local outDir = select(2, ...) or "."

local function read_le_uint32(f)
	local b1, b2, b3, b4 = f:read(1):byte(), f:read(1):byte(), f:read(1):byte(), f:read(1):byte()
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

local function read_le_uint16(f)
	local b1, b2 = f:read(1):byte(), f:read(1):byte()
	return b1 + b2 * 256
end

local f = fs.open(zipFile, "rb")
if not f then error("Cannot open " .. zipFile) end

while true do
	local sig = f:read(4)
	if not sig then break end
	if sig ~= "\x50\x4b\x03\x04" then break end -- local file header
	f:read(2)                                  -- version
	f:read(2)                                  -- flags
	local method = read_le_uint16(f)
	f:read(4)                                  -- time/date
	f:read(4)                                  -- crc32
	local csize = read_le_uint32(f)
	local usize = read_le_uint32(f)
	local nlen = read_le_uint16(f)
	local elen = read_le_uint16(f)
	local name = f:read(nlen)
	f:read(elen) -- extra
	if method ~= 0 then
		error("File " .. name .. " is compressed (method " .. method .. ")—not supported")
	end
	local data = f:read(csize)
	local outPath = fs.combine(outDir, name)
	fs.makeDir(fs.getDir(outPath))
	local out = fs.open(outPath, "wb")
	out.write(data)
	out.close()
end
f.close()
print("Done.")
