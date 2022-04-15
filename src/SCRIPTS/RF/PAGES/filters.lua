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

local gyroFilterType = { [0] = "PT1", "BIQUAD" }

labels[#labels + 1] = { t = "Gyro Lowpass 1",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 2 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 3, 4 } }

labels[#labels + 1] = { t = "Gyro Lowpass 1 Dynamic",   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Min Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 26, 27 } }
fields[#fields + 1] = { t = "Max Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 28, 29 } }

labels[#labels + 1] = { t = "Gyro Lowpass 2",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 5 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 6, 7 } }

labels[#labels + 1] = { t = "Gyro Notch 1",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 8, 9 } }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 10, 11 } }

labels[#labels + 1] = { t = "Gyro Notch 2",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 12, 13 } }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 14, 15 } }

labels[#labels + 1] = { t = "D Term Lowpass 1",         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 16 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 17, 18 } }

labels[#labels + 1] = { t = "D Term Lowpass 1 Dynamic", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Min Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 30, 31 } }
fields[#fields + 1] = { t = "Max Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 32, 33 } }

labels[#labels + 1] = { t = "D Term Lowpass 2",         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 19 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 20, 21 } }

labels[#labels + 1] = { t = "D Term Notch",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 22, 23 } }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 24, 25 } }

--[[
labels[#labels + 1] = { t = "Dynamic Notch Filter",     x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Width %",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 20, vals = { 34 } }
fields[#fields + 1] = { t = "Q",                        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000, vals = { 35, 36 } }
fields[#fields + 1] = { t = "Min Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 60, max = 250, vals = { 37, 38 } }
fields[#fields + 1] = { t = "Max Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 200, max = 1000, vals = { 39, 40 } }
--]]

return {
    read        = 92, -- MSP_FILTER_CONFIG
    write       = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite = true,
    reboot      = false,
    title       = "Filters",
    minBytes    = 40,
    labels      = labels,
    fields      = fields,
}
