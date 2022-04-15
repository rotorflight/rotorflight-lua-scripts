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

local escProtocols = { [0] = "PWM", "OS125", "OS42", "MSHOT", "BRUSHED", "DS150", "DS300", "DS600", "PS1000", "DISABLED" }

fields[#fields + 1] = { t = "Protocol",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #escProtocols, vals = { 10 }, table = escProtocols }
labels[#labels + 1] = { t = "DSHOT" ,           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Bidir. DSHOT",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 9 }, table = { [0] = "OFF", "ON" } }
labels[#labels + 1] = { t = "Analog protocols", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Min Command",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 750, max = 2250, vals = { 5, 6 } }
fields[#fields + 1] = { t = "Min Throttle",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 750, max = 2250, vals = { 1, 2 } }
fields[#fields + 1] = { t = "Max Throttle",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 750, max = 2250, vals = { 3, 4 } }

labels[#labels + 1] = { t = "PWM" ,             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "PWM Frequency",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 200, max = 32000, vals = { 11, 12 }, mult = 100 }
fields[#fields + 1] = { t = "PWM Inversion",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 13 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "Unsynced PWM",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 14 }, table = { [0] = "OFF", "ON" } }

return {
    read        = 131, -- MSP_MOTOR_CONFIG
    write       = 222, -- MSP_SET_MOTOR_CONFIG
    reboot      = true,
    eepromWrite = true,
    title       = "Motors",
    minBytes    = 30,
    labels      = labels,
    fields      = fields,
}
