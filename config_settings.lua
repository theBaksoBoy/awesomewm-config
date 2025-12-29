-- here you will find both settings for general configurations for the AwesomeWM config,
-- but also info about dependencies and stuff



-- dependencies for config to work
-------------------------------------
-- sharedtags (might be included in config already in same dir as rc.lua) (https://github.com/Drauthius/awesome-sharedtags)
-- all the programs listed further down in the changeable setting (most can be changed though!)
-- paplay
-- redshift
-- maim
-- picom fork with animations (https://github.com/r0-zero/picom) (in AUR the package is called  picom-ftlabs-git)
-- rofi
-- rofi-calc (https://github.com/svenstaro/rofi-calc)
-- greenclip (https://github.com/erebe/greenclip)
-- the font "Odin Rounded"
-- acpi
-- wpctl (should already be included if you use pipewire)
-- brightnessctl

-- hotkeys.lua is for all the different hotkeys in the config

local settings = {}

-- if you want to add/remove/change the tag selection then good luck. There is no super easy way of doing it.
-- If you want to add a tag, *unless I remember something wrong* you have to first go into rc.lua and change tag_count.
-- Then change the tags variable to add another entry. Then finally(?) go into wibar/tag_button_widget and create a new
-- file named tag_n.png (with n being the tag number) which is used as the image for the tag button.

settings.terminal = "kitty"
settings.browser = "firefox"
settings.file_browser = "nautilus"
-- note that Emacs stuff is based specifically on Doom Emacs. I'm not sure if vanilla Emacs's commands look any different
settings.emacs =  "/usr/bin/emacsclient -c -a 'emacs'" -- if you don't want to use emacs then you can ignore this. All it will do is make the hotkey for launching it not work
settings.emacs_server = "/usr/bin/emacs --daemon" -- if you don't want to use emacs then you can ignore this. All it will do is make a command ran at startup related to emacs fail

settings.use_battery_indicators = true -- for if the wibar should have a battery widget, and if the battery status should periodically be updated
settings.darken_screens_with_DDC_CI = true -- if the redshift button should be used to toggle between a bright and dark screen using DDC/CI. This is not very necessary on for instance laptops, as you can manually change their brightness way more efficiently

-- commands that will be run when AwesomeWM starts up
settings.run_on_startup = {
    "discord",
    settings.browser,
    --"steam -silent", -- start steam in the background
    "kdeconnect-cli", -- start KDE-connect so that stuff can be recieved from the app
    "pkill greenclip ; greenclip clear ; greenclip daemon", -- start the clipboard daemon after clearing it
    settings.emacs_server, -- start the doom emacs server
    "sleep 3 ; " .. settings.emacs, -- Has delay to allow emacs daemon to start first
    config_dir .. "startup_reminders/handle_startup_reminders.sh", -- start thing that opens gedit of the reminder file if it is not empty, and then clears it
    "cd /home/bakso/programming && cargo clean-all --keep-days 3 -y", -- run thing that runs cargo clean on rust projects that haven't been worked on for a while, since rust projects take up so much fucking storage space holy shit
    --"cd " .. config_dir .. "python_background_macro_practice_tool/ ; source venv/bin/activate ; python3 main.py", -- start python script that notifies you if you typed a macro without using the dedicated macro button
}



return settings
