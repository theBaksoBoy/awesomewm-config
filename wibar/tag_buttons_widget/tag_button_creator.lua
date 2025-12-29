-- widget for creating each individual tag button

local function CreateTagButtonWidget(button_index, LeftClickFunction, RightClickFunction, screen_side)

    local function CreateImageWidget(path)
        return wibox.widget {
            image = path,
            resize = false,
            widget = wibox.widget.imagebox
        }
    end

    -- create widgets for all the individual images that the tag button is composed of
    local unselected_widget = CreateImageWidget(config_dir .. "wibar/tag_buttons_widget/unselected.png")
    local selected_widget = CreateImageWidget(config_dir .. "wibar/tag_buttons_widget/selected.png")
    local tag_image_widget = CreateImageWidget(config_dir .. "wibar/tag_buttons_widget/tag_" .. tostring(button_index) .. ".png")

    -- make a widget that stacks all the image widgets on top each other
    local stacked_images_widget = wibox.widget {
        unselected_widget,
        selected_widget,
        {
            tag_image_widget,
            halign = "center",
            valign = "center",
            widget = wibox.container.place
        },
        layout = wibox.layout.stack
    }

    -- give the widget margins so that it is moved away from the edge of the screen
    -- and so that it tiles correctly with other tag button widgets
    local tag_button_widget = wibox.widget {
        stacked_images_widget,
        left = 0,
        right = 0,
        top = 5,
        bottom = 0,
        widget = wibox.container.margin
    }

    function tag_button_widget:SetState(is_selected)
        unselected_widget.visible = not is_selected
        selected_widget.visible = is_selected
        if screen_side == "left" then
            tag_button_widget.left = 10
        else
            tag_button_widget.right = 10
        end
    end

    tag_button_widget:buttons(gears.table.join(
        awful.button({}, 1, function()
            tag_button_widget.LeftClickFunction(tag_button_widget.button_index)
        end),
        awful.button({}, 3, function()
            tag_button_widget.RightClickFunction(tag_button_widget.button_index)
        end)
    ))

    -- storing the index of the button given by the parameter from the function
    tag_button_widget.button_index = button_index
    -- functions that get called when the button is pressed
    tag_button_widget.LeftClickFunction = LeftClickFunction
    tag_button_widget.RightClickFunction = RightClickFunction

    return tag_button_widget

end

return CreateTagButtonWidget
