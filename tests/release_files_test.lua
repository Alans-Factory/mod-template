local failures = 0
local checks = 0

local function check(condition, message)
  checks = checks + 1
  if not condition then
    failures = failures + 1
    io.stderr:write("FAIL: " .. message .. "\n")
  end
end

local function read_file(path)
  local handle = assert(io.open(path, "r"))
  local contents = handle:read("a")
  handle:close()
  return contents
end

local info = read_file("info.json")
local version = info:match('"version"%s*:%s*"([^"]+)"')
local name = info:match('"name"%s*:%s*"([^"]+)"')

check(name ~= nil and name ~= "", "info.json has a name")
check(version ~= nil and version:match("^%d+%.%d+%.%d+$") ~= nil, "info.json version is number.number.number")
check(info:match('"title"%s*:%s*"[^"]+"') ~= nil, "info.json has a title")
check(info:match('"author"%s*:%s*"[^"]+"') ~= nil, "info.json has an author")
check(info:match('"factorio_version"%s*:%s*"%d+%.%d+"') ~= nil, "info.json has a factorio_version")

local changelog = read_file("changelog.txt")
local first_line = changelog:match("^[^\n]*")
check(first_line == string.rep("-", 99), "changelog starts with 99 dashes")

local changelog_version = changelog:match("Version:%s*(%d+%.%d+%.%d+)")
check(changelog_version == version, "newest changelog version matches info.json")

return {failures = failures, checks = checks}
