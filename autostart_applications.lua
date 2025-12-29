
-- do not remove these as they are a key part of the config!
awful.spawn.with_shell("picom") -- compositor
awful.spawn.with_shell("killall redshift ; sleep 2 ; redshift") -- has a delay at the start to make sure that it works correctly. If you don't want to use redshift then note that there already exists a button in the control panel for redshift, so you might have to tweak that one too to make the default state be off


for i, command in ipairs(settings.run_on_startup) do
    awful.spawn.with_shell(command)
end
