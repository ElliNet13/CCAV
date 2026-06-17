if not _G.EAntiVirusStarted then
    print("ElliNet13 Antivirus is not running or installed.")
    return
end

local antivirusDir = fs.getDir(shell.getRunningProgram())
local assetsDir = fs.combine(antivirusDir, "assets")

print("Starting sandbox via OrangeBox...")

local orangebox = require("libraries.orangebox.orangebox")
local biosPath = fs.combine(assetsDir, "bios.lua")
if not fs.exists(biosPath) then
    error("Corrupted ElliNet13 Antivirus installation. BIOS not found.")
end
local bios = fs.open(biosPath, "r")
local vm = orangebox:new(bios.readAll())
bios.close()

vm.apis.debug = debug
vm:reloadenv()
vm:resume()
while vm.running do
    vm:resume()
    vm:queueEvent(os.pullEventRaw())
end
print("EAV Sandbox has been closed.")