local PageFiles = {}
local settings = rf2.loadSettings()

local function addPage(key, title, script, showIfNotSet)
    if settings[key] == 1 or (showIfNotSet and not settings[key]) then
        PageFiles[#PageFiles + 1] = { title = title, script = script }
    end
end

addPage("showStatus", "Status", "status", true)
addPage("showRates", "Rates", "rates", true)
addPage("showRateDynamics", "Rate Dynamics", "rate_dynamics", true)
addPage("showPidGains", "PID Gains", "profile_pids", true)
addPage("showPidController", "PID Controller", "profile_pidcon", true)
addPage("showProfileVarious", "Profile - Various", "profile_various", true)
addPage("showProfileRescue", "Profile - Rescue", "profile_rescue", true)
addPage("showProfileGovernor", "Profile - Governor", "profile_governor", true)
addPage("showBattery", "Battery", "battery", true)
addPage("showServos", "Servos", "servos", true)
addPage("showMixer", "Mixer", "mixer", true)
addPage("showGyroFilters", "Gyro Filters", "filters", true)
addPage("showGovernor", "Governor", "governor", true)
addPage("showAccelerometerTrim", "Accelerometer Trim", "accelerometer", true)

if rf2.apiVersion >= 12.07 then
    addPage("showModelOnTx", "Model", "model", true)
    addPage("showExperimental", "Experimental (!)", "experimental", false)
    addPage("showFlyRotor", "ESC - FLYROTOR", "esc_flyrotor", false)
    addPage("showPlatinumV5", "ESC - HW Platinum V5", "esc_hwpl5", false)
    addPage("showTribunus", "ESC - Scorpion Tribunus", "esc_scorp", false)
    if rf2.apiVersion >= 12.08 then
        addPage("showXdfly", "ESC - XDFly/OMP/ZTW", "esc_xdfly", false)
    end
    addPage("showYge", "ESC - YGE", "esc_yge", false)

    PageFiles[#PageFiles + 1] = { title = "Settings", script = "settings" }
end

return PageFiles
