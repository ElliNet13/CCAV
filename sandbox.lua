if not _G.EAntiVirusStarted then
    print("ElliNet13 Antivirus is not running or installed.")
    return
end

math.randomseed(os.time())

local function randomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""

    for i = 1, length do
        local index = math.random(1, #chars)
        result = result .. chars:sub(index, index)
    end

    return result
end

local antivirusDir = fs.getDir(shell.getRunningProgram())
local assetsDir = fs.combine(antivirusDir, "assets")
local sandboxFile = fs.combine("/", "eavsandbox" .. randomString(10) .. ".vfs")

print("Starting sandbox via OrangeBox...")

local orangebox = require("libraries.orangebox.orangebox")
local biosPath = fs.combine(assetsDir, "bios.lua")
local templatevmvfs = fs.combine(assetsDir, "templatevm.vfs")
if not fs.exists(biosPath) then
    error("Corrupted ElliNet13 Antivirus installation. BIOS not found.")
end
if not fs.exists(templatevmvfs) then
    error("Corrupted ElliNet13 Antivirus installation. Template VM not found.")
end
local bios = fs.open(biosPath, "r")
local vm = orangebox:new(bios.readAll())
bios.close()

fs.copy(templatevmvfs, sandboxFile)
vm:loadVFS(sandboxFile)
vm.apis.debug = debug
vm:reloadenv()
vm:resume()
while vm.running do
    vm:resume()
    vm:queueEvent(os.pullEventRaw())
end
fs.delete(sandboxFile)
print("EAV Sandbox has been closed.")