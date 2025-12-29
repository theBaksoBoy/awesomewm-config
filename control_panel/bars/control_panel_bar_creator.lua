-- widget for creating bars used in the control panel

local function CreateBarWidget(color)

    local main_bar = wibox.widget {

        -- start x positions and widths of the differently colored rectangle segments for the moving part of the bar
        horizontal_dimensions = {
            { x = 11, width = 18 },
            { x = 29, width = 1 },
            { x = 30, width = 18 }
        },

        -- colors for the three segments, for each different color the bar can be. Definitely not a clean solution but fuck you
        -- the values are taken from Krita, however when using those values here the rectangles have slightly off colors. Thus random-ass constants were added until the color matched up perfectly
        rgb = {
            ["red"] = {
                { (231+3)/255, (114+13)/255, (188+7)/255 },
                { (242+1)/255, (116+13)/255, (191+7)/255 },
                { (255)/255, (119+12)/255, (195+6)/255 }
            },
            ["green"] = {
                { (111+13)/255, (199+6)/255, (125+12)/255 },
                { (114+13)/255, (204+5)/255, (125+12)/255 },
                { (120+12)/255, (214+4)/255, (124+12)/255 }
            },
            ["blue"] = {
                { (114+13)/255, (141+11)/255, (231+3)/255 },
                { (117+13)/255, (140+11)/255, (245+1)/255 },
                { (119+12)/255, (140+11)/255, (255)/255 }
            },
            ["yellow"] = {
                { (231+3)/255, (186+7)/255, (114+13)/255 },
                { (242+1)/255, (199+6)/255, (116+13)/255 },
                { (255)/255, (213+4)/255, (119+12)/255 }
            }
        },

        start_y = 100,
        height = 191 - 100,

        fit = function(self, context, width, height)
            return width, height
        end,

        draw = function(self, context, cr, width, height)
            -- draw background image
            local image = gears.surface.load_uncached(config_dir .. "control_panel/bars/bar_background_" .. color .. ".png")
            cr:set_source_surface(image, 0, 0)
            cr:paint()

            -- draw the three renctangle segments for the moving part of the bar
            for i=1, 3 do
                cr:set_source_rgba(self.rgb[color][i][1], self.rgb[color][i][2], self.rgb[color][i][3], 1) -- set color
                cr:rectangle(self.horizontal_dimensions[i].x, self.start_y, self.horizontal_dimensions[i].width, self.height)
                cr:fill()
            end
        end,

        -- allow updates to positions and force redraw
        UpdateRectangles = function(self, start_y)
            self.start_y = start_y
            self.height = 191 - self.start_y
            self:emit_signal("widget::redraw_needed")
            self:emit_signal("widget::layout_changed")
        end,

        widget = wibox.widget.base.make_widget
    }

    -- widget for the top of the bar to make it look 3D like in the game
    local bar_cap = wibox.widget {
        {
            image = config_dir .. "control_panel/bars/bar_cap_" .. color .. ".png",
            resize = false,
            widget = wibox.widget.imagebox
        },
        left = 11,
        widget = wibox.container.margin
    }

    -- widget for the lines dividing the bar into segments that will be overlayed on top
    local bar_lines = wibox.widget {
        {
            image = config_dir .. "control_panel/bars/bar_lines.png",
            resize = false,
            widget = wibox.widget.imagebox
        },
        left = 11,
        top = 66,
        widget = wibox.container.margin
    }

    -- text displaying percentage
    local percentage_text = wibox.widget {
        text = "",
        font = "Odin Rounded 20",
        align = "left",
        valigh = "top",
        widget = wibox.widget.textbox
    }

    local percentage_text_colored = wibox.widget {
        percentage_text,
        fg = "#000000",
        widget = wibox.container.background
    }

    -- force it's size and position it under the bar
    local percentage_text_colored_positioned = wibox.widget {
        percentage_text_colored,
        left = 12,
        bottom = 140, -- the way the text works is absurdly jank, but I can't be fucking bothered to find a better solution
        layout = wibox.container.margin
    }

    -- combine the two widgets into the full bar
    local bar_widget = wibox.widget {
        main_bar,
        bar_cap,
        bar_lines,
        percentage_text_colored_positioned,
        layout = wibox.layout.stack
    }

    -- function for updating the visual of how filled the bar is
    -- factor = float in the range [0, 1]
    function bar_widget:UpdateValue(factor)
        factor = math.max(math.min(factor, 1), 0) -- make sure that the bar doesn't try to display more or less than it is capable of
        local rectangle_y_start = math.min(math.floor(202 + factor * (35 - 202) + 0.5), 191)
        main_bar:UpdateRectangles(rectangle_y_start)
        percentage_text.text = tostring(math.floor(factor * 100 + 0.5)) .. "%"
        bar_cap.top = rectangle_y_start - 21
    end

    -- set the bar's filled level to 0 to make sure that it looks correct before any other part of the code has updated it
    bar_widget:UpdateValue(0)

    return bar_widget

end

return CreateBarWidget
