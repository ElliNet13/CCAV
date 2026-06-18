-- we do not have shell yet
-- use events to pretend to type the command

if _G.startedbiosvmintegration then return end
_G.startedbiosvmintegration = true

local function emulateCommandRun(command, firstEnter)
    -- 1. Press Enter the first time
    if firstEnter then
        os.queueEvent("key", keys.enter, false)
    end

    -- 2. Type out the command string
    for i = 1, #command do
        local character = command:sub(i, i)
        local code = keys[character] or 0

        os.queueEvent("key", code, false)
        os.queueEvent("char", character)
    end

    -- 3. Press Enter the second time to execute it
    os.queueEvent("key", keys.enter, false)
end

emulateCommandRun("/vmbin/shellvmintergration.lua")

while true do
    local event = {os.pullEventRaw()}
    if event[1] == "clear" then
        term.clear()
        term.setCursorPos(1, 1)
    end
end
