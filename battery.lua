
local battery_information = {
    is_charging = false,
    percentage = 100,
    time_remaining_hours = 0,
    time_remaining_minutes = 0,
    is_low = false,
    has_warned_about_being_low = false,
}

local function UpdateBatteryInformation()

    awful.spawn.easy_async_with_shell("acpi -b", function(stdout)

        -- examples on how the output of acpi -b can look:
        --
        -- Battery 0: Discharging, 69%, 01:23:45 remaining
        -- Battery 0: Charging, 7%, 01:23:45 until charged
        -- Battery 0: Full, 100%
        -- BAT0: Critical, 2%, 01:23:45 remaining
        -- BAT1: Unknown, 100%
        --
        -- on systems without battery, stdout will be empty
        if stdout == "" then return end

        local index_of_first_comma = string.find(stdout, ",")
        local index_of_first_colon, index_of_last_colon = string.find(stdout, ":")

        local index_of_status_start = index_of_first_colon + 2
        local index_of_status_end = index_of_first_comma - 1

        local index_of_percentage_start = index_of_first_comma + 2
        local index_of_percentage_end = string.find(stdout, "%%") - 1


        -- only change the variable if it is either charging or discharging.
        -- if it is either Critical or Unknown then it will just keep the value that it had last iteration
        local status = string.sub(stdout, index_of_status_start, index_of_status_end)
        if status == "Charging" then
            battery_information.is_charging = true
        elseif status == "Discharging" then
            battery_information.is_charging = false
        end

        battery_information.percentage = tonumber(string.sub(stdout, index_of_percentage_start, index_of_percentage_end))

        -- if the time remaining isn't mentioned in the output then just set it to 0 and return
        if string.sub(stdout, -1) == "%" then
            battery_information.time_remaining_hours = 0
            battery_information.time_remaining_minutes = 0
            return
        end

        battery_information.time_remaining_hours = tonumber(string.sub(stdout, index_of_last_colon - 5, index_of_last_colon - 4))
        battery_information.time_remaining_minutes = tonumber(string.sub(stdout, index_of_last_colon - 5, index_of_last_colon - 4))

        if battery_information.percentage <= 15 then
            battery_information.is_low = true
        else
            battery_information.is_low = false
            battery_information.has_warned_about_being_low = false
        end

    end)
end

-- start timer that updates the battery information every couple of seconds
if settings.use_battery_indicators then
    gears.timer({
        timeout = 5,
        autostart = true,
        single_shot = false,
        callback = function ()
            UpdateBatteryInformation()
        end
    })
end

return battery_information
