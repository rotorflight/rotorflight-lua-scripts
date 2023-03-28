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

fields[#fields + 1] = { t = "Rescue mode enabled",   x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1,     vals = { 1 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "Flip to upright",       x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1,     vals = { 2 }, table = { [0] = "No flip", "Flip" } }
fields[#fields + 1] = { t = "Pull-up collective",    x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,  vals = { 9,10 }, mult = 10 }
fields[#fields + 1] = { t = "Pull-up time",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 5 }, scale = 10 }
fields[#fields + 1] = { t = "Climb collective",      x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,  vals = { 11,12 }, mult = 10 }
fields[#fields + 1] = { t = "Climb time",            x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 6 }, scale = 10 }
fields[#fields + 1] = { t = "Hover collective",      x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,  vals = { 13,14 }, mult = 10 }
fields[#fields + 1] = { t = "Flip fail time",        x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 7 }, scale = 10 }
fields[#fields + 1] = { t = "Exit time",             x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 8 }, scale = 10 }
fields[#fields + 1] = { t = "Rescue level gain",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 5, max = 250,   vals = { 4 } }
fields[#fields + 1] = { t = "Rescue flip gain",      x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 5, max = 250,   vals = { 3 } }
fields[#fields + 1] = { t = "Rescue max rate",       x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000,  vals = { 23,24 }, mult = 10 }
fields[#fields + 1] = { t = "Rescue max accel",      x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 10000, vals = { 25,26 }, mult = 10 }
labels[#labels + 1] = { t = "Altitude hold",         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Hover altitude",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 15,16 }, mult = 10 }
fields[#fields + 1] = { t = "P-gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 17,18 }, mult = 10 }
fields[#fields + 1] = { t = "I-gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 19,20 }, mult = 10 }
fields[#fields + 1] = { t = "Max collective",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000,  vals = { 21,22 }, mult = 10 }

return {
    read        = 146, -- MSP_RESCUE_PROFILE
    write       = 147, -- MSP_SET_RESCUE_PROFILE
    title       = "Profile - Rescue",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 26,
    labels      = labels,
    fields      = fields,
}
