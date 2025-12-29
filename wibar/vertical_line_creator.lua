-- thing that creates widget for wibar that stretches vertically as much as possible

local function CreateVerticalLineWidget()

    local vertical_line_widget = wibox.widget {
        fit = function(_, _, width, height)
            return 3, height
        end,
        draw = function(_, _, cr, width, height)
            -- draw a vertical line
            cr:set_source_rgb(1, 1, 1)
            cr:set_line_width(3)
            cr:move_to(16, 0)
            cr:line_to(16, height)
            cr:stroke()
        end,
        layout = wibox.widget.base.make_widget
    }

    return vertical_line_widget

end

return CreateVerticalLineWidget
