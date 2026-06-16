local current = shell.path()

local oldVersion = os.version
---@diagnostic disable-next-line: duplicate-set-field
os.version = function()
    return "EAV VM Manager running on " .. oldVersion()
end

local antivirusDir = fs.getDir(shell.getRunningProgram())
local VMManagerDir = fs.combine(antivirusDir, "vmmanager")
local VMDataDir = fs.combine("/", "vmmanagerdata")

print("Loading VM Manager shell...")

if not fs.exists(VMDataDir) then
    fs.makeDir(VMDataDir)
end

shell.setPath("/" .. VMManagerDir .. "/")
shell.setDir(VMManagerDir)

shell.run("/rom/programs/shell.lua")

print("Exited VM manager shell")

shell.setPath(current)
os.version = oldVersion