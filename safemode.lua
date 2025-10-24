if not _G.EAntiVirusStarted then
    print("ElliNet13 Antivirus is not running or installed.")
    return
end

if _G.EAVSafeMode then
    print("ElliNet13 Antivirus is already in safe mode.")
    return
end

print("Which mode do you want to run?")
print("1. Edit startup")
print("2. Unquarantine items")
print("3. Edit protected files/folders list")
print("4. Update ElliNet13 Antivirus")
print("5. Safe mode shell (has less protections)")

local mode = read()
if mode == "1" then
    RestartTo("editStartup")
elseif mode == "2" then
    RestartTo("unquarantine")
elseif mode == "3" then
    RestartTo("EditProtectedFilesOrFoldersList")
elseif mode == "4" then
    RestartTo("update")
elseif mode == "5" then
    RestartTo("shell")
else
    print("Invalid mode")
end
