local PageFiles = {}
local settings = rf2.loadSettings()

-- Rotorflight pages.
PageFiles[#PageFiles + 1] = { title = "Status", script = "status" }
PageFiles[#PageFiles + 1] = { title = "Rates", script = "rates" }
PageFiles[#PageFiles + 1] = { title = "Rate Dynamics", script = "rate_dynamics" }
PageFiles[#PageFiles + 1] = { title = "PID Gains", script = "profile_pids" }
PageFiles[#PageFiles + 1] = { title = "PID Controller", script = "profile_pidcon" }
PageFiles[#PageFiles + 1] = { title = "Profile - Various", script = "profile_various" }
PageFiles[#PageFiles + 1] = { title = "Profile - Rescue", script = "profile_rescue" }
PageFiles[#PageFiles + 1] = { title = "Profile - Governor", script = "profile_governor" }
PageFiles[#PageFiles + 1] = { title = "Servos", script = "servos" }
PageFiles[#PageFiles + 1] = { title = "Mixer", script = "mixer" }
PageFiles[#PageFiles + 1] = { title = "Gyro Filters", script = "filters" }
PageFiles[#PageFiles + 1] = { title = "Governor", script = "governor" }
PageFiles[#PageFiles + 1] = { title = "Accelerometer Trim", script = "accelerometer" }

if rf2.apiVersion >= 12.07 then
    if settings.showModelOnTx == 1 then
        PageFiles[#PageFiles + 1] = { title = "Model", script = "model" }
    end
    if settings.showExperimental == 1 then
        PageFiles[#PageFiles + 1] = { title = "Experimental (!)", script = "experimental" }
    end
    if settings.showFlyRotor == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - FLYROTOR", script = "esc_flyrotor" }
    end
    if settings.showPlatinumV5 == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - HW Platinum V5", script = "esc_hwpl5" }
    end
    if settings.showTribunus == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - Scorpion Tribunus", script = "esc_scorp" }
    end
    if rf2.apiVersion >= 12.08 and settings.showXdfly == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - XDFly", script = "esc_xdfly" }
    end
    if settings.showYge == 1 then
        PageFiles[#PageFiles + 1] = { title = "ESC - YGE", script = "esc_yge" }
    end

    PageFiles[#PageFiles + 1] = { title = "Settings", script = "settings" }
end

return PageFiles
