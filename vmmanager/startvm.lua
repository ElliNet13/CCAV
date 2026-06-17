if not _G.EAntiVirusStarted then
    print("ElliNet13 Antivirus is not running or installed.")
    return
end

math.randomseed(os.time())

local VMDataDir = fs.combine("/", "vmmanagerdata")

package.path = "../libraries/?.lua;../libraries/?/init.lua;../libraries/metis/src/?.lua;" .. package.path

local argparse = require("metis.argparse")

-- Create parser
local parser = argparse.create()

-- Add flags
parser:add({ "name" }, {
    name = "name",
    required = true,
    doc = "[Required] Name of the VM",
})

parser:add({ "mountHostDir" }, {
    name = "mountHostDir",
    required = false,
    doc = "[Optional] Folder from host to mount in /host",
})

-- Parse CLI args
local result = parser:parse(...)

local vmDir = fs.combine(VMDataDir, result.name)
if not fs.exists(vmDir) then
    error("VM does not exist")
end

local antivirusDir = fs.combine(fs.getDir(shell.getRunningProgram()), "..")
local assetsDir = fs.combine(antivirusDir, "assets")

print("Starting VM via OrangeBox...")

local orangebox = require("orangebox.orangebox")
local biosPath = fs.combine(assetsDir, "bios.lua")
if not fs.exists(biosPath) then
    error("Corrupted ElliNet13 Antivirus installation. BIOS not found.")
end
local bios = fs.open(biosPath, "r")
local vm = orangebox:new(bios.readAll())
bios.close()

vm:loadVFS(fs.combine(vmDir, "filesystem.vfs"))
if result.mountHostDir then
    vm:mount("/host", result.mountHostDir)
end
vm.apis.debug = debug
vm:reloadenv()
vm:resume()
while vm.running do
    vm:resume()
    vm:queueEvent(os.pullEventRaw())
end
print('VM "' .. result.name .. '" has been closed.')