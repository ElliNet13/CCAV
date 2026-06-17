local VMDataDir = "/" .. fs.combine("/", "vmmanagerdata")

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
if fs.exists(vmDir) then
    error("VM already exists")
end

fs.makeDir(vmDir)

print("Creating disk image")

-- Create example file quick
local exampleFile = "/" .. fs.combine(vmDir, "eav.txt")
local file = fs.open(exampleFile, "w")
file.write("Welcome to the ElliNet13 Antivirus VM!")
file.close()

-- Now we make the actual image
local command = "imgtool build compress " .. fs.combine(vmDir, "filesystem.vfs") .. " " .. exampleFile
local currentDir = shell.dir()
print("> cd /")
shell.setDir("/")
print("> " .. command)
shell.run(command)
print("> cd " .. currentDir)
shell.setDir(currentDir)
fs.delete(exampleFile)

print('Done creating "' .. result.name .. '"')