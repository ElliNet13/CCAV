-- Scan all disk drives for startup files and optionally execute them (using shell.run)

local drives = { peripheral.find("drive") }
local found = {}

local function checkStartup(mount)
    if not mount then return false end

    local startupLua = fs.combine(mount, "startup.lua")
    local startupFile = fs.combine(mount, "startup")
    local startupDir = fs.combine(mount, "startup")

    if fs.exists(startupLua) then
        return true, startupLua
    end

    if fs.exists(startupFile) and not fs.isDir(startupFile) then
        return true, startupFile
    end

    if fs.exists(startupDir) and fs.isDir(startupDir) then
        return true, startupDir
    end

    return false
end

-- Scan all drives
for _, drive in ipairs(drives) do
    if drive.isDiskPresent() and drive.hasData() then
        local mount = drive.getMountPath()
        local ok, path = checkStartup(mount)

        if ok then
            table.insert(found, { mount = mount, path = path })
        end
    end
end

-- Silent exit if nothing found
if #found == 0 then
    return
end

-- Ask once
print("Startup files found on " .. #found .. " disk(s).")
write("Run all startup scripts? (y/n): ")

local input = read()
if input ~= "y" and input ~= "Y" then
    return
end

-- Run them using shell.run
for _, disk in ipairs(found) do
    print("Running from: " .. disk.mount)

    local ok, err = pcall(function()
        shell.run(disk.path)
    end)

    if not ok then
        print("Error: " .. tostring(err))
    end
end