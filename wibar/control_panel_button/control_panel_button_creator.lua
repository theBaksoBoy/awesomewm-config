-- widget for creating the widget used to open the control panel on each screen

local function CreateControlPanelButtonWidget(LeftClickFunction)

    local function CreateImageWidget(path)
        return wibox.widget {
            image = path,
            resize = false,
            widget = wibox.widget.imagebox
        }
    end

    -- create widgets for all the individual images that the button is composed of
    local unselected_widget = CreateImageWidget(config_dir .. "wibar/control_panel_button/unselected.png")
    local selected_widget = CreateImageWidget(config_dir .. "wibar/control_panel_button/selected.png")

    -- make the initial state be unselected
    selected_widget.visible = false

    -- make a widget that stacks all the image widgets on top each other
    local control_panel_button_widget = wibox.widget {
        unselected_widget,
        selected_widget,
        layout = wibox.layout.stack
    }

    function control_panel_button_widget:SetState(is_active)
        unselected_widget.visible = not is_active
        selected_widget.visible = is_active
    end

    control_panel_button_widget:buttons(gears.table.join(
        awful.button({}, 1, function()
            control_panel_button_widget.LeftClickFunction()
        end)
    ))

    -- function that get called when the button is pressed
    control_panel_button_widget.LeftClickFunction = LeftClickFunction

    return control_panel_button_widget

end

return CreateControlPanelButtonWidget
