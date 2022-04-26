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

x = margin
y = yMinLim - tableSpacing.header

fields[#fields + 1] = { t = "Mode",                x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4,     vals = { 1 }, table = { [0]="OFF", "PASSTHROUGH", "STANDARD", "MODE1", "MODE2" } }
fields[#fields + 1] = { t = "Spoolup Time",        x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 2,3 }, scale = 10 }
fields[#fields + 1] = { t = "Tracking Time",       x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 4,5 }, scale = 10 }
fields[#fields + 1] = { t = "Recovery Time",       x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 6,7 }, scale = 10 }
fields[#fields + 1] = { t = "AR Bailout Time",     x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 10,11 }, scale = 10 }
fields[#fields + 1] = { t = "AR Timeout",          x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 8,9 }, scale = 10 }
fields[#fields + 1] = { t = "AR Min Entry Time",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 12,13 }, scale = 10 }
fields[#fields + 1] = { t = "Zero Throttle TO",    x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 14,15 }, scale = 10 }
fields[#fields + 1] = { t = "HS Signal Timeout",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 16,17 }, scale = 10 }
fields[#fields + 1] = { t = "HS Filter Cutoff",    x = x, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000,  vals = { 20,21 } }
fields[#fields + 1] = { t = "Volt. Filter Cutoff", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000,  vals = { 18,19 } }
fields[#fields + 1] = { t = "TTA Filter Cutoff", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000,  vals = { 22,23 } }

return {
    read        = 142, -- MSP_GOVERNOR
    write       = 143, -- MSP_SET_GOVERNOR
    title       = "Governor",
    reboot      = true,
    eepromWrite = true,
    minBytes    = 23,
    labels      = labels,
    fields      = fields,
}
