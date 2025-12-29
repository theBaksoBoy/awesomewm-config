-- script for managing the control panel and all the features contained in it

local ButtonCreator = require("control_panel.buttons.control_panel_button_creator")
local BarCreator = require("control_panel.bars.control_panel_bar_creator")

local compositor_in_auto_mode = true
local old_compositor_state = true

function SetCompositorState(state)

    if state and (not old_compositor_state) then
        awful.spawn.with_shell("picom")
        old_compositor_state = true
    elseif (not state) and old_compositor_state then
        awful.spawn.with_shell("killall picom")
        old_compositor_state = false
    end

    for _, widget in ipairs(widgets_to_update_on_compositor_change) do
        widget.OnCompositorUpdate(state)
    end
end

function UpdateCompositorAutoModeState()

    if not compositor_in_auto_mode then return end

    local activate_compositor = true

    -- see if any client that is currently visible on any screen is fullscreened
    for s in screen do
        for _, c in ipairs(client.get()) do
            if c.screen == s and not c.minimized and c:isvisible() and c.fullscreen then
                activate_compositor = false
            end
        end
    end

    -- start or stop picom depending on if it should be on or off
    SetCompositorState(activate_compositor)

end

-- used when pressing the compositor button
local function SetCompositorMode(button_state)
    -- button state 1 = auto, 2 = off, 3 = on
    if button_state == 1 then
        awful.spawn.with_shell("picom") -- make sure that an instance is running
        compositor_in_auto_mode = true
        UpdateCompositorAutoModeState()
    elseif button_state == 2 then
        SetCompositorState(false)
        compositor_in_auto_mode = false
    elseif button_state == 3 then
        SetCompositorState(true)
        compositor_in_auto_mode = false
    end
end

-- used when pressing the redshift button
local function SetRedshiftMode(button_state)
    -- button state (if settings.darken_screens_with_DDC_CI)     1 = redshift, 2 = redshift + dark, 3 = normal
    -- button state (if not settings.darken_screens_with_DDC_CI) 1 = redshift, 2 = normal
    if button_state == 1 then
        awful.spawn.with_shell("redshift")
    elseif button_state == 2 then
        if settings.darken_screens_with_DDC_CI then
            -- set brightness of screens
            awful.spawn.with_shell("ddcutil --display 1 setvcp 10 0 && ddcutil --display 2 setvcp 10 0")
        else
            awful.spawn.with_shell("killall redshift")
        end
    elseif button_state == 3 then
        awful.spawn.with_shell("killall redshift")
        -- set brightness of screens
        awful.spawn.with_shell("ddcutil --display 1 setvcp 10 100 && ddcutil --display 2 setvcp 10 100")
    end
end

-- used when pressing the keyboard layout button
local function SetKeyboardLayoutMode(button_state)
    -- button state 1 = Swedish, 2 = other
    if button_state == 1 then
        awful.spawn.with_shell("setxkbmap se -variant nodeadkeys")
    elseif button_state == 2 then
        awful.spawn.with_shell("setxkbmap us")
    end
end



-- make compositor button widget
local button_compositor = wibox.widget {
    ButtonCreator({config_dir .. "control_panel/buttons/compositor_auto.png", config_dir .. "control_panel/buttons/compositor_off.png", config_dir .. "control_panel/buttons/compositor_on.png"}, SetCompositorMode),
    left = (680 - 88) / 2 - 200, -- x position
    top = 405, -- y position
    widget = wibox.container.margin
}
-- jank shit to make button not pressable when pressing underneath or to the right of it
button_compositor.right = 592 - button_compositor.left
button_compositor.bottom = 605 - button_compositor.top

-- make redshift button widget
local button_redshift = nil
if settings.darken_screens_with_DDC_CI then
    button_redshift = wibox.widget {
        ButtonCreator({config_dir .. "control_panel/buttons/screen_redshift.png", config_dir .. "control_panel/buttons/screen_redshift_dark.png", config_dir .. "control_panel/buttons/screen_normal.png"}, SetRedshiftMode),
        left = (680 - 88) / 2 + 0, -- x position
        top = 405, -- y position
        widget = wibox.container.margin
    }
else
    button_redshift = wibox.widget {
        ButtonCreator({config_dir .. "control_panel/buttons/screen_redshift.png", config_dir .. "control_panel/buttons/screen_normal.png"}, SetRedshiftMode),
        left = (680 - 88) / 2 + 0, -- x position
        top = 405, -- y position
        widget = wibox.container.margin
    }
end
-- jank shit to make button not pressable when pressing underneath or to the right of it
button_redshift.right = 592 - button_redshift.left
button_redshift.bottom = 605 - button_redshift.top

-- make keyboard layout button widget
local button_keyboard_layout = wibox.widget {
    ButtonCreator({config_dir .. "control_panel/buttons/keyboard_layout_swedish.png", config_dir .. "control_panel/buttons/keyboard_layout_other.png"}, SetKeyboardLayoutMode),
    left = (680 - 88) / 2 + 200, -- x position
    top = 405, -- y position
    widget = wibox.container.margin
}
-- jank shit to make button not pressable when pressing underneath or to the right of it
button_keyboard_layout.right = 592 - button_keyboard_layout.left
button_keyboard_layout.bottom = 605 - button_keyboard_layout.top

local bar_CPU = BarCreator("red")
local bar_CPU_margin = wibox.widget {
    bar_CPU,
    left = (680 - 59) / 2 + 125 * -1.5,
    top = 103,
    widget = wibox.container.margin
}

local bar_GPU = BarCreator("green")
local bar_GPU_margin = wibox.widget {
    bar_GPU,
    left = (680 - 59) / 2 + 125 * -0.5,
    top = 103,
    widget = wibox.container.margin
}

local bar_RAM = BarCreator("blue")
local bar_RAM_margin = wibox.widget {
    bar_RAM,
    left = (680 - 59) / 2 + 125 * 0.5,
    top = 103,
    widget = wibox.container.margin
}

local bar_battery = BarCreator("yellow")
local bar_battery_margin = wibox.widget {
    bar_battery,
    left = (680 - 59) / 2 + 125 * 1.5,
    top = 103,
    widget = wibox.container.margin
}

local charging_image = wibox.widget {
    image  = config_dir .. "control_panel/bars/charging_icon.png",
    resize = false,
    visible = false,
    widget = wibox.widget.imagebox
}

-- create charging icon that gets stacked together with the battery bar
local charging_icon = wibox.widget {
    charging_image,
    left = (680 - 49) / 2 + 125 * 1.5,
    top = 103 + (215 - 49) / 2,
    widget = wibox.container.margin
}

local bar_battery_stack = wibox.widget {
        bar_battery_margin,
        charging_icon,
        layout = wibox.layout.stack
    }

local battery_time_text = wibox.widget {
    text = "...", -- initial value
    font = "Odin Rounded 18",
    widget = wibox.widget.textbox
}

local battery_time_widget = wibox.widget {
    {
        battery_time_text,
        fg = "#000",
        widget = wibox.container.background
    },
    top = 0,
    left = 510,
    widget = wibox.container.margin
}



-- make the main part of the control panel that all the buttons and stuff will be on.
local control_panel_main = wibox({
    width = 680,
    height = 693,
    ontop = true,
    type = "dock",
    bg = "#00000000",
    visible = true,
    name = "control_panel" -- used to exclude fucker from blur and stuff in picom
})

control_panel_main.OnCompositorUpdate = function(is_on)
    if is_on then control_panel_main.bg = "#00000000" else control_panel_main.bg = "#000000FF" end
end

control_panel_main:setup {
    layout = wibox.layout.stack,
    {
        image = config_dir .. "control_panel/control_panel_main.png",
        resize = false,
        widget = wibox.widget.imagebox
    },
    button_compositor,
    button_redshift,
    button_keyboard_layout,
    bar_CPU_margin,
    bar_GPU_margin,
    bar_RAM_margin,
    bar_battery_stack,
    battery_time_widget
}

table.insert(widgets_to_update_on_compositor_change, control_panel_main)


-- offsets for the different parts of the top panel relative to the main panel image
pos_offset_left_x = -62
pos_offset_left_y = 9
pos_offset_right_x = 680
pos_offset_right_y = 9
pos_offset_top_x = 59
pos_offset_top_y = -11
pos_offset_bottom_x = 271
pos_offset_bottom_y = 693

-- make the left side of the ribbon
local control_panel_left = wibox({
    width = 62,
    height = 99,
    ontop = true,
    type = "dock",
    bg = "#00000000",
    visible = true,
    name = "control_panel" -- used to exclude fucker from blur and stuff in picom
})

control_panel_left.OnCompositorUpdate = function(is_on)
    if is_on then control_panel_left.bg = "#00000000" else control_panel_left.bg = "#000000FF" end
end

control_panel_left:setup {
    layout = wibox.layout.stack,
    {
        image = config_dir .. "control_panel/control_panel_left.png",
        resize = false,
        widget = wibox.widget.imagebox
    }
}

table.insert(widgets_to_update_on_compositor_change, control_panel_left)

-- make the right side of the ribbon
local control_panel_right = wibox({
    width = 62,
    height = 99,
    ontop = true,
    type = "dock",
    bg = "#00000000",
    visible = true,
    name = "control_panel" -- used to exclude fucker from blur and stuff in picom
})

control_panel_right.OnCompositorUpdate = function(is_on)
    if is_on then control_panel_right.bg = "#00000000" else control_panel_right.bg = "#000000FF" end
end

control_panel_right:setup {
    layout = wibox.layout.stack,
    {
        image = config_dir .. "control_panel/control_panel_right.png",
        resize = false,
        widget = wibox.widget.imagebox
    }
}

table.insert(widgets_to_update_on_compositor_change, control_panel_right)

-- make the top side of the ribbon
local control_panel_top = wibox({
    width = 562,
    height = 11,
    ontop = true,
    type = "dock",
    bg = "#00000000",
    visible = true,
    name = "control_panel" -- used to exclude fucker from blur and stuff in picom
})

control_panel_top.OnCompositorUpdate = function(is_on)
    if is_on then control_panel_top.bg = "#00000000" else control_panel_top.bg = "#000000FF" end
end

control_panel_top:setup {
    layout = wibox.layout.stack,
    {
        image = config_dir .. "control_panel/control_panel_top.png",
        resize = false,
        widget = wibox.widget.imagebox
    }
}

table.insert(widgets_to_update_on_compositor_change, control_panel_top)

-- make the bottom part of the metal decoration thing
local control_panel_bottom = wibox({
    width = 138,
    height = 14,
    ontop = true,
    type = "dock",
    bg = "#00000000",
    visible = true,
    name = "control_panel" -- used to exclude fucker from blur and stuff in picom
})

control_panel_bottom.OnCompositorUpdate = function(is_on)
    if is_on then control_panel_bottom.bg = "#00000000" else control_panel_bottom.bg = "#000000FF" end
end

control_panel_bottom:setup {
    layout = wibox.layout.stack,
    {
        image = config_dir .. "control_panel/control_panel_bottom.png",
        resize = false,
        widget = wibox.widget.imagebox
    }
}

table.insert(widgets_to_update_on_compositor_change, control_panel_bottom)


function SetControlPanelVisibility(visibility)
  control_panel_main.visible = visibility
  control_panel_left.visible = visibility
  control_panel_right.visible = visibility
  control_panel_top.visible = visibility
  control_panel_bottom.visible = visibility
end

function PositionControlPanelOnScreen(s)
    x = s.geometry.x + (s.geometry.width - 680) / 2
    y = s.geometry.y + 50

    control_panel_main.x = x
    control_panel_main.y = y
    control_panel_right.x = x + pos_offset_right_x
    control_panel_right.y = y + pos_offset_right_y
    control_panel_left.x = x + pos_offset_left_x
    control_panel_left.y = y + pos_offset_left_y
    control_panel_top.x = x + pos_offset_top_x
    control_panel_top.y = y + pos_offset_top_y
    control_panel_bottom.x = x + pos_offset_bottom_x
    control_panel_bottom.y = y + pos_offset_bottom_y
end



local CPU_idle_percentage = { value = 0 } -- table so that it can be passed by reference in the async function
function UpdateCPUBar()

    -- update value. Is done before async command as even if you put it after it will run before due to this not being async
    bar_CPU:UpdateValue((100 - CPU_idle_percentage.value) / 100)

    awful.spawn.easy_async_with_shell("top -bn1 | grep 'Cpu(s)' | awk '{print $8}'", function(stdout)
        CPU_idle_percentage.value = tonumber(stdout)
    end)
end



local GPU_percentage = { value = 0 } -- table so that it can be passed by reference in the async function
function UpdateGPUBar()

    -- update value. Is done before async command as even if you put it after it will run before due to this not being async
    bar_GPU:UpdateValue(GPU_percentage.value / 100)

    -- this only works if you are using the proprietary nvidia driver
    awful.spawn.easy_async_with_shell("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits", function(stdout)
        GPU_percentage.value = tonumber(stdout)
    end)
end



local RAM_percentage = { value = 0 } -- table so that it can be passed by reference in the async function
function UpdateRAMBar()

    bar_RAM:UpdateValue(RAM_percentage.value)

    awful.spawn.easy_async_with_shell("free | awk '/Mem:/ {printf \"%.3f\", $3/$2}'", function(stdout)
        RAM_percentage.value = tonumber(stdout)
    end)
end



function UpdateBatteryBar()

    -- this function doesn't have to actually update the battery information as a gears timer for that already exists (in battery.lua)
    -- all this does is just grab the information from the already updating battery_information table in rc.lua

    -- update the bar
    bar_battery:UpdateValue(battery_information.percentage / 100)
    charging_image.visible = battery_information.is_charging

    -- update the text saying how long until charged/empty
    if battery_information.time_remaining_hours == 0 then
        battery_time_text.text = tostring(battery_information.time_remaining_minutes) .. "m"
    else
        battery_time_text.text = tostring(battery_information.time_remaining_hours) .. "h " .. tostring(battery_information.time_remaining_minutes) .. "m"
    end
end



-- what bar should be updated in the current loop
local bar_updating_index = 1
local bar_updating_functions = { UpdateCPUBar, UpdateGPUBar, UpdateRAMBar, UpdateBatteryBar }
bar_updating_loop_timer = gears.timer({
        timeout = 0.25,
        autostart = false,
        callback = function ()

            -- stop the loop if the control panel is hidden
            if control_panel_screen_index == 0 then
                bar_updating_loop_timer:stop()
                return
            end

            -- update the bar next in line and then go to the other one
            bar_updating_index = bar_updating_index % #bar_updating_functions + 1
            bar_updating_functions[bar_updating_index]()
        end
})

-- I'm pretty sure this line isn't nessecary. If you have had it commented for a while without issue you can probably remove it
--PositionControlPanelOnScreen(screen.primary)

SetControlPanelVisibility(false)
