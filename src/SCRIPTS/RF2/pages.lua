local PageFiles = {}

-- Rotorflight pages.
PageFiles[#PageFiles + 1] = { title = localization.profile_pids, script = "pids.lua" }
PageFiles[#PageFiles + 1] = { title = localization.profile_governor, script = "profile_governor.lua" }
PageFiles[#PageFiles + 1] = { title = localization.profile_rescue, script = "profile_rescue.lua" }
PageFiles[#PageFiles + 1] = { title = localization.profile_various, script = "profile.lua" }
PageFiles[#PageFiles + 1] = { title = localization.copy_profiles, script = "copy_profiles.lua" }
PageFiles[#PageFiles + 1] = { title = localization.rates, script = "rates.lua" }
PageFiles[#PageFiles + 1] = { title = localization.governor, script = "governor.lua" }
PageFiles[#PageFiles + 1] = { title = localization.servos, script = "servos.lua" }
PageFiles[#PageFiles + 1] = { title = localization.mixer, script = "mixer.lua" }
PageFiles[#PageFiles + 1] = { title = localization.filters, script = "filters.lua" }
PageFiles[#PageFiles + 1] = { title = localization.accelerometer_trim, script = "accelerometer.lua" }

return PageFiles
