-- function that takes a widget as input whose vertical size is variable, and puts it inside of a
-- rectangle that is procedurally resized whenever the inputted widget changes.
-- returns the new widget with the inputted widget surrounded in the rectangle

local function WrapWidgetInDynamicSizedBody(widget_to_wrap, horizontal_alignment)

    local function CreateImageWidget(path)
        return wibox.widget {
            {
                image = path,
                resize = false,
                widget = wibox.widget.imagebox
            },
            halign = horizontal_alignment,
            widget = wibox.container.place
        }
    end

    -- create widgets for all the individual images that the tag button is composed of
    local top_cap = CreateImageWidget(config_dir .. "wibar/dynamic_sized_body/top.png")
    local bottom_cap = CreateImageWidget(config_dir .. "wibar/dynamic_sized_body/bottom.png")


    local wrapped_widget = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        top_cap,
        widget_to_wrap,
        bottom_cap,
    }

    return wrapped_widget

end

return WrapWidgetInDynamicSizedBody
