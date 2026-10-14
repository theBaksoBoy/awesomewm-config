# awesomewm config

The config for my awesomewm setup, which has themes from the game TUNIC, and from the language Toki Pona. The config is built to work for 1920x1080 displays, and other resolutions may thus have visual glitches.

To change settings in this config such as what file browser you are using, or if you want a battery widget to be shown or not, then go into settings.lua

## Dependencies:
- sharedtags (already included in repo) (https://github.com/Drauthius/awesome-sharedtags)
- paplay
- redshift
- maim
- picom (fork with animations) (https://github.com/r0-zero/picom) (AUR package name: picom-ftlabs-git)
- rofi
- rofi-calc
- xclip
- greenclip (https://github.com/erebe/greenclip) (AUR package name: rofi-greenclip)
- the font "Odin Rounded"
- if you are going to work with the .kra assets, then you need the trunic font (https://www.reddit.com/r/TunicGame/comments/12nr1m1/tunic_font_fullversion/)
- acpi (if using batery indicator)
- wpctl (included with pipewire)
- ddcutil (if you want screen brightness to be controllable through the control panel)
- brightnessctl (if you want brightness up/down buttons on a laptop to work)
- xset (pacman package name: xorg-xset)
- udisks2
- udiskie
- polkit
- polkit-gnome
- **you also need to look in settings.lua and hotkeys.lua for applications that are specified there.**

If you are going to use the glucose widget that gets values from LibreLinkUp then you need to do the following
- Run the commands `cd ~/.config/awesome/wibar/glucose_widget && python3 -m venv venv` and `source venv/bin/activate && pip install libre-linkup-py && pip install pydantic`.
- Note that the url string in `wibar/glucose_widget/glucose_updater.py` may be dependant on your region (read more here: https://github.com/smpurkis/libre-linkup-py). The url used in this config is what works for me in Sweden.
- As of writing this the last commit for libre-linkup-py was commit `d67fc28`. It has an error related to timezones. Fix this by going into `glucose/venv/lib/python3.14/site-packages/libre-link-up/client.py` and change `tz = timezone(country)` to `tz = timezone("Europe/Stockholm" if country == "SE" else country)` (this fix is only relevant for Swedish users).
- To make the widget work you need to provide login details for your LibreLinkUp account. create the file `login_credentials.txt` under `wibar/glucose_widget/` where line 1 is the account's email, and line 2 is the account's password.
