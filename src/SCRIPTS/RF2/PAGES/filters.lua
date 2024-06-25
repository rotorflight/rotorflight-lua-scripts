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

local gyroFilterType = { [0] = "NONE", "1ST", "2ND" }

labels[#labels + 1] = { t = "Gyro lowpass 1",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 2 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 3, 4 } }

labels[#labels + 1] = { t = "Gyro lowpass 1 dynamic",   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Min cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 16, 17 } }
fields[#fields + 1] = { t = "Max cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 18, 19 } }

labels[#labels + 1] = { t = "Gyro lowpass 2",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 5 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 6, 7 } }

labels[#labels + 1] = { t = "Gyro notch 1",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 8, 9 } }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 10, 11 } }

labels[#labels + 1] = { t = "Gyro notch 2",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 12, 13 } }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 14, 15 } }

labels[#labels + 1] = { t = "Dynamic Notch Filters",    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Count",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 8, vals = { 20 } }
fields[#fields + 1] = { t = "Q",                        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 100, vals = { 21 }, scale = 10 }
fields[#fields + 1] = { t = "Min Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 200, vals = { 22, 23 } }
fields[#fields + 1] = { t = "Max Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 100, max = 500, vals = { 24, 25 } }

return {
    read        = 92, -- MSP_FILTER_CONFIG
    write       = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite = true,
    reboot      = true,
    title       = "Filters",
    minBytes    = 25,
    labels      = labels,
    fields      = fields,
    simulatorResponse = { 0, 1, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 25, 25, 0, 245, 0 },
}
