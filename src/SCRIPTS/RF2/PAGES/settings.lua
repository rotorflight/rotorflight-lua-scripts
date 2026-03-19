local template = rf2.executeScript(rf2.radio.template)
local settings = rf2.loadSettings()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local hideShow = { [0] = "Hide", "Show" }
local offOn = { [0] = "Off", "On" }
local canUseLvgl = rf2.executeScript("F/canUseLvgl")()

y = yMinLim - tableSpacing.header
labels[1] = { t = "Display FC Pages",        x = x, y = incY(lineSpacing) }
fields[1] = { t = "Status",                  x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[2] = { t = "Rates",                   x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[3] = { t = "Rate Dynamics",           x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[4] = { t = "PID Gains",               x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[5] = { t = "PID Controller",          x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[6] = { t = "Profile - Various",       x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[7] = { t = "Profile - Rescue",        x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[8] = { t = "Profile - Governor",      x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[9] = { t = "Battery",                 x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[10] = { t = "Servos",                 x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[11] = { t = "Mixer",                  x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[12] = { t = "Gyro Filters",           x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[13] = { t = "Governor",               x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[14] = { t = "Accelerometer Trim",     x = x + indent, y = incY(lineSpacing), sp = x + sp }

incY(lineSpacing * 0.5)
labels[2] = { t = "Display Various Pages",   x = x, y = incY(lineSpacing) }
fields[15] = { t = "Model",                  x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[16] = { t = "Experimental (!)",       x = x + indent, y = incY(lineSpacing), sp = x + sp }

incY(lineSpacing * 0.5)
labels[3] = { t = "Display ESC Pages",       x = x, y = incY(lineSpacing) }
fields[17] = { t = "FLYROTOR",               x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[18] = { t = "HW Platinum V5",         x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[19] = { t = "Scorpion Tribunus",      x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[20] = { t = "XDFly/OMP/ZTW",          x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[21] = { t = "YGE",                    x = x + indent, y = incY(lineSpacing), sp = x + sp }

incY(lineSpacing * 0.5)
labels[4] = { t = "Rf2bg Options",           x = x, y = incY(lineSpacing) }
fields[22] = { t = "Adjustment Teller",      x = x + indent, y = incY(lineSpacing), sp = x + sp }

if canUseLvgl then
    incY(lineSpacing * 0.5)
    labels[5] = { t = "Tool Options",        x = x, y = incY(lineSpacing) }
    fields[23] = { t = "Use touch UI",       x = x + indent, y = incY(lineSpacing), sp = x + sp }
end

local function setValues()
    fields[1].data = { value = settings.showStatus or 1, min = 0, max = 1, table = hideShow }
    fields[2].data = { value = settings.showRates or 1, min = 0, max = 1, table = hideShow }
    fields[3].data = { value = settings.showRateDynamics  or 1, min = 0, max = 1, table = hideShow }
    fields[4].data = { value = settings.showPidGains or 1, min = 0, max = 1, table = hideShow }
    fields[5].data = { value = settings.showPidController or 1, min = 0, max = 1, table = hideShow }
    fields[6].data = { value = settings.showProfileVarious or 1, min = 0, max = 1, table = hideShow }
    fields[7].data = { value = settings.showProfileRescue or 1, min = 0, max = 1, table = hideShow }
    fields[8].data = { value = settings.showProfileGovernor or 1, min = 0, max = 1, table = hideShow }
    fields[9].data = { value = settings.showBattery or 1, min = 0, max = 1, table = hideShow }
    fields[10].data = { value = settings.showServos or 1, min = 0, max = 1, table = hideShow }
    fields[11].data = { value = settings.showMixer or 1, min = 0, max = 1, table = hideShow }
    fields[12].data = { value = settings.showGyroFilters or 1, min = 0, max = 1, table = hideShow }
    fields[13].data = { value = settings.showGovernor or 1, min = 0, max = 1, table = hideShow }
    fields[14].data = { value = settings.showAccelerometerTrim or 1, min = 0, max = 1, table = hideShow }
    fields[15].data = { value = settings.showModelOnTx or 0, min = 0, max = 1, table = hideShow }
    fields[16].data = { value = settings.showExperimental or 0, min = 0, max = 1, table = hideShow }
    fields[17].data = { value = settings.showFlyRotor or 0, min = 0, max = 1, table = hideShow }
    fields[18].data = { value = settings.showPlatinumV5 or 0, min = 0, max = 1, table = hideShow }
    fields[19].data = { value = settings.showTribunus or 0, min = 0, max = 1, table = hideShow }
    fields[20].data = { value = settings.showXdfly or 0, min = 0, max = 1, table = hideShow }
    fields[21].data = { value = settings.showYge or 0, min = 0, max = 1, table = hideShow }
    fields[22].data = { value = settings.useAdjustmentTeller or 0, min = 0, max = 1, table = offOn }
    if canUseLvgl then
        fields[23].data = { value = settings.useLvgl or 1, min = 0, max = 1, table = offOn }
    end
end

return {
    read = function(self)
        setValues()
        rf2.onPageReady(self)
    end,
    write = function(self)
        settings.showStatus = fields[1].data.value
        settings.showRates = fields[2].data.value
        settings.showRateDynamics = fields[3].data.value
        settings.showPidGains = fields[4].data.value
        settings.showPidController = fields[5].data.value
        settings.showProfileVarious = fields[6].data.value
        settings.showProfileRescue = fields[7].data.value
        settings.showProfileGovernor = fields[8].data.value
        settings.showBattery = fields[9].data.value
        settings.showServos = fields[10].data.value
        settings.showMixer = fields[11].data.value
        settings.showGyroFilters = fields[12].data.value
        settings.showGovernor = fields[13].data.value
        settings.showAccelerometerTrim = fields[14].data.value
        settings.showModelOnTx = fields[15].data.value
        settings.showExperimental = fields[16].data.value
        settings.showFlyRotor = fields[17].data.value
        settings.showPlatinumV5 = fields[18].data.value
        settings.showTribunus = fields[19].data.value
        settings.showXdfly = fields[20].data.value
        settings.showYge = fields[21].data.value
        if settings.useAdjustmentTeller ~= fields[22].data.value then
            settings.useAdjustmentTeller = fields[22].data.value
            rf2.executeScript("F/pilotConfigReset")() -- restart rf2bg
        end
        if canUseLvgl then
            settings.useLvgl = fields[23].data.value
        end
        rf2.saveSettings(settings)
        rf2.reloadMainMenu(true)
        rf2.settingsSaved(false, false)
    end,
    title       = "Settings",
    labels      = labels,
    fields      = fields
}
