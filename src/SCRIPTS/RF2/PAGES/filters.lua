local template = assert(loadScript(radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

local gyroFilterType = { [0] = "NONE", "1ST", "2ND" }

labels[#labels + 1] = { t = localization.gyro_lowpass_1,           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.filter_type,              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 2 }, table = gyroFilterType }
fields[#fields + 1] = { t = localization.cutoff,                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 3, 4 } }

labels[#labels + 1] = { t = localization.Ggyro_lowpass_1_dynamic,   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.min_cutoff,               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 16, 17 } }
fields[#fields + 1] = { t = localization.max_cutoff,               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 18, 19 } }

labels[#labels + 1] = { t = localization.gyro_lowpass_2,           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.filter_type,              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 5 }, table = gyroFilterType }
fields[#fields + 1] = { t = localization.cutoff,                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 6, 7 } }

labels[#labels + 1] = { t = localization.gyro_notch_1,             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.center,                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 8, 9 } }
fields[#fields + 1] = { t = localization.cutoff,                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 10, 11 } }

labels[#labels + 1] = { t = localization.gyro_notch_2,             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.center,                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 12, 13 } }
fields[#fields + 1] = { t = localization.cutoff,                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 14, 15 } }

labels[#labels + 1] = { t = localization.dynamic_notch_filters,    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.count,                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 8, vals = { 20 } }
fields[#fields + 1] = { t = localization.q,                        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 100, vals = { 21 }, scale = 10 }
fields[#fields + 1] = { t = localization.min_frequency,            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 200, vals = { 22, 23 } }
fields[#fields + 1] = { t = localization.max_frequency,            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 100, max = 500, vals = { 24, 25 } }

return {
    read        = 92, -- MSP_FILTER_CONFIG
    write       = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite = true,
    reboot      = true,
    title       = localization.filters,
    minBytes    = 25,
    labels      = labels,
    fields      = fields,
}
