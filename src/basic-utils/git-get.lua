-- git-get.lua
-- Usage: git-get <user>/<repo> [branch] [dest]
-- Grabs the GitHub "tarball" URL and extracts it.

local userrepo, branch, dest = ...
if not userrepo then
	print("Usage: git-get <user>/<repo> [branch] [dest]")
	return
end
branch       = branch or "main"
dest         = dest or select(3, string.find(userrepo, "/(.*)$")) or userrepo

local tarUrl = "https://codeload.github.com/" .. userrepo .. "/tar.gz/" .. branch
print("Downloading " .. tarUrl)

if not http then error("HTTP API not enabled in config") end
local r = http.get(tarUrl)
if not r then error("Download failed") end
local raw = r.readAll()
r.close()

-- This code expects a *plain* tar; GitHub gives a gzip stream.
-- Without a DEFLATE library we can’t decompress gzip.
error("GitHub serves gzip-compressed tarballs; pure Lua cannot extract this without a gunzip library.\n" ..
	"Either:\n" ..
	"  • host your own uncompressed tar/zip of the repo,\n" ..
	"  • or pair this script with a Lua gunzip or unzip library.")
