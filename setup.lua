print("Welcome to the ElliNet13 Antivirus setup script!")
print("This script will install/update the program.")
print("Are you sure you want to continue? (y/n)")
local answer = read()

local destination = "/av"

if _G.EAntiVirusStarted then
    print("Detected ElliNet13 Antivirus running")
    if not _G.EAVSafeMode then
        print("ElliNet13 Antivirus is not in safe mode")
        print("Please run the update using /av/safemode.lua")
        return
    end
end

if answer ~= "y" then
    print("Aborting")
    return
end

-- If the destination exists, only delete things that are NOT configs
if fs.exists(destination) then
    for _, item in ipairs(fs.list(destination)) do
        if item ~= "protectedFiles.txt" then
            fs.delete(destination .. "/" .. item)
        end
    end
else
    fs.makeDir(destination)
end

-- Copy the new files into the destination
local sourceFiles = fs.getDir(shell.getRunningProgram()) .. "/files"
for _, file in ipairs(fs.list(sourceFiles)) do
    fs.copy(sourceFiles .. "/" .. file, destination .. "/" .. file)
end

print("Setup finished!")
print("Installed to " .. destination)
print("To access websites, run the browser.lua script in the " .. destination .. " directory.")
print("To host your own website, run the server.lua script in the " .. destination .. " directory.")
