local template = rf2.executeScript(rf2.radio.template)
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
local filterConfig = rf2.useApi("mspFilterConfig").getDefaults()

labels[#labels + 1] = { t = "Gyro Lowpass 1",           x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_type,           id = "gyroLowpassType" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_static_hz,      id = "gyroLowpassFrequency" }
labels[#labels + 1] = { t = "Gyro Lowpass 1 Dynamic",   x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Min cutoff",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_dyn_min_hz,     id = "gyroLowpassDynMinFrequency" }
fields[#fields + 1] = { t = "Max cutoff",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf1_dyn_max_hz,     id = "gyroLowpassDynMaxFrequency" }
labels[#labels + 1] = { t = "Gyro Lowpass 2",           x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf2_type,           id = "gyroLowpass2Type" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_lpf2_static_hz,      id = "gyroLowpass2Frequency" }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Gyro Notch 1",             x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_hz_1,     id = "gyroNotch1Frequency" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_cutoff_1, id = "gyroNotch1Cutoff" }
labels[#labels + 1] = { t = "Gyro Notch 2",             x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_hz_2,     id = "gyroNotch2Frequency" }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.gyro_soft_notch_cutoff_2, id = "gyroNotch2Cutoff" }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Dynamic Notch Filters",    x = x,          y = incY(lineSpacing) }
-- TODO: enable/disable dynamic notch filters by setting/clearing feature DYN_NOTCH (see MSP_FEATURE_CONFIG)
fields[#fields + 1] = { t = "Count",                    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_count }
fields[#fields + 1] = { t = "Q",                        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_q,              id = "gyroDynamicNotchQ" }
fields[#fields + 1] = { t = "Min Frequency",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_min_hz,         id = "gyroDynamicNotchMinHz" }
fields[#fields + 1] = { t = "Max Frequency",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = filterConfig.dyn_notch_max_hz,         id = "gyroDynamicNotchMaxHz"}
-- TODO: preset and min_hz for API >= 12.08

local function receivedFilterConfig(page, _)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi("mspFilterConfig").read(receivedFilterConfig, self, filterConfig)
    end,
    write = function(self)
        rf2.useApi("mspFilterConfig").write(filterConfig)
        rf2.settingsSaved(true, true)
    end,
    title       = "Gyro Filters",
    labels      = labels,
    fields      = fields,
}
