local PageFiles = {}

-- Rotorflight pages.
PageFiles[#PageFiles + 1] = { title = "Profile - PIDs", script = "pids.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Governor", script = "profile_governor.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Rescue", script = "profile_rescue.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Various", script = "profile.lua" }
PageFiles[#PageFiles + 1] = { title = "Copy profiles", script = "copy_profiles.lua" }
PageFiles[#PageFiles + 1] = { title = "Rates", script = "rates.lua" }
PageFiles[#PageFiles + 1] = { title = "Governor", script = "governor.lua" }
PageFiles[#PageFiles + 1] = { title = "Servos", script = "servos.lua" }
PageFiles[#PageFiles + 1] = { title = "Mixer", script = "mixer.lua" }
PageFiles[#PageFiles + 1] = { title = "Filters", script = "filters.lua" }
PageFiles[#PageFiles + 1] = { title = "Accelerometer trim", script = "accelerometer.lua" }

if rf2.apiVersion >= 12.07 then
    PageFiles[#PageFiles + 1] = { title = "ESC - HW Platinum V5", script = "esc_hwpl5.lua" }
    PageFiles[#PageFiles + 1] = { title = "ESC - Scorpion Tribunus", script = "esc_scorp.lua" }
    PageFiles[#PageFiles + 1] = { title = "ESC - YGE", script = "esc_yge.lua" }
end

return PageFiles
