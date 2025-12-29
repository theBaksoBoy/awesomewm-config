
local wallpaperPathsForDaysOfWeek = {
    [0] = "Cotton_Nixie_space",  -- SUNDAY
    [1] = "cube_pondering",      -- Monday
    [2] = "cube_pondering",      -- Tuesday
    [3] = "cube_pondering",      -- Wednesday
    [4] = "spiral-space Cotton", -- Thursday
    [5] = "spiral-space Cotton", -- Friday
    [6] = "Cotton_Nixie_space"   -- Saturday
}

local dayOfWeek = tonumber(os.date("%w")) -- get weekday as an int. Starts on sunday as it is cringe

return wallpaperPathsForDaysOfWeek[dayOfWeek]
