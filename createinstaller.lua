local disk = peripheral.find("drive")

if not disk or not disk.isDiskPresent() then
    print("No disk found")
    return
end

local destination = disk.getMountPath()

print("Are you sure you want to create an installer for " .. destination .. "? (y/n)")
local answer = read()

if answer ~= "y" then
    print("Aborting")
    return
end

for _, file in ipairs(fs.list(destination)) do
    fs.delete(fs.combine(destination, file))
end

fs.makeDir(fs.combine(destination, "files"))

local prodFiles = {
    "antivirus.lua",
    "safemode.lua",
    "libraries",
}

for _, file in ipairs(prodFiles) do
    fs.copy(fs.combine(fs.getDir(shell.getRunningProgram()), file), fs.combine(fs.combine(destination, "files"), file))
end

fs.copy(fs.getDir(shell.getRunningProgram()) .. "/setup.lua", destination.."/setup.lua")

local markerFile = fs.open(destination .. "/.EAVUpdate", "w")
markerFile.write("This file is a marker to tell ElliNet13 Antivirus that this is a update disk.")
markerFile.close()

print("Disk created!")