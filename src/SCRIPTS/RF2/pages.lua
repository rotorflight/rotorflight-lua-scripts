local PageFiles = {}

-- Rotorflight pages.
PageFiles[#PageFiles + 1] = { title = "Profile - PIDs", script = "pids.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Governor", script = "profile_governor.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Rescue", script = "profile_rescue.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Various", script = "profile.lua" }
PageFiles[#PageFiles + 1] = { title = "Copy profiles", script = "copy_profiles.lua" }
PageFiles[#PageFiles + 1] = { title = "Rates", script = "ratesrf.lua" }
PageFiles[#PageFiles + 1] = { title = "Governor", script = "governor.lua" }
PageFiles[#PageFiles + 1] = { title = "Filters", script = "filters.lua" }
PageFiles[#PageFiles + 1] = { title = "Accelerometer trim", script = "accelerometer.lua" }
--PageFiles[#PageFiles + 1] = { title = "Receiver", script = "rxrf.lua" }
PageFiles[#PageFiles + 1] = { title = "Failsafe", script = "failsafe.lua" }
--PageFiles[#PageFiles + 1] = { title = "Motors", script = "motors.lua" }

-- Betaflight pages that might (one day) work with Rotorflight (untested).
--PageFiles[#PageFiles + 1] = { title = "VTX Settings", script = "vtx.lua" }
--PageFiles[#PageFiles + 1] = { title = "GPS Rescue", script = "rescue.lua" }
--PageFiles[#PageFiles + 1] = { title = "GPS PIDs", script = "gpspids.lua" }

-- Original Betaflight pages that are incompatible, because the MSP messages are different or not implemented in RF.
--PageFiles[#PageFiles + 1] = { title = "Profiles", script = "profiles.lua" }
--PageFiles[#PageFiles + 1] = { title = "PIDs 1", script = "pids1.lua" }
--PageFiles[#PageFiles + 1] = { title = "PIDs 2", script = "pids2.lua" }
--PageFiles[#PageFiles + 1] = { title = "PIDs Advanced", script = "pids_advanced.lua" }
--PageFiles[#PageFiles + 1] = { title = "Rates", script = "rates.lua" }
--PageFiles[#PageFiles + 1] = { title = "Filters 1", script = "filters1.lua" }
--PageFiles[#PageFiles + 1] = { title = "Filters 2", script = "filters2.lua" }
--PageFiles[#PageFiles + 1] = { title = "Receiver", script = "rx.lua" }
--PageFiles[#PageFiles + 1] = { title = "Motors", script = "pwm.lua" }
--PageFiles[#PageFiles + 1] = { title = "Simplified Tuning", script = "simplified_tuning.lua" }

return PageFiles
