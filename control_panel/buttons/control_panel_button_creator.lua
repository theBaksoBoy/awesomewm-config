-- widget for creating buttons used in the control panel

local function CreateButtonWidget(images, LeftClickFunction)

    local button_widget = wibox.widget {
        image = nil,
        resize = false,
        widget = wibox.widget.imagebox
    }

    button_widget.images = images

    button_widget.state_index = 1

    button_widget.LeftClickFunction = LeftClickFunction

    function button_widget:UpdateImage()
        button_widget.image = button_widget.images[button_widget.state_index]
    end

    button_widget:UpdateImage()

    button_widget:buttons(gears.table.join(
        awful.button({}, 1, function()

          -- increment state index and update the image
            button_widget.state_index = button_widget.state_index % #button_widget.images + 1
            button_widget:UpdateImage()

          -- play TUNIC sound effect
            awful.spawn.with_shell("paplay " .. config_dir .. "sounds/TUNIC_assign_to_button.wav &")

            button_widget.LeftClickFunction(button_widget.state_index)

        end)
    ))

    return button_widget

end

return CreateButtonWidget
