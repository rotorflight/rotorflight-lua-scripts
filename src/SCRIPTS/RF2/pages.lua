local PageFiles = {}
local settings = assert(rf2.loadScript("PAGES/helpers/settingsHelper.lua"))().loadSettings()

-- Rotorflight pages.
PageFiles[#PageFiles + 1] = { title = "Status", script = "status.lua" }
PageFiles[#PageFiles + 1] = { title = "Rates", script = "rates.lua" }
PageFiles[#PageFiles + 1] = { title = "Rate Dynamics", script = "rate_dynamics.lua" }
PageFiles[#PageFiles + 1] = { title = "PID Gains", script = "profile_pids.lua" }
PageFiles[#PageFiles + 1] = { title = "PID Controller", script = "profile_pidcon.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Various", script = "profile_various.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Rescue", script = "profile_rescue.lua" }
PageFiles[#PageFiles + 1] = { title = "Profile - Governor", script = "profile_governor.lua" }
PageFiles[#PageFiles + 1] = { title = "Servos", script = "servos.lua" }
PageFiles[#PageFiles + 1] = { title = "Mixer", script = "mixer.lua" }
PageFiles[#PageFiles + 1] = { title = "Gyro Filters", script = "filters.lua" }
PageFiles[#PageFiles + 1] = { title = "Governor", script = "governor.lua" }
PageFiles[#PageFiles + 1] = { title = "Accelerometer Trim", script = "accelerometer.lua" }

if rf2.apiVersion >= 12.07 then
    if settings.showModelOnTx == 1 then
        PageFiles[#PageFiles + 1] = { title = "Model on TX", script = "model.lua" }
    end
    if settings.showExperimental == 1 then
        PageFiles[#PageFiles + 1] = { title = "Experimental (danger!)", script = "experimental.lua" }
    end
    if settings.showFlyRotor == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - FLYROTOR", script = "esc_flyrotor.lua" }
    end
    if settings.showPlatinumV5 == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - HW Platinum V5", script = "esc_hwpl5.lua" }
    end
    if settings.showTribunus == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - Scorpion Tribunus", script = "esc_scorp.lua" }
    end
    if rf2.apiVersion >= 12.08 and settings.showXdfly == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - XDFly", script = "esc_xdfly.lua" }
    end
    if settings.showYge == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - YGE", script = "esc_yge.lua" }
    end

    PageFiles[#PageFiles + 1] = { title = "Settings", script = "settings.lua" }
end

return PageFiles
