package.path = "/vmlibraries/?.lua;/vmlibraries/?/init.lua;/vmlibraries/metis/src/?.lua;" .. package.path

local argparse = require "metis.argparse"

local parser = argparse.create()

parser:add({ "hostDir" }, {
    name = "hostDir",
    required = true,
    doc = "Name of the folder on the host CraftOS",
})

parser:add({ "vmDir" }, {
    name = "vmDir",
    required = true,
    doc = "Name of the folder on the VM to mount into",
})

local result = parser:parse(...)

print("Requesting to mount...")
if eavvm.mount(result.hostDir, result.vmDir)
then
    print("Mount request accepted.")
else
    print("Mount request denied.")
end