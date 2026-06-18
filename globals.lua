---@diagnostic disable: lowercase-global, unused-local, missing-return

eavvm = {
    --- Safe shutdown
    shutdown = function() end,
    -- Sync the filesystem
    sync = function() end,
    -- Request to mount a directory from the host
    ---@param hostDir string
    ---@param vmDir string
    ---@return boolean
    mount = function(hostDir, vmDir) end
}