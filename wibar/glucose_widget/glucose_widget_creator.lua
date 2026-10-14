
local function CreateGlucoseWidget(widget_on_right_screen)

    local body_widget = wibox.widget {
        image = config_dir .. "wibar/glucose_widget/glucose_body.png",
        resize = false,
        widget = wibox.widget.imagebox
    }
    


    local glucose_text_widget = wibox.widget {
        text = "∙∙∙", -- initial value
        font = "Odin Rounded 14",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox
    }
    local glucose_text_widget_colorable = wibox.widget {
        glucose_text_widget,
        fg = "#FFF",
        widget = wibox.container.background
    }
    local glucose_text_widget_with_padding = wibox.widget {
        glucose_text_widget_colorable,
        bottom = 15,
        widget = wibox.container.margin
    }



    local timedelta_text_widget = wibox.widget {
        text = "∙∙∙", -- initial value
        font = "Odin Rounded 10",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox
    }
    local timedelta_text_widget_with_padding = wibox.widget {
        timedelta_text_widget,
        bottom = 3,
        widget = wibox.container.margin
    }



    local stacked_widget = wibox.widget {
        body_widget,
        {
            glucose_text_widget_with_padding,
            valign = "bottom",
            widget = wibox.container.place
        },
        {
            timedelta_text_widget_with_padding,
            valign = "bottom",
            widget = wibox.container.place
        },
        layout = wibox.layout.stack
    }



    -- create final widget with padding so that it doesn't touch the edge of the screen
    local glucose_widget = wibox.widget {
        stacked_widget,
        bottom = 10,
        layout = wibox.container.margin
    }
    if widget_on_right_screen then
        glucose_widget.left = 0
        glucose_widget.right = 10
    else
        glucose_widget.left = 10
        glucose_widget.right = 0
    end



    glucose_widget.Refresh = function()

        local file = io.open(config_dir .. "wibar/glucose_widget/current_reading.txt", "r")
        local minutes_since_glucose_reading = math.floor((os.time() - tonumber(file:read("*l"))) / 60 + 0.5)
        local glucose_value = tonumber(file:read("*l"))
        file:close()

        -- if it was more than an hour since the last reading it stops displaying the glucose value and returns early
        if minutes_since_glucose_reading >= 60 then
            glucose_text_widget.text = "∙∙∙"
            glucose_text_widget_colorable.fg = "#FFF"
            timedelta_text_widget.text = "old"
            return
        end

        glucose_text_widget.text = tostring(glucose_value)
        timedelta_text_widget.text = tostring(minutes_since_glucose_reading) .. "m"

        
        -- red: #F44
        -- orange: #FB2
        -- white: #FFF
        if glucose_value > 10 then
            glucose_text_widget_colorable.fg = "#FB2"
        elseif glucose_value < 4 then
            glucose_text_widget_colorable.fg = "#F44"
        else
            glucose_text_widget_colorable.fg = "#FFF"
        end 

    end



    -- refresh the widget each minute. The one minute timer starts after 7 seconds to give glucose_updater.py time to log in and stuff
    gears.timer {
        timeout = 7,
        autostart = true,
        single_shot = true,
        callback = function()
            
            gears.timer {
                timeout = 60,
                autostart = true,
                call_now = true,
                callback = glucose_widget.Refresh
            }

        end
    }


    
    return glucose_widget

end

return CreateGlucoseWidget
