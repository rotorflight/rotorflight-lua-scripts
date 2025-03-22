local template = assert(rf2.loadScript(rf2.radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}
local mspFilterConfig = rf2.useApi("mspFilterConfig")
local filterConfig = mspFilterConfig.getDefaults()

labels[#labels + 1] = { t = "Gyro Lowpass 1",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_type,           id = "gyroLowpassType" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_static_hz,      id = "gyroLowpassFrequency" }
labels[#labels + 1] = { t = "Gyro Lowpass 1 Dynamic",   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Min cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_dyn_min_hz,     id = "gyroLowpassDynMinFrequency" }
fields[#fields + 1] = { t = "Max cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_dyn_max_hz,     id = "gyroLowpassDynMaxFrequency" }
labels[#labels + 1] = { t = "Gyro Lowpass 2",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf2_type,           id = "gyroLowpass2Type" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf2_static_hz,      id = "gyroLowpass2Frequency" }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Gyro Notch 1",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_hz_1,     id = "gyroNotch1Frequency" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_cutoff_1, id = "gyroNotch1Cutoff" }
labels[#labels + 1] = { t = "Gyro Notch 2",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_hz_2,     id = "gyroNotch2Frequency" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_cutoff_2, id = "gyroNotch2Cutoff" }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Dynamic Notch Filters",    x = x,          y = inc.y(lineSpacing) }
-- TODO: enable/disable dynamic notch filters by setting/clearing feature DYN_NOTCH (see MSP_FEATURE_CONFIG)
fields[#fields + 1] = { t = "Count",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_count }
fields[#fields + 1] = { t = "Q",                        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_q,              id = "gyroDynamicNotchQ" }
fields[#fields + 1] = { t = "Min Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_min_hz,         id = "gyroDynamicNotchMinHz" }
fields[#fields + 1] = { t = "Max Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_max_hz,         id = "gyroDynamicNotchMaxHz"}

local function receivedFilterConfig(page)
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspFilterConfig.read(filterConfig, receivedFilterConfig, self)
    end,
    write = function(self)
        mspFilterConfig.write(filterConfig)
        rf2.settingsSaved()
    end,
    eepromWrite = true,
    reboot      = true,
    title       = "Gyro Filters",
    labels      = labels,
    fields      = fields,
}
