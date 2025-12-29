-- script for asigning all hotkeys

modkey = "Mod4"


-- making all the hotkeys for tag navigation
-- NOTE! keycodes are used to make it work on any keyboard layout
for i = 1, tag_count do

    globalkeys = gears.table.join(globalkeys,

        awful.key({ modkey }, "#" .. i + 9,
            function ()
                FocusOnTag(i)
            end),

        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
            function ()
                ToggleTag(i)
            end),

        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                        FocusOnTag(i)
                    end
                end
            end)
    )
end

-- hotkeys that work globally
globalkeys = gears.table.join(globalkeys,

    awful.key({ modkey }, "h",
        hotkeys_popup.show_help,
        {description="show help", group="awesome"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey }, "p",
        function ()
            ToggleControlPanel()
        end,
        {description = "open control panel", group = "awesome"}),

    awful.key({ modkey }, "n",
        function ()
            naughty.destroy_all_notifications()
        end,
        {description = "close notifications", group = "general"}),

    awful.key({}, "XF86AudioRaiseVolume",
        function ()
            awful.spawn("wpctl set-volume @DEFAULT_SINK@ 10%+")
            naughty.notify({text="volume +10%"})
        end),

    awful.key({}, "XF86AudioLowerVolume",
        function ()
            awful.spawn("wpctl set-volume @DEFAULT_SINK@ 10%-")
            naughty.notify({text="volume -10%"})
        end),

    awful.key({}, "XF86AudioMute",
        function ()
            awful.spawn("wpctl set-volume @DEFAULT_SINK@ 0%")
            naughty.notify({text="volume 0%"})
        end),

    awful.key({}, "XF86MonBrightnessDown",
        function ()
            awful.spawn("brightnessctl set 10%-")
            naughty.notify({text="brightness -10%"})
            -- make sure that brightness doesn't go to 0% because at least on my laptop, the screen goes pitch fucking black
            awful.spawn.easy_async_with_shell("brightnessctl i | awk -F'[()%]' '/Current brightness/ {print $2}'", function(stdout)
                if tonumber(stdout) < 1 then
                    awful.spawn("brightnessctl set 1%")
                    naughty.notify({text="brightness limited to a minimum of 1%"})
                end
            end)
        end),

    awful.key({}, "XF86MonBrightnessUp",
        function ()
            awful.spawn("brightnessctl set +10%")
            naughty.notify({text="brightness +10%"})
        end),

    awful.key({ "Mod1" }, "Tab",
        function ()
            awful.screen.focus_relative(1)
        end,
        {description = "switch monitor focus", group = "general"}),

    awful.key({ modkey }, "u",
        function ()
            for s in screen do
                local selected_tags = s.selected_tags
                for _, tag in ipairs(selected_tags) do
                    for _, c in ipairs(tag:clients()) do
                        if c.minimized then
                            c.minimized = false
                        end
                    end
                end
            end
        end,
        {description = "un-minimize all clients on screen", group = "client"}),

    -- focusing on neighbouring clients
    awful.key({ modkey }, "Up",
        function ()
            awful.client.focus.global_bydirection("up")
        end,
        {description = "focus upwards", group = "client"}),

    awful.key({ modkey }, "Left",
        function ()
            awful.client.focus.global_bydirection("left")
        end,
        {description = "focus to left", group = "client"}),

    awful.key({ modkey }, "Down",
        function ()
            awful.client.focus.global_bydirection("down")
        end,
        {description = "focus downwards", group = "client"}),

    awful.key({ modkey }, "Right",
        function ()
            awful.client.focus.global_bydirection("right")
        end,
        {description = "focus to right", group = "client"}),

    -- swap client positions
    awful.key({ modkey, "Shift" }, "Up",
        function ()
            awful.client.swap.global_bydirection("up")
        end,
        {description = "swap with client upwards", group = "client"}),

    awful.key({ modkey, "Shift" }, "Left",
        function ()
            awful.client.swap.global_bydirection("left")
        end,
        {description = "swap with client to left", group = "client"}),

    awful.key({ modkey, "Shift" }, "Down",
        function ()
            awful.client.swap.global_bydirection("down")
        end,
        {description = "swap with client downwards", group = "client"}),

    awful.key({ modkey, "Shift" }, "Right",
        function ()
            awful.client.swap.global_bydirection("right")
        end,
        {description = "swap with client to right", group = "client"}),

    -- move what monitor the client is in
    awful.key({ modkey, "Control" }, "Left",
        function ()
            local c = client.focus
            if c then
                c:move_to_screen(c.screen.index - 1)
            end
        end,
        {description = "move client to previous screen", group = "client"}),

    awful.key({ modkey, "Control" }, "Right",
        function ()
            local c = client.focus
            if c then
                c:move_to_screen(c.screen.index + 1)
            end
        end,
        {description = "move client to next screen", group = "client"}),

    -- change master width
    awful.key({ modkey }, "w",
        function ()
            awful.tag.incmwfact( 0.05)
        end,
        {description = "increase master width factor", group = "client"}),

    awful.key({ modkey }, "s",
        function ()
            awful.tag.incmwfact(-0.05)
        end,
        {description = "decrease master width factor", group = "client"}),

    -- change master client count
    awful.key({ modkey }, "i",
        function ()
            awful.tag.incnmaster( 1, nil, true)
        end,
        {description = "increase the number of master clients", group = "layout"}),

    awful.key({ modkey }, "k",
        function ()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {description = "decrease the number of master clients", group = "layout"}),

    -- change column count
    awful.key({ modkey, "Shift" }, "i",
        function ()
            awful.tag.incncol( 1, nil, true)
        end,
        {description = "increase the number of columns", group = "layout"}),

    awful.key({ modkey, "Shift" }, "k",
        function ()
            awful.tag.incncol(-1, nil, true)
        end,
        {description = "decrease the number of columns", group = "layout"}),

    -- change layout
    awful.key({ modkey }, "Tab",
        function ()
            awful.layout.inc(1)
        end,
        {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift" }, "Tab",
        function ()
            awful.layout.inc(-1)
        end,
        {description = "select previous", group = "layout"}),

    -- launch programs
    awful.key({ modkey }, "t",
        function ()
            awful.spawn(settings.terminal)
        end,
        {description = "open terminal", group = "launcher"}),

    awful.key({ modkey }, "e",
        function ()
            awful.spawn(settings.file_browser)
        end,
        {description = "open file browser", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "s",
        function ()
            awful.spawn.easy_async_with_shell('maim -o -s | tee ~/Pictures/Screenshots/"Screenshot_$(date +"%Y-%m-%d_%H-%M-%S")".png | xclip -selection clipboard -t image/png')
        end,
        {description = "take screenshot of region", group = "launcher"}),

    awful.key({ modkey }, "d",
        function ()
            awful.spawn.easy_async_with_shell(settings.emacs)
        end,
        {description = "open Doom Emacs", group = "launcher"}),

    awful.key({ modkey }, "space",
        function ()
            awful.util.spawn("rofi -show drun")
        end,
        {description = "launch application with Rofi", group = "launcher"}),

    awful.key({ modkey }, "c",
        function ()
            awful.util.spawn("rofi -show calc -modi calc -no-show-match -no-sort -calc-command \"echo -n '{result}' | xclip -selection clipboard\"")
        end,
        {description = "run Rofi-calc", group = "launcher"}),

    awful.key({ modkey }, "v",
        function ()
            awful.util.spawn('rofi -modi "clipboard:greenclip print" -show clipboard')
        end,
        {description = "open grenclip", group = "launcher"}),

    -- tag navigation
    -- NOTE! These hotkeys don't actually do anything. They are just for making entries in the hotkeys menu
    awful.key({ modkey }, "(1-" .. tostring(tag_count) .. ")",
        function () end, -- dunno how to make it properly not do anything
        {description = "view the specified tag", group = "tag"}),

    awful.key({ modkey, "Mod1" }, "(1-" .. tostring(tag_count) .. ")",
        function () end, -- dunno how to make it properly not do anything
        {description = "toggle the specified tag", group = "tag"}),

    awful.key({ modkey, "Control" }, "(1-" .. tostring(tag_count) .. ")",
        function () end, -- dunno how to make it properly not do anything
        {description = "move client to specified tag and switch to that tag", group = "tag"})
)

-- hotkeys that only work when focusing on a client
clientkeys = gears.table.join(clientkeys,
    awful.key({ modkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey }, "q",
        function (c)
            c:kill()
        end,
        {description = "close", group = "client"}),

    awful.key({ modkey }, "Return",
        function (c)
            c:swap(awful.client.getmaster())
        end,
        {description = "move to master", group = "client"}),

    awful.key({ modkey }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "maximize window", group = "client"})
)

-- assign the global keys or some shit
root.keys(globalkeys)
