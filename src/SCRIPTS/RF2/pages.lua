local PageFiles = {}
local settings = rf2.loadSettings()
local t = rf2.i18n.t

local SYMBOL = {
    RATES = rf2.baseDir .. "IMG/" .. "rates.png",
    PID = rf2.baseDir .. "IMG/" .. "pids.png",
    STATUS = rf2.baseDir .. "IMG/" .. "rfstatus.png",
    PID_CONTROLLER = rf2.baseDir .. "IMG/" .. "pids-controller.png",
    PROFILE = rf2.baseDir .. "IMG/" .. "profile.png",
    MAINROTOR = rf2.baseDir .. "IMG/" .. "mainrotor.png",
    RESCUE = rf2.baseDir .. "IMG/" .. "rescue.png",
    GOVERNOR = rf2.baseDir .. "IMG/" .. "governor.png",
    SERVOS = rf2.baseDir .. "IMG/" .. "servos.png",
    MIXER = rf2.baseDir .. "IMG/" .. "mixer.png",
    FILTERS = rf2.baseDir .. "IMG/" .. "filters.png",
    ACCELEROMETER = rf2.baseDir .. "IMG/" .. "acc.png",
    FBLSTATUS = rf2.baseDir .. "IMG/" .. "fblstatus.png",
    MSP_EXP = rf2.baseDir .. "IMG/" .. "msp_exp.png",
    FLRTR = rf2.baseDir .. "IMG/" .. "fltr.png",
    HOBBYWING = rf2.baseDir .. "IMG/" .. "hobbywing.png",
    SCORPION = rf2.baseDir .. "IMG/" .. "scorpion.png",
    XDFLY = rf2.baseDir .. "IMG/" .. "xdfly.png",
    YGE = rf2.baseDir .. "IMG/" .. "yge.png",
    SETTINGS = rf2.baseDir .. "IMG/" .. "settings.png",
    ADVANCED = rf2.baseDir .. "IMG/" .. "advanced.png"
}

-- Rotorflight pages.
PageFiles[#PageFiles + 1] = { title = t("PAGE_Status"), script = "status", icon=SYMBOL.STATUS }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Rates"), script = "rates", icon=SYMBOL.RATES }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Rate_Dynamics"), script = "rate_dynamics", icon=SYMBOL.ADVANCED }
PageFiles[#PageFiles + 1] = { title = t("PAGE_PID_Gains"), script = "profile_pids", icon=SYMBOL.PID }
PageFiles[#PageFiles + 1] = { title = t("PAGE_PID_Controller"), script = "profile_pidcon", icon=SYMBOL.PID_CONTROLLER }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Profile_Various"), script = "profile_various", icon=SYMBOL.MAINROTOR }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Profile_Rescue"), script = "profile_rescue", icon=SYMBOL.RESCUE }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Profile_Governor"), script = "profile_governor", icon=SYMBOL.GOVERNOR }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Servos"), script = "servos", icon=SYMBOL.SERVOS }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Mixer"), script = "mixer", icon=SYMBOL.MIXER }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Gyro_Filters"), script = "filters", icon=SYMBOL.FILTERS }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Governor"), script = "governor", icon=SYMBOL.GOVERNOR }
PageFiles[#PageFiles + 1] = { title = t("PAGE_Accelerometer_Trim"), script = "accelerometer", icon=SYMBOL.ACCELEROMETER }

if rf2.apiVersion >= 12.07 then
    if settings.showModelOnTx == 1 then
        PageFiles[#PageFiles + 1] = { title = t("PAGE_Model"), script = "model", icon=SYMBOL.FBLSTATUS }
    end
    if settings.showExperimental == 1 then
        PageFiles[#PageFiles + 1] = { title = t("PAGE_Experimental"), script = "experimental", icon=SYMBOL.MSP_EXP }
    end
    if settings.showFlyRotor == 1 then
        PageFiles[#PageFiles + 1] = { title = t("PAGE_ESC_FLYROTOR"), script = "esc_flyrotor", icon=SYMBOL.FLRTR }
    end
    if settings.showPlatinumV5 == 1 then
        PageFiles[#PageFiles + 1] = { title = t("PAGE_ESC_HW_Platinum_V5"), script = "esc_hwpl5", icon=SYMBOL.HOBBYWING }
    end
    if settings.showTribunus == 1 then
        PageFiles[#PageFiles + 1] = { title = t("PAGE_ESC_Scorpion_Tribunus"), script = "esc_scorp", icon=SYMBOL.SCORPION }
    end
    if rf2.apiVersion >= 12.08 and settings.showXdfly == 1 then
        PageFiles[#PageFiles + 1] = { title = t("PAGE_ESC_XDFly"), script = "esc_xdfly", icon=SYMBOL.XDFLY }
    end
    if settings.showYge == 1 then
        PageFiles[#PageFiles + 1] = { title = t("PAGE_ESC_YGE"), script = "esc_yge", icon=SYMBOL.YGE }
    end

    PageFiles[#PageFiles + 1] = { title = t("PAGE_Settings"), script = "settings", icon=SYMBOL.SETTINGS }
end

return PageFiles
