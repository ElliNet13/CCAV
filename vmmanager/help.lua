print("All commands:")
shell.run("/rom/programs/list.lua", "/" .. fs.getDir(shell.getRunningProgram()))
print("Other commands:")
print("exit    help" )