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

local gyroFilterType = { "1ST", "2ND", "PT1" }

labels[#labels + 1] = { t = "Gyro lowpass 1",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = #gyroFilterType, vals = { 2 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 3, 4 } }

labels[#labels + 1] = { t = "Gyro lowpass 1 dynamic",   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Min cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 16, 17 } }
fields[#fields + 1] = { t = "Max cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 18, 19 } }

labels[#labels + 1] = { t = "Gyro lowpass 2",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Filter type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = #gyroFilterType, vals = { 5 }, table = gyroFilterType }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 6, 7 } }

labels[#labels + 1] = { t = "Gyro notch 1",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 8, 9 } }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 10, 11 } }

labels[#labels + 1] = { t = "Gyro notch 2",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 12, 13 } }
fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4000, vals = { 14, 15 } }

--[[
labels[#labels + 1] = { t = "Dynamic Notch Filter",     x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Width %",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 20, vals = { 20 } }
fields[#fields + 1] = { t = "Q",                        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000, vals = { 21, 22 } }
fields[#fields + 1] = { t = "Min Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 60, max = 250, vals = { 23, 24 } }
fields[#fields + 1] = { t = "Max Frequency",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 200, max = 1000, vals = { 25, 26 } }
--]]

return {
    read        = 92, -- MSP_FILTER_CONFIG
    write       = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite = true,
    reboot      = true,
    title       = "Filters",
    minBytes    = 26,
    labels      = labels,
    fields      = fields,
}
