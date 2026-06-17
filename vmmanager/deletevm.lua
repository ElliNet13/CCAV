local VMDataDir = fs.combine("/", "vmmanagerdata")

package.path = "../libraries/?.lua;../libraries/?/init.lua;../libraries/metis/src/?.lua;" .. package.path

local argparse = require("metis.argparse")

-- Create parser
local parser = argparse.create()

-- Add flags
parser:add({ "name" }, {
    name = "name",
    required = true,
    doc = "Name of the VM",
})

-- Parse CLI args
local result = parser:parse(...)

local vmDir = fs.combine(VMDataDir, result.name)
if not fs.exists(vmDir) then
    error("VM does not exist")
end

print("Are you sure you want to delete " .. result.name .. "? (y/n)")
local answer = read()

if answer ~= "y" then
    print("Aborting")
    return
end

fs.delete(vmDir)
print('Deleted "' .. result.name .. '"')