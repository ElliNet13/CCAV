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
print("4. Update ElliNet13 Antivirus from disk")
print("5. Safe mode shell (has less protections)")
print("6. HTTP update (Requires HTTP to be enabled, can be used to repair corrupted EAV files)")
print("7. Set startup password")

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
elseif mode == "6" then
    RestartTo("httpupdate")
elseif mode == "7" then
    RestartTo("startupPasswordSetup")
else
    print("Invalid mode")
end
