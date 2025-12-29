
local function CreateBatteryWidget(widget_on_right_screen)

    local function CreateImageWidget(path)
        return wibox.widget {
            image = path,
            resize = false,
            widget = wibox.widget.imagebox
        }
    end

    local body_discharge_widget = CreateImageWidget(config_dir .. "wibar/battery_widget/battery_body_discharging.png")
    local body_charge_widget = CreateImageWidget(config_dir .. "wibar/battery_widget/battery_body_charging.png")

    local text_widget = wibox.widget {
        text = "...", -- initial value
        font = "Odin Rounded 16",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox
    }

    local text_widget_colorable = wibox.widget {
        text_widget,
        fg = "#FFF",
        widget = wibox.container.background
    }

    local text_widget_with_padding = wibox.widget {
        text_widget_colorable,
        bottom = 3,
        widget = wibox.container.margin
    }

    text_widget.Refresh = function()

        body_charge_widget.visible = battery_information.is_charging
        body_discharge_widget.visible = not battery_information.is_charging
        text_widget.text = tostring(battery_information.percentage)

        if battery_information.is_low then
            text_widget_colorable.fg = "#F00"
            if not battery_information.has_warned_about_being_low then
                naughty.notify({
                    title="battery low!",
                    preset = naughty.config.presets.critical

                })
                battery_information.has_warned_about_being_low = true
            end
        else
            text_widget_colorable.fg = "#FFF"
        end

    end



    -- create a loop for refresh
    gears.timer {
        timeout = 1, -- make the loop happen every second
        autostart = true,
        call_now = true,
        callback = text_widget.Refresh
    }



    local stacked_widget = wibox.widget {
        body_discharge_widget,
        body_charge_widget,
        {
            text_widget_with_padding,
            valign = "bottom",
            widget = wibox.container.place
        },
        layout = wibox.layout.stack
    }

    -- create final widget with padding so that it doesn't touch the edge of the screen
    local battery_widget = wibox.widget {
        stacked_widget,
        bottom = 10,
        layout = wibox.container.margin
    }
    if widget_on_right_screen then
        battery_widget.left = 0
        battery_widget.right = 10
    else
        battery_widget.left = 10
        battery_widget.right = 0
    end


    battery_widget:buttons(gears.table.join(
        awful.button({}, 1, function()
            text_widget.show_in_ISO_format = not text_widget.show_in_ISO_format
            text_widget.Refresh()
        end),
        awful.button({}, 3, function()
            text_widget.show_in_ISO_format = not text_widget.show_in_ISO_format
            text_widget.Refresh()
        end)
    ))

    return battery_widget

end

return CreateBatteryWidget
