
-- to speify what commands should be run during startup, look in config_settings.lua and not here!

-- do not remove these as they are a key part of the config!
awful.spawn.with_shell("picom") -- compositor
awful.spawn.with_shell("killall redshift ; sleep 2 ; redshift") -- has a delay at the start to make sure that it works correctly. If you don't want to use redshift then note that there already exists a button in the control panel for redshift, so you might have to tweak that one too to make the default state be off


for i, command in ipairs(settings.run_on_startup) do
    awful.spawn.with_shell(command)
end


-- set screen brightness to be bright in case it was set to dark from last session
if settings.darken_screens_with_DDC_CI then
    local file = io.open(config_dir .. "last_screen_brightness_state.txt", "r")
    local content = file:read("*a")
    file:close()

    if content == "dark" then
        awful.spawn.with_shell("ddcutil --display 1 setvcp 10 100 && ddcutil --display 2 setvcp 10 100")
        -- save brightness state to file
        local file = io.open(config_dir .. "last_screen_brightness_state.txt", "w")
        file:write("bright")
        file:close()
    end
end
