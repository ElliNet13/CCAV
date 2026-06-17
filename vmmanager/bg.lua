-- SPDX-FileCopyrightText: 2017 Daniel Ratcliffe
--
-- SPDX-License-Identifier: LicenseRef-CCPL

if not shell.openTab then
    printError("Requires a advanced computer and multishell, but not found.")
    return
end

local tArgs = { ... }
if #tArgs > 0 then
    shell.openTab(table.unpack(tArgs))
else
    printError("Usage: bg <command> [arguments]")
    return
end