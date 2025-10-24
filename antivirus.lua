if _G.EAntiVirusStarted then return end
_G.EAntiVirusStarted = true
_G.EAVSafeMode = false

local shift = os.getComputerID()

-- Normalizes a path
local function normalizePath(path)
    if string.sub(path, 1, 1) ~= "/" then
        path = "/" .. path
    end
    if #path > 1 and string.sub(path, -1) == "/" then
        path = string.sub(path, 1, -2)
    end
    return path
end

-- Encode/decode
local function encode(text)
    local out = {}
    for i = 1, #text do
        out[i] = string.char((string.byte(text, i) + shift) % 256)
    end
    return table.concat(out)
end

local function decode(text)
    local out = {}
    for i = 1, #text do
        out[i] = string.char((string.byte(text, i) - shift) % 256)
    end
    return table.concat(out)
end

-- Paths
local antivirusDir = normalizePath(fs.getDir(shell.getRunningProgram()))
local quarantineFolder = normalizePath(antivirusDir .. "/quarantine")
local protectedListFile = fs.combine(antivirusDir, "protectedFiles.txt")
local libraries = fs.combine(antivirusDir, "libraries")

if not fs.exists(quarantineFolder) then
    fs.makeDir(quarantineFolder)
end

print("[Antivirus] This computer is secured by ElliNet13 Antivirus")

-- Keep original functions
local oldDelete = fs.delete
local oldMove   = fs.move
local oldOpen   = fs.open
local reboot    = os.reboot
local getProgram = shell.getRunningProgram

-- Function to check if the AV is at the top of the startup file
local function checkStartup()
    local startup
    local AVLine = 'shell.run("/av/antivirus.lua");'

    -- Determine which startup file to use
    if fs.exists("/startup") then
        startup = "/startup"
    elseif fs.exists("/startup.lua") then
        startup = "/startup.lua"
    else
        oldOpen("/startup", "w").close()
        startup = "/startup"
    end

    -- Read the whole file
    local file = oldOpen(startup, "r")
    local data = file.readAll()
    file.close()

    -- Check if the file starts with AVLine
    local firstLine = data:match("([^\n]*)") -- extract first line
    if firstLine ~= AVLine then
        print("[Antivirus] Fixing startup file")
        local newFile = oldOpen(startup, "w")
        newFile.write(AVLine .. "\n" .. data)
        newFile.close()
        print("[Antivirus] Fixed startup file")
        print("[Antivirus] Rebooting in 5 seconds...")
        os.sleep(5)
        reboot()
    end
end

checkStartup()

-- Load protected files/folders list
local protectedList = {}

if fs.exists(protectedListFile) then
    local file = oldOpen(protectedListFile, "r")
    local data = file.readAll()
    file.close()

    for line in data:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$") -- trim whitespace
        if line ~= "" and string.sub(line, 1, 1) == "/" then
            table.insert(protectedList, line)
        end
    end
else
    -- Create empty file if it doesn't exist
    oldOpen(protectedListFile, "w").close()
end

-- Helper: is inside AV
local function isInAV(path)
    path = normalizePath(path)
    return string.sub(path, 1, #antivirusDir) == antivirusDir
end

-- Helper: is inside ROM
local function isInROM(path)
    path = normalizePath(path)
    local rom = "/rom"
    return string.sub(path, 1, #rom) == rom
end

-- Helper: is protected
local function isProtected(path)
    path = normalizePath(path)

    -- Always protect AV folder, ROM, startup, EAVStartup
    if isInAV(path)
        or isInROM(path)
        or path == normalizePath("/startup")
        or path == normalizePath("/startup.lua")
        or path == normalizePath("/EAVStartup") then
        return true
    end

    -- Check against protected list
    for _, protectedPath in ipairs(protectedList) do
        if fs.isDir(protectedPath) then
            -- If it's a folder, check if path is inside that folder
            if string.sub(path, 1, #protectedPath + 1) == protectedPath .. "/" then
                return true
            end
        else
            -- If it's a file, exact match
            if path == protectedPath then
                return true
            end
        end
    end

    return false
end

-- Restart to
if fs.exists("/EAVStartup") then
    term.clear()
    term.setCursorPos(1, 1)
    print("[Antivirus] Found secure mode startup flag")
    print()
    _G.EAVSafeMode = true

    -- Open and read flag file
    local file = fs.open("/EAVStartup", "r")
    local data = file.readAll()
    file.close()

    -- Remove the flag
    oldDelete("/EAVStartup")

    -- Trim whitespace/newlines
    data = data:match("^%s*(.-)%s*$") or ""

    if data == "editStartup" then
        print("[Antivirus] Opening edit for you to edit startup")
        os.sleep(2)

        if fs.exists("/startup") then
            shell.run("edit", "/startup")
            checkStartup()
        elseif fs.exists("/startup.lua") then
            shell.run("edit", "/startup.lua")
            checkStartup()
        else
            print("[Antivirus] No startup file found")
            print("[Antivirus] How are you running this program if you have no startup?")
        end
    elseif data == "unquarantine" then
        -- List files in quarantine folder
        local files = fs.list(quarantineFolder)
        if #files == 0 then
            print("[Antivirus] Quarantine folder is empty")
        else
            print("[Antivirus] Files in quarantine:")
            os.sleep(1)
            shell.run("ls", quarantineFolder)

            -- Get user input (just the number)
            print("[Antivirus] Enter the file number to unquarantine:")
            local inputNum = read()

            -- Find the matching file
            local matchedFile
            for _, file in ipairs(files) do
                if file:match("%-" .. inputNum .. "$") then
                    matchedFile = file
                    break
                end
            end

            if matchedFile then
                local path = fs.combine(quarantineFolder, matchedFile)
                local fileData = fs.open(path, "r")
                local decodedData = decode(fileData.readAll())
                fileData.close()

                print("[Antivirus] Where should the file be unquarantined:")
                local dest = normalizePath(read())
                if isProtected(dest) then
                    print("[Antivirus] Cannot unquarantine to protected location: " .. dest)
                else
                    -- Write decoded file
                    local outFile = fs.open(dest, "w")
                    outFile.write(decodedData)
                    outFile.close()

                    -- Remove from quarantine
                    oldDelete(path)
                    print("[Antivirus] Successfully unquarantined: " .. matchedFile)
                end
            else
                print("[Antivirus] No quarantined file ends with: -" .. inputNum)
            end
        end

    elseif data == "EditProtectedFilesOrFoldersList" then
        print("[Antivirus] Editing protected files list (you will not be able to edit files in thus list)")
        print("[Antivirus] Note: All lines not starting with / are ignored (you can use them as comments)")
        print("[Antivirus] Seperate file and folder name with new lines")
        print("[Antivirus] Folders in the list will have all the files inside be protected.")
        print("[Antivirus] If you put a file name in the list, only it will be protected.")

        os.sleep(5)
        shell.run("edit", protectedListFile)
    elseif data == "update" then
        print("[Antivirus] Finding disk...")
        local disk = peripheral.find("drive")
        if not disk or not disk.isDiskPresent() or not disk.hasData() then
            print("[Antivirus] No floppy disk found")
            return
        end

        local disk = disk.getMountPath()

        print("[Antivirus] Found disk. Checking if it contains the marker...")
        if not fs.exists(fs.combine(disk, "/.EAVUpdate")) then
            print("[Antivirus] Marker not found. No update available.")
            return
        end

        print("[Antivirus] Marker found.")
        print("[Antivirus] Do you trust this disk? A bad disk can corrupt your ElliNet13 Antivirus install and disable it. (y/n)")
        local answer = read()
        if answer ~= "y" then
            print("[Antivirus] Aborting update.")
            return
        end
        print("[Antivirus] Running setup...")
        shell.run(fs.combine(disk, "setup.lua"))
    elseif data == "httpupdate" then
        local CCArchive = fs.combine(libraries, "CC-Archive")
        print("[Antivirus] Starting HTTP update...")
        local tempDir = "/tmpEAVhttpupdate" .. math.random(10000, 99999)
        fs.makeDir(tempDir)

        if not http then print("[Antivirus] HTTP is disabled and not available. Aborting update.") return end

        print("[Antivirus] Checking internet connection...")
        local testRequest = http.get("https://example.tweaked.cc")
        if testRequest.getResponseCode() ~= 200 then print("[Antivirus] Could not connect to example.tweaked.cc. You may be offline. Aborting update.") return end

        print("[Antivirus] Downloading update...")
        local file = http.get("https://n8n.ellinet13.com/webhook/update.tar.gz?item=eav")
        if file.getResponseCode() ~= 200 then print("[Antivirus] Could not download update because of HTTP error " .. file.getResponseCode() .. ". Aborting update.") return end

        local fileData = file.readAll()
        file.close()

        if fileData == nil or fileData == "" then
            print("[Antivirus] Could not download update, file is empty. Aborting update.")
            return
        end
        
        local file = fs.open(fs.combine(tempDir, "eav.tar.gz"), "w")
        file.write(fileData)
        file.close()

        local tar = normalizePath(fs.combine(CCArchive, "tar.lua"))
        print("[Antivirus] Using tar: " .. tar)

        print("[Antivirus] Extracting update...")
        shell.setDir(tempDir)
        shell.run(tar, "-xzf", "eav.tar.gz")
        
        print("[Antivirus] Running setup...")
        shell.run("setup.lua")

        print("[Antivirus] Cleaning up...")
        shell.setDir("/")
        fs.delete(tempDir)
    elseif data == "shell" then
        print("[Antivirus] Are you SURE you want to enter the safe mode shell? It has less protections and should not be used unless you know what you're doing. (y/n)")
        local answer = read()
        if answer ~= "y" then
            print("[Antivirus] Aborting safe mode shell.")
        end
        print("[Antivirus] Starting safe mode shell...")
        shell.run("shell")
    else
        print("[Antivirus] Invalid flag: " .. data)
    end

    print("[Antivirus] Safe mode finished. Rebooting in 5 seconds...")
    os.sleep(5)
    reboot()
end

-- Quarantine function (does NOT move AV or /rom scripts)
local function quarantine()
    local offender = getProgram()
    if isProtected(offender) then
        print("[Antivirus] Access denied: cannot quarantine system or AV files: " .. offender)
    else
        print("[Antivirus] Quarantining: " .. offender)
        local dest = fs.combine(quarantineFolder, fs.getName(offender)) .. "-" .. math.random(10000, 99999)
        local file = oldOpen(offender, "r")
        local encoded = encode(file.readAll())
        file.close()
        oldDelete(offender)
        local newFile = oldOpen(dest, "w")
        newFile.write(encoded)
        newFile.close()
        print("[Antivirus] Quarantined: " .. offender)
        print("[Antivirus] Quarantined to: " .. dest)
    end
    print("Rebooting in 5 seconds to prevent further damage...")
    os.sleep(5)
    reboot()
end

-- Safe delete
fs.delete = function(path)
    path = normalizePath(path)
    if isProtected(path) then
        print("[Antivirus] Access denied: cannot delete protected file: " .. path)
        quarantine()
        return false
    end
    return oldDelete(path)
end

-- Safe move
fs.move = function(src, dest)
    src  = normalizePath(src)
    dest = normalizePath(dest)
    if isProtected(src) or isProtected(dest) then
        print("[Antivirus] Access denied: cannot move protected file: " .. src)
        quarantine()
        return false
    end
    return oldMove(src, dest)
end

-- Safe write
fs.open = function(path, mode)
    path = normalizePath(path)
    local unsafeModes = { w = true, a = true, wb = true, ab = true }
    if isProtected(path) and unsafeModes[mode] then
        error("[Antivirus] Access denied: cannot modify protected file: " .. path, 2)
    end
    return oldOpen(path, mode)
end

-- Safe restart to flag
function RestartTo(flag)
    if not isInAV(normalizePath(getProgram())) then error("[Antivirus] Access denied: cannot change restart to flag", 2) end
    print("[Antivirus] Setting startup flag: " .. flag)
    local file = oldOpen("/EAVStartup", "w")
    file.write(flag)
    file.close()
    print("Rebooting into mode")
    os.sleep(2)
    reboot()
end

_G.RestartTo = RestartTo

print("[Antivirus] Antivirus started")
