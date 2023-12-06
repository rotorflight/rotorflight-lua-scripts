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

labels[#labels + 1] = { t = "Swashplate",               x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Total pitch limit",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 3000, vals = { 9, 10 }, scale = 83.33333333333333, mult = 8.3333333333333 }
fields[#fields + 1] = { t = "Phase angle",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1800, max = 1800, vals = { 7, 8 }, scale = 10, mult = 5 }
fields[#fields + 1] = { t = "Cyclic ring",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 100, vals = { 6 } }
fields[#fields + 1] = { t = "Col. TTA precomp",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 250, vals = { 14 } }

labels[#labels + 1] = { t = "Swashplate link trims",    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Link trim #1",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -128, max = 127, vals = { 11 } }
fields[#fields + 1] = { t = "Link trim #2",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -128, max = 127, vals = { 12 } }
fields[#fields + 1] = { t = "Link trim #3",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -128, max = 127, vals = { 13 } }

labels[#labels + 1] = { t = "Motorised tail",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Motor idle thr%",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,    max = 250, vals = { 3 }, scale = 10 }
fields[#fields + 1] = { t = "Center trim",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -125, max = 125, vals = { 4 }, scale = 4 }

return {
    read        = 42, -- MSP_MIXER_CONFIG
    write       = 43, -- MSP_SET_MIXER_CONFIG
    eepromWrite = true,
    reboot      = false,
    title       = "Mixer",
    minBytes    = 14,
    labels      = labels,
    fields      = fields,
}
