if not _G.EAntiVirusStarted then
    print("ElliNet13 Antivirus is not running or installed.")
    return
end

math.randomseed(os.time())

local VMDataDir = fs.combine("/", "vmmanagerdata")

package.path = "../libraries/?.lua;../libraries/?/init.lua;../libraries/metis/src/?.lua;" .. package.path

local argparse = require "metis.argparse"
local kb = require "metis.input.keybinding"

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
vm:mount("/vmbin", fs.combine(antivirusDir, "vmbin"))
if result.mountHostDir then
    vm:mount("/host", result.mountHostDir)
end

local nextaction = "nothing"

local eavvm = {
     shutdown = function()
         print("[EAV vmmanager] Shutting down VM...")
         vm.running = false
         print("[EAV vmmanager] Syncing filesystem...")
         vm:syncfs(true)
         print("[EAV vmmanager] VM shut down.")
     end,
     hshell = function(bg)
        if bg then
            nextaction = "hshellbg"
        else
            nextaction = "hshell"
        end
     end
}

vm.apis.debug = debug
vm.apis.eavvm = eavvm

vm:reloadenv()
vm:resume()
while vm.running do
    nextaction = "nothing"
    vm:resume()
    if nextaction == "hshell" then
        _G.vmrevert()
        shell.run("/rom/programs/shell.lua")
        _G.vmsetenv()
        vm:queueEvent("clear")
    elseif nextaction == "hshellbg" then
        _G.vmrevert()
        shell.openTab("/rom/programs/shell.lua")
        _G.vmsetenv()
    end
    if not vm.running then
        break
    end
    local eventData = {os.pullEvent()}
    local event = eventData[1]
    vm:queueEvent(table.unpack(eventData))
end

print('VM "' .. result.name .. '" has been closed.')