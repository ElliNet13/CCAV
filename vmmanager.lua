if not _G.EAntiVirusStarted then
    print("ElliNet13 Antivirus is not running or installed.")
    return
end
if _G.EAVSafeMode then
    print("Can not use VMs in safe mode.")
    return
end

local current = shell.path()

local oldVersion = os.version
---@diagnostic disable-next-line: duplicate-set-field
os.version = function()
    return "EAV VM Manager running on " .. oldVersion()
end

local antivirusDir = fs.getDir(shell.getRunningProgram())
local VMManagerDir = fs.combine(antivirusDir, "vmmanager")
local VMDataDir = "/" .. fs.combine("/", "vmmanagerdata")

print("Loading VM Manager shell...")

if not fs.exists(VMDataDir) then
    fs.makeDir(VMDataDir)
end

local function setenv()
    shell.setPath("/" .. VMManagerDir .. "/")
    shell.setDir(VMManagerDir)

    shell.setAlias("exit", "/rom/programs/exit.lua")
    shell.setAlias("clear", "/rom/programs/clear.lua")
end

setenv()
_G.vmsetenv = setenv

local function revertenv()
    shell.setPath(current)
    os.version = oldVersion
    shell.setDir(antivirusDir)
end
_G.vmrevert = revertenv

shell.run("/rom/programs/shell.lua")

print("Exited VM manager shell")

revertenv()
_G.vmsetenv = nil
_G.vmrevert = nil