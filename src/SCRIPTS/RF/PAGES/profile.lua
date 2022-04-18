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

labels[#labels + 1] = { t = "I-term limit",            x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 1, 2 }, scale = 5 }
fields[#fields + 1] = { t = "Pitch",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 3, 4 }, scale = 5 }
fields[#fields + 1] = { t = "Yaw",                     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 5, 6 }, scale = 5 }
fields[#fields + 1] = { t = "I Term Decay",            x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 7 }, scale = 10 }
fields[#fields + 1] = { t = "I Term Rotation",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 8 }, table = { [0] = "OFF", "ON" } }

labels[#labels + 1] = { t = "I Term Relax",            x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Axes",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4, vals = { 9 }, table = { [0] = "NONE", "RP", "RPY", "RP (inc)", "RPY (inc)" } }
fields[#fields + 1] = { t = "Type",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 10 }, table = { [0] = "GYRO", "SETPOINT" } }
fields[#fields + 1] = { t = "Roll Cutoff",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 50, vals = { 11 } }
fields[#fields + 1] = { t = "Pitch Cutoff",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 50, vals = { 12 } }
fields[#fields + 1] = { t = "Yaw Cutoff",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 50, vals = { 13 } }

labels[#labels + 1] = { t = "Rate Normalization Mode", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Cyclic",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 30 }, table = { [0] = "ABSOLUTE", "LINEAR", "NATURAL" } }
fields[#fields + 1] = { t = "Collective",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 31 }, table = { [0] = "ABSOLUTE", "LINEAR", "NATURAL" } }

labels[#labels + 1] = { t = "Yaw",                     x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Center Offset",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -250, max = 250, vals = { 19, 20 } }
fields[#fields + 1] = { t = "CW Stop Gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 250, vals = { 21 } }
fields[#fields + 1] = { t = "CCW Stop Gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 250, vals = { 22 } }
fields[#fields + 1] = { t = "Cyclic FF Gain",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 23,24 } }
fields[#fields + 1] = { t = "Col. FF Gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 25,26 } }
fields[#fields + 1] = { t = "Col. FF Imp Gain",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2500, vals = { 27,28 } }
fields[#fields + 1] = { t = "Col. FF Imp Freq",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 29 } }
fields[#fields + 1] = { t = "TTA Gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 44 } }
fields[#fields + 1] = { t = "TTA Limit",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 45 } }

labels[#labels + 1] = { t = "Auto-levelling",          x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Acro Tr Lev Gain",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 255, vals = { 17 } }
fields[#fields + 1] = { t = "Acro Tr Max Angle",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 80, vals = { 18 } }
fields[#fields + 1] = { t = "Angle Lev Gain",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 14 } }
fields[#fields + 1] = { t = "Angle Max Angle",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 90, vals = { 15 } }
fields[#fields + 1] = { t = "Horizon Lev Gain",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 16 } }

labels[#labels + 1] = { t = "Rescue",                  x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Climb Collective",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 32, 33 } }
fields[#fields + 1] = { t = "Init. Climb Boost",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 34, 35 } }
fields[#fields + 1] = { t = "Init. Climb Dura.",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 36 }, scale = 10 }

labels[#labels + 1] = { t = "Governor",                x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Full Headspeed",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50000, vals = { 37, 38 }, mult = 10}
fields[#fields + 1] = { t = "PID Master Gain",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 39 } }
fields[#fields + 1] = { t = "P-gain",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 40 } }
fields[#fields + 1] = { t = "I-gain",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 41 } }
fields[#fields + 1] = { t = "D-gain",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 42 } }
fields[#fields + 1] = { t = "F-gain",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 43 } }
fields[#fields + 1] = { t = "Cyclic Precomp.",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 46 } }
fields[#fields + 1] = { t = "Col. Precomp",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 47 } }

return {
    read        = 94, -- MSP_PID_ADVANCED
    write       = 95, -- MSP_SET_PID_ADVANCED
    title       = "Profile",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 47,
    labels      = labels,
    fields      = fields,
}
