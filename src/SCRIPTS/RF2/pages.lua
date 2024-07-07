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
PageFiles[#PageFiles + 1] = { title = "HWPL5 - Basic", script = "HWPL5/esc_basic.lua" }
PageFiles[#PageFiles + 1] = { title = "HWPL5 - Advanced", script = "HWPL5/esc_advanced.lua" }
PageFiles[#PageFiles + 1] = { title = "HWPL5 - Other", script = "HWPL5/esc_other.lua" }

return PageFiles
