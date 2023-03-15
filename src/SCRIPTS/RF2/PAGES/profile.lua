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

fields[#fields + 1] = { t = "PID mode",                x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 1 }, table = { [0] = "MODE 0", "MODE 1", "MODE 2" } }
-- TODO? add MODE 9
-- TODO? show WAY in mode 2 and 9 (see configurator, but it doesn't seem to work there?)

fields[#fields + 1] = { t = "Error decay",             x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 2 }, scale = 10 }
fields[#fields + 1] = { t = "Error rotation",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 3 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "Error limit roll",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 4,5 }, scale = 5, mult = 5 }
fields[#fields + 1] = { t = "Error limit pitch",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 6,7 }, scale = 5, mult = 5 }
fields[#fields + 1] = { t = "Error limit yaw",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 8,9 }, scale = 5, mult = 5 }
-- TODO? toggle 'I-term limits', off = 1000

fields[#fields + 1] = { t = "I-term relax type",       x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 10 }, table = { [0] = "OFF", "RP", "RPY" } }
fields[#fields + 1] = { t = "Cut-off point R",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 14 } }
fields[#fields + 1] = { t = "Cut-off point P",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 15 } }
fields[#fields + 1] = { t = "Cut-off point Y",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 16 } }
fields[#fields + 1] = { t = "I-term relax level R",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 250, vals = { 11 } }
fields[#fields + 1] = { t = "I-term relax level P",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 250, vals = { 12 } }
fields[#fields + 1] = { t = "I-term relax level Y",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 250, vals = { 13 } }

labels[#labels + 1] = { t = "Yaw",                     x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "CW stop gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 250, vals = { 17 } }
fields[#fields + 1] = { t = "CCW stop gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 250, vals = { 18 } }
fields[#fields + 1] = { t = "Cyclic FF gain",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 19,20 } }
fields[#fields + 1] = { t = "Col. FF gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 21,22 } }
fields[#fields + 1] = { t = "Col. FF imp gain",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 23,24 } }
fields[#fields + 1] = { t = "Col. FF imp freq",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 25 } }

labels[#labels + 1] = { t = "Pitch",                   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Col. FF gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 26,27 } }
fields[#fields + 1] = { t = "Col. FF imp gain",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 28,29 } }

labels[#labels + 1] = { t = "Acro trainer",            x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 255, vals = { 33 } }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 80, vals = { 34 } }

labels[#labels + 1] = { t = "Angle mode",              x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 30 } }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 90, vals = { 31 } }

labels[#labels + 1] = { t = "Horizon mode",            x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 32 } }

return {
    read        = 94, -- MSP_PID_PROFILE
    write       = 95, -- MSP_SET_PID_PROFILE
    title       = "Profile",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 34,
    labels      = labels,
    fields      = fields,
}
