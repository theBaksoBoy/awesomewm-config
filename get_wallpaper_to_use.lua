
local wallpaperPathsForDaysOfWeek = {
    [0] = "Mystic_Lands_characters",  -- SUNDAY
    [1] = "Mystic_Lands_characters",      -- Monday
    [2] = "cube_pondering",      -- Tuesday
    [3] = "spiral-space Cotton",      -- Wednesday
    [4] = "spiral-space Cotton", -- Thursday
    [5] = "CottonExplore", -- Friday
    [6] = "Mystic_Lands_background"   -- Saturday
}

local dayOfWeek = tonumber(os.date("%w")) -- get weekday as an int. Starts on sunday as it is cringe

return wallpaperPathsForDaysOfWeek[dayOfWeek]
