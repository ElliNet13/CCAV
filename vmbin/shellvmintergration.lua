-- we now have access to shell
if _G.startedshellvmintegration then return end
_G.startedshellvmintegration = true
print("[EAV shellvmintergration] Welcome to your EAV VM!")

shell.setPath("/vmbin:" .. shell.path())