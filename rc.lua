-- AwesomeWM config designed and made by baksoBoy
--
-- This config utilizes the Tunic font;
-- Original script by Andrew Shouldice for the game Tunic.
-- Font by Adrián Jiménez Pascual (dirdam.github.io).
-- usage guide: https://github.com/dirdam/fonts/blob/main/tunic/README.md
--
-- This config uses some assets from Finji. Both images and sounds from TUNIC have been used



-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
gears = require("gears")
config_dir = gears.filesystem.get_configuration_dir() -- /home/bakso/.config/awesome/
awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
wibox = require("wibox")

-- Theme handling library
beautiful = require("beautiful")

-- Notification library
naughty = require("naughty")
menubar = require("menubar")
hotkeys_popup = require("awful.hotkeys_popup")

package.path = package.path .. ";" .. config_dir .. "awesome-sharedtags-4.0/init.lua"
local sharedtags = require("sharedtags")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Themes define colours, icons, font and wallpapers.
beautiful.init()
require("beautiful_settings") -- load beautiful settings



-- load variables for all the general settings for the config
settings = require("config_settings")



local wallpaper_to_use = require("get_wallpaper_to_use")

-- stores battery information. Requiring the script also makes the gears timer that updates the status start (if specified in config_settings.lua)
battery_information = require("battery")

local BatteryWidgetCreator = require("wibar.battery_widget.battery_widget_creator")

-- create the clock widget
local TextClockCreator = require("wibar.clock_widget.clock_widget_creator")

-- whenever the compositor is turned on or off all widgets in this table will have self:OnCompositorUpdate(state) called
widgets_to_update_on_compositor_change = {}

-- create the control panel
require("control_panel/control_panel")

local ControlPanelButtonCreator = require("wibar.control_panel_button.control_panel_button_creator")

local TagButtonCreator = require("wibar.tag_buttons_widget.tag_button_creator")

local VerticalLineCreator = require("wibar.vertical_line_creator")

local WrapWidgetInDynamicSizedBody = require("wibar.dynamic_sized_body.wrap_in_dynamic_sized_body")

-- thing that is false by default, but turns true after a couple of seconds after launching AwesomeWM
-- is to prevent user from being spammed with the opening sound on startup
local allowed_to_play_client_opening_sound = false

-- table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.right,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.fair,
}

tag_count = 7
-- the tag names NEED to be numbers of their index. Custom names are handeled elsewhere for the tag buttons themselves
tags = sharedtags({
    {name = "1", layout = awful.layout.layouts[1] }, -- main
    {name = "2", layout = awful.layout.layouts[1] }, -- browser
    {name = "3", layout = awful.layout.layouts[1] }, -- secondary
    {name = "4", layout = awful.layout.layouts[1] }, -- files
    {name = "5", layout = awful.layout.layouts[1] }, -- background tasks
    {name = "6", layout = awful.layout.layouts[1] }, -- tetriary
    {name = "7", layout = awful.layout.layouts[1] }, -- emacs
})

-- assign all hotkeys
require("hotkeys")




-- error handling

-- check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Something fucked up during startup :(",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Something fucked up :(",
                         text = tostring(err) })
        in_error = false
    end)
end







-- menu

main_menu = awful.menu({ items = {
                             { "shutdown", "shutdown -h  now" },
                             { "log out", function() awesome.quit() end },
                             { "restart", "shutdown -r now" },
                             { "help", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
                                 }
                        })

-- menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it




-- wibar

-- Create a wibox for each screen and add it
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                {raise = true}
            )
        end
    end),
    awful.button({ }, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


-- table containing a widget of all the tag buttons for each screen
local tag_button_collection_widgets = {}
-- table containing all the tag button widgets for each screen. First index acesses the screen index, and the second index acesses the button widget on that screen
local tag_buttons = {}

local function UpdateTagButtonsAppearance()

    for s in screen do

        -- get all tags on each screen
        local selected_tags = s.selected_tags
        local selected_tag_indices = {}
        for _, tag in ipairs(selected_tags) do
            table.insert(selected_tag_indices, tonumber(tag.name))
        end

        -- loop through each tag on the screen and set its active state to if that tag is currently being viewed or not
        for _, tag_button in ipairs(tag_buttons[s.index]) do

            local tag_selected = false
            for _, selected_tag_index in ipairs(selected_tag_indices) do
                if selected_tag_index == tag_button.button_index then
                    tag_selected = true
                    break
                end
            end

            tag_button:SetState(tag_selected) -- set the state of the tag button to the condition of if that tag is currently selected
        end

    end
end

function FocusOnTag(i)
    local screen = awful.screen.focused()
    local tag = tags[i]
    if tag then
        sharedtags.viewonly(tag, screen)
        UpdateTagButtonsAppearance()
        -- play TUNIC sound effect
        awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_UI_move.wav &")

    end
    UpdateCompositorAutoModeState()
end

function ToggleTag(i)
    local screen = awful.screen.focused()
    local tag = tags[i]
    if tag then
        sharedtags.viewtoggle(tag, screen)
        UpdateTagButtonsAppearance()
        -- play TUNIC sound effect
        awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_UI_move.wav &")
    end
    UpdateCompositorAutoModeState()
end



-- table containing the button widgets for making the top panel appear
local control_panel_button_widgets = {}

-- int for what screen the control panel is on. If it isn't on any screen then the value should be 0
control_panel_screen_index = 0

function ToggleControlPanel()
    local hovered_over_screen_index = mouse.screen.index
    if hovered_over_screen_index == control_panel_screen_index then
        control_panel_screen_index = 0
    else
        control_panel_screen_index = hovered_over_screen_index
        bar_updating_loop_timer:start()
    end

    -- update the active state of each control panel button
    for i = 1, screen.count() do
        control_panel_button_widgets[i]:SetState(control_panel_screen_index == i)
    end

    -- position and set top panel screen visibility
    SetControlPanelVisibility(control_panel_screen_index > 0)
    if control_panel_screen_index > 0 then
        PositionControlPanelOnScreen(screen[control_panel_screen_index])
    end

    -- play TUNIC sound effect
    if control_panel_screen_index > 0 then
        awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_manual_open.wav &")
    else
        awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_manual_close.wav &")
    end

end

-- only one systray can be created, so this is used to keep track of if one has been created already or not,
-- to prevent widgets and stuff from surrounding nothing, when it tries to make another systray
local systray_already_created = false

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    s.wibar_side_of_screen = "initial value"
    s.wibar_side_of_screen_reversed = "initial value"
    if s.index == 1 then
        s.wibar_side_of_screen = "left"
        s.wibar_side_of_screen_reversed = "right"
    else
        s.wibar_side_of_screen = "right"
        s.wibar_side_of_screen_reversed = "left"
    end


    -- for each screen, create a widget containing all tag buttons that then gets added to the table containing the tag button collection for each screen

    -- widget that the buttons should be added to so that they are placed on top ofeach other
    local tag_button_row_widget = wibox.widget {
        layout = wibox.layout.fixed.vertical
    }

    tag_buttons_for_current_screen = {}
    -- create and add each tag button to the collection
    for i = 1, tag_count do
        table.insert(tag_buttons_for_current_screen, TagButtonCreator(i, FocusOnTag, ToggleTag, s.wibar_side_of_screen))
        tag_button_row_widget:add(tag_buttons_for_current_screen[#tag_buttons_for_current_screen]) -- get the last item in the list and add it here
    end

    -- make sure that it has the correct amount of padding on the bottom
    tag_button_row_widget_with_margin = wibox.widget {
        tag_button_row_widget,
        bottom = 10,
        widget = wibox.container.margin
    }
    table.insert(tag_buttons, tag_buttons_for_current_screen)
    table.insert(tag_button_collection_widgets, tag_button_row_widget_with_margin)



    -- for each screen, create a button widget for making the top panel appear
    table.insert(control_panel_button_widgets, ControlPanelButtonCreator(ToggleControlPanel))



    -- Create a tasklist widget
    s.tasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        layout   = {
            spacing = 0, -- how far away the icons are from each other. Negative values are supported
            layout  = wibox.layout.fixed.vertical,  -- stack vertically
        },
        widget_template = {
            {
                {
                    {

                        id = 'icon_role',
                        forced_height = 25,
                        forced_width  = 25,
                        widget = wibox.widget.imagebox,
                    },
                    halign = s.wibar_side_of_screen_reversed,
                    widget = wibox.container.place,
                },
                left = 4,
                right = 4,
                widget = wibox.container.margin,
            },
            id = 'background_role',
            widget = wibox.container.background,
        }
    }
    s.tasklist_with_margin = wibox.widget {
        s.tasklist,
        widget = wibox.container.margin
    }
    if s.wibar_side_of_screen == "right" then
        s.tasklist_with_margin.right = 10
    else
        s.tasklist_with_margin.left = 10
    end
    s.wrapped_tasklist = WrapWidgetInDynamicSizedBody(s.tasklist_with_margin, s.wibar_side_of_screen_reversed)



    s.systray = wibox.widget {
        base_size = 17, -- size of icons
        widget = wibox.widget.systray,
    }
    s.systray_pre_margin = wibox.widget {
        s.systray,
        bottom = 8, -- this is actually to the left as the widget will be rotated
        widget = wibox.container.margin
    }
    s.rotated_systray = wibox.container.rotate(
            s.systray_pre_margin,
            "west"
    )
    s.wrapped_systray = WrapWidgetInDynamicSizedBody(s.rotated_systray, s.wibar_side_of_screen_reversed)
    s.systray_with_margin = wibox.widget {
        s.wrapped_systray,
        bottom = 10,
        left = 10,
        widget = wibox.container.margin
    }
    if systray_already_created then
        s.systray_with_margin = nil
    end
    systray_already_created = true



    s.control_panel_button_with_margin = wibox.widget {
        control_panel_button_widgets[s.index],
        top = 10,
        bottom = 10,
        widget = wibox.container.margin
    }
    if s.wibar_side_of_screen == "left" then
        s.control_panel_button_with_margin.left = 10
    else
        s.control_panel_button_with_margin.right = 10
    end

    -- only create the battery widget if battery indicators should be used. Otherwise it is nil
    if settings.use_battery_indicators then
        s.battery_widget = BatteryWidgetCreator(s.wibar_side_of_screen == "right")
    end

    -- creating the actual wibar
    s.wibar = awful.wibar({
            position = "left", -- this value is kind of temporary. The parameter needs to be initialized here as it otherwise shits itself, but the value is changed to "rght" if it is on the right monitor
            -- position is specified under the creation of this variable since it is dependant on what screen it is
            screen = s,
            width = 43,
            bgimage = config_dir .. "backgrounds/" .. wallpaper_to_use .. "_wibar_gradient_" .. s.wibar_side_of_screen .. ".png",
    })
    s.wibar.position = s.wibar_side_of_screen

    s.wibar:setup {
        layout = wibox.layout.align.vertical,
        expand = "none", -- lock center wiget to be in the center of a screens
        -- top widgets
        {
            layout = wibox.layout.fixed.vertical,
            s.control_panel_button_with_margin,
            s.battery_widget,
            s.systray_with_margin,
            s.wrapped_tasklist,
        },

        -- middle widget
        TextClockCreator(s.wibar_side_of_screen == "right"),

        -- bottom widgets
        {
            layout = wibox.layout.fixed.vertical,
            --VerticalLineCreator(),
            tag_button_collection_widgets[s.index],
        },
    }

end)
UpdateTagButtonsAppearance()



-- mouse bindings for when clicking the desktop
root.buttons(gears.table.join(
    awful.button({ }, 3, function () main_menu:toggle() end)
))



clientbuttons = gears.table.join(

    -- make left, middle, and right-clicking focus onto clients
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ }, 2, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),

    -- super + left click moves clients
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),

    -- super + right click resizes clients
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)


-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
            "DTA",  -- Firefox addon DownThemAll.
            "copyq",  -- Includes session name in class.
            "pinentry",
        },
        class = {
            "Arandr",
            "Blueman-manager",
            "Gpick",
            "Kruler",
            "MessageWin",  -- kalarm.
            "Sxiv",
            "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
            "Wpa_gui",
            "veromix",
            "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
            "Event Tester",  -- xev.
        },
        role = {
            "AlarmWindow",  -- Thunderbird's calendar.
            "ConfigManager",  -- Thunderbird's about:config.
            "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
    },
      properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
--    { rule_any = {type = { "normal", "dialog" }
--      }, properties = { titlebars_enabled = true }
--    },
    -- Make sure that clients that are "normal" and "dialog" never spawn in as maximized
    { rule_any = {type = { "normal", "dialog" }
        }, properties = { maximized = false }
    },


    { rule = { class = "firefox" },
        properties = { tag = tags[2] } },

    { rule = { class = "librewolf" },
        properties = { tag = tags[2] } },

    { rule = { class = "discord" },
        properties = { tag = tags[5] } },
    
    { rule = { class = "Emacs" },
        properties = { tag = tags[7] } },
    
    { rule = { class = "Io.elementary.appcenter" }, -- Pop! shop
        properties = {
            callback = function(c)
                naughty.notify({
                    title = "Error",
                    text = "DO NOT USE POP SHOP WITH AWESOMEWM! IT FUCKS SHIT UP! Just use 'flatpak upgrade' in terminal",
                    -- I updated a bunch of stuff through the Pop shop, and that completely broke minecraft and I couldn't launch it. After a while I learnt that I could just run "flatpak update" for it to get fixed. I have however never experiacned this on GNOME, and there might be more issues that I haven't found regarding using the Pop shop with AwesomeWM
                    preset = naughty.config.presets.critical
                })
                awful.placement.centered(c)
                --c:kill()
            end
    } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- Enable rounded corners
    c.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, beautiful.border_radius)
    end

    -- play TUNIC sound effect
    if allowed_to_play_client_opening_sound then
        awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_UI_select.wav &")
    end

    UpdateCompositorAutoModeState()
end)

-- signal function to execute when a client is closed
client.connect_signal("unmanage", function(c)
    -- play TUNIC sound effect
    awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_UI_cancel.wav &")

    UpdateCompositorAutoModeState()
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--    c:emit_signal("request::activate", "mouse_enter", {raise = false})
--end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("property::fullscreen", function(c) -- make sure that when clients are fullscreened their corners aren't rounded
    if c.fullscreen then
        c.shape = gears.shape.rect
    else
        c.shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, beautiful.border_radius)
        end
    end

    UpdateCompositorAutoModeState()
end)
client.connect_signal("property::minimized", function (c) UpdateCompositorAutoModeState() end)
-- }}}



-- set the tags that the screens should display on startup
for i = 1, screen.count() do
    if i > tag_count then -- don't continue if past the amount of tags that exist
        break;
    end
    sharedtags.viewonly(tags[i], screen[i])
end
UpdateTagButtonsAppearance()



-- image wallpaper
gears.wallpaper.maximized(config_dir .. "backgrounds/" .. wallpaper_to_use .. ".png", 1) -- set wallpaper for monitor 1
gears.wallpaper.maximized(config_dir .. "backgrounds/" .. wallpaper_to_use .. ".png", 2) -- set wallpaper for monitor 2

-- video wallpaper
-- set the background to a video file with a script
--awful.spawn.easy_async_with_shell("sleep 1 ; " .. config_dir .. "animated_wallpaper.sh " .. rcLuaDirectory  .. "backgrounds/video_background.mp4")



-- autostart Applications
require("autostart_applications")



-- start timer that periodically checks for Syncthing file conflicts
require("detect_syncthing_conflicts")



os.execute("xset r rate 225 50") -- change keyboard DAS and ARR because holy shit the default ones makes me want to kill myself



-- play TUNIC sound effect
awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_continue.wav &")



-- shit to make clients allowed to make spawning sounds after most auto-launched clients have finished launching
gears.timer({
        timeout = 5,
        autostart = true,
        single_shot = true,
        callback = function ()
            allowed_to_play_client_opening_sound = true
        end
})
