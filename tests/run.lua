local source = debug.getinfo(1, "S").source:sub(2)
local root = source:gsub("/?tests/run%.lua$", "")
if root == "" then
  root = "."
end

package.path = root .. "/?.lua;" .. package.path

local result = dofile(root .. "/tests/release_files_test.lua")
if result.failures > 0 then
  io.stderr:write(string.format("%d of %d checks failed\n", result.failures, result.checks))
  os.exit(1)
end

print(string.format("%d checks passed", result.checks))
