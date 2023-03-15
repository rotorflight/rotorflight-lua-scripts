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

local channels = { [0] = 
    "OFF", "R",    "P",    "RP",
    "Y",   "RY",   "PY",   "RPY",
    "T",   "RT",   "PT",   "RPT",
    "YT",  "RYT",  "PYT",  "RPYT",
    "C",   "RC",   "PC",   "RPC",
    "YC",  "RYC",  "PYC",  "RPYC",
    "TC",  "RTC",  "PTC",  "RPTC",
    "YTC", "RYTC", "PYTC", "RPYTC",
}

labels[#labels + 1] = { t = "Stick",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Low",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 8, 9 } }
fields[#fields + 1] = { t = "Center",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 6, 7 } }
fields[#fields + 1] = { t = "High",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 4, 5 } }

labels[#labels + 1] = { t = "RC Smoothing",      x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 17 }, table = { [0] = "Interpolation", "Filter" } }
fields[#fields + 1] = { t = "Channels",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #channels, vals = { 16 }, table = channels }
labels[#labels + 1] = { t = "Input Filter",      x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Cutoff",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 255, vals = { 19 }, table = { [0] = "Auto" } }
fields[#fields + 1] = { t = "Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 18 }, table = { [0] = "PT1", "BIQUAD"} }
labels[#labels + 1] = { t = "Derivative Filter", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Cutoff",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 255, vals = { 21 }, table = { [0] = "Auto" } }
fields[#fields + 1] = { t = "Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 20 }, table = { [0] = "Off", "PT1", "BIQUAD", "Auto"} }
fields[#fields + 1] = { t = "Auto Smoothness",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50, vals = { 22 } }

fields[#fields + 1] = { t = "Interpolation",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 14 }, table={ [0]="Off", "Preset", "Auto", "Manual"} }
fields[#fields + 1] = { t = "Interval",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 50, vals = { 15 } }

return {
    read        = 44, -- MSP_RX_CONFIG
    write       = 45, -- MSP_SET_RX_CONFIG
    title       = "Receiver",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 28,
    labels      = labels,
    fields      = fields,
}
