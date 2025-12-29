local function CheckForSyncthingConflicts()
    awful.spawn.easy_async_with_shell("python3 " .. config_dir .. "detect_syncthing_conflicts.py", function(stdout)
        if stdout and stdout:match("%S") then -- Check if stdout is not empty or whitespace
            naughty.notify({ preset = naughty.config.presets.critical,
                title = "Syncthing conflict files found in the following directories:",
                text = stdout })
        end
    end)
end

-- create timer that periodically runs the function
local timer = gears.timer({
    timeout = 3600, -- one hour
    call_now = true,
    autostart = true,
    callback = CheckForSyncthingConflicts
})
