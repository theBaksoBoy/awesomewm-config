
-- here you will find both settings for general configurations for the awesome config

local settings = {}

-- If you want to add/remove/change the tag selection then good luck. There is no super easy way of doing it.
-- If you want to add a tag, *unless I remember something wrong* you have to first go into rc.lua and change tag_count.
-- Then change the tags variable to add another entry. Then finally(?) go into wibar/tag_button_widget and create a new
-- file named tag_n.png (with n being the tag number) which is used as the image for the tag button.

settings.terminal = "kitty"
settings.browser = "firefox"
settings.file_browser_primary = "kitty -- spf" -- spf = superfile. Note that bat, a nerd icon font, and thunar are also used with your spf config
settings.file_browser_secondary = "thunar"
-- note that Emacs stuff is based specifically on Doom Emacs. I'm not sure if vanilla Emacs's commands look any different
settings.emacs = "/usr/bin/emacsclient -c -a 'emacs'" -- if you don't want to use emacs then you can ignore this. All it will do is make the hotkey for launching it not work
settings.emacs_server = "/usr/bin/emacs --daemon" -- if you don't want to use emacs then you can ignore this. All it will do is make a command ran at startup related to emacs fail

settings.use_battery_indicators = false -- for if the wibar should have a battery widget, and if the battery status should periodically be updated
settings.darken_screens_with_redshift = true -- if redshift should also darken the screens or not

-- commands that will be run when awesome starts up
settings.run_on_startup = {
    "discord",
    --"sleep 5 ; flatpak run app.fluxer.Fluxer",
    settings.browser,
    --"steam -silent", -- start steam in the background
    "kdeconnect-cli", -- start KDE-connect so that stuff can be recieved from the app
    "pkill greenclip ; greenclip clear ; greenclip daemon", -- start the clipboard daemon after clearing it
    settings.emacs_server, -- start the doom emacs server
    "sleep 3 ; " .. settings.emacs, -- Has delay to allow emacs daemon to start first
    config_dir .. "startup_reminders/handle_startup_reminders.sh", -- start thing that opens gedit of the reminder file if it is not empty, and then clears it
    "udiskie",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
}

return settings
