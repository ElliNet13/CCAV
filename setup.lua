if _G.EAntiVirusStarted then
    print("Detected ElliNet13 Antivirus running")
    if not _G.EAVSafeMode then
        print("ElliNet13 Antivirus is not in safe mode")
        print("Please run the update using /av/safemode.lua")
        return
    end
end

print("Welcome to the ElliNet13 Antivirus setup script!")
print("This script will install/update the program.")
local answer = nil
if not _G.EAVSafeMode then
    print("Are you sure you want to continue? (y/n)")
    answer = read()
else
    answer = "y"
end

local destination = "/av"

if answer ~= "y" then
    print("Aborting")
    return
end

-- If the destination exists, only delete things that are NOT configs
if fs.exists(destination) then
    for _, item in ipairs(fs.list(destination)) do
        if item ~= "protectedFiles.txt" and item ~= "quarantine" and item ~= "noupdate.flag" and item ~= "secrets" then
            fs.delete(fs.combine(destination, item))
        end
    end
else
    fs.makeDir(destination)
end

-- Copy the new files into the destination
local sourceFiles = fs.combine(fs.getDir(shell.getRunningProgram()), "files")
for _, file in ipairs(fs.list(sourceFiles)) do
    fs.copy(fs.combine(sourceFiles, file), fs.combine(destination, file))
end

print("Setup finished!")
print("Installed to " .. destination)
print("Running the antivirus...")
shell.setDir(destination)
shell.run("antivirus.lua")
