-- widget for the wibar to display the time and shit

local function CreateTextClockWidget(widget_on_right_screen)

    local function CreateImageWidget(path)
        return wibox.widget {
            image = path,
            resize = false,
            widget = wibox.widget.imagebox
        }
    end

    local body_widget = CreateImageWidget(config_dir .. "wibar/clock_widget/datetime_body.png")

    local text_widget = wibox.widget {
        markup = "", -- initial value
        align = "center",
        halign = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local month_strings = {
        "jan",
        "feb",
        "mar",
        "apr",
        "may",
        "jun",
        "jul",
        "aug",
        "sep",
        "oct",
        "nov",
        "dec"
    }

    local weekday_strings = {
        "sun",
        "mon",
        "tue",
        "wed",
        "thu",
        "fri",
        "sat"
    }

    text_widget.show_in_ISO_format = false

    text_widget.Refresh = function()
        local now = os.date("*t")
        local month_string = month_strings[now.month]
        local weekday_string = weekday_strings[now.wday]

        local hour_12_format = 0
        if now.hour == 0 then
            hour_12_format = 12
        elseif now.hour <= 12 then
            hour_12_format = now.hour
        else
            hour_12_format = now.hour - 12
        end

        if text_widget.show_in_ISO_format then
            text_widget.markup =
                '<span font="Odin Rounded 10">' .. tostring(now.year) .. "</span>\n" ..
                '<span font="Odin Rounded 13">-' .. tostring(now.month) .. "</span>\n" ..
                '<span font="Odin Rounded 13">-' .. tostring(now.day) .. "</span>\n\n" ..
                '<span font="Odin Rounded 18">' .. tostring(hour_12_format) .. "\n" ..
                tostring(now.min) .. "\n" ..
                tostring(now.hour) .. "</span>"
        else
            text_widget.markup =
                '<span font="Odin Rounded 13">' .. month_string .. "</span>\n" ..
                '<span font="Odin Rounded 18">' .. tostring(now.day) .. "</span>\n" ..
                '<span font="Odin Rounded 13">' .. weekday_string .. "</span>\n\n" ..
                '<span font="Odin Rounded 18">' .. tostring(hour_12_format) .. "\n" ..
                tostring(now.min) .. "\n" ..
                tostring(now.hour) .. "</span>"
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
        body_widget,
        text_widget,
        layout = wibox.layout.stack
    }

    -- create final widget with padding so that it doesn't touch the edge of the screen
    local clock_widget = wibox.widget {
        stacked_widget,
        top = 10,
        bottom = 10,
        layout = wibox.container.margin
    }
    if widget_on_right_screen then
        clock_widget.left = 0
        clock_widget.right = 10
    else
        clock_widget.left = 10
        clock_widget.right = 0
    end


    clock_widget:buttons(gears.table.join(
        awful.button({}, 1, function()
            text_widget.show_in_ISO_format = not text_widget.show_in_ISO_format
            text_widget.Refresh()
        end),
        awful.button({}, 3, function()
            text_widget.show_in_ISO_format = not text_widget.show_in_ISO_format
            text_widget.Refresh()
        end)
    ))

    return clock_widget

end

return CreateTextClockWidget
