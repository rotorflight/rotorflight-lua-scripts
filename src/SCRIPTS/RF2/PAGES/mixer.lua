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

labels[#labels + 1] = { t = localization.swashplate,         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.geo_correction,     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -125,  max = 125,  vals = { 19 }, scale = 5 }
fields[#fields + 1] = { t = localization.total_pitch_limit,  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 3000, vals = { 10, 11 }, scale = 83.33333333333333, mult = 8.3333333333333 }
fields[#fields + 1] = { t = localization.phase_angle,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1800, max = 1800, vals = { 8, 9 }, scale = 10, mult = 5 }
fields[#fields + 1] = { t = localization.tta_precomp,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 250,  vals = { 18 } }

labels[#labels + 1] = { t = localization.swashplate_link_trims,  x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.roll_trim,              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 12, 13 }, scale = 10 }
fields[#fields + 1] = { t = localization.pitch_trim,             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 14, 15 }, scale = 10 }
fields[#fields + 1] = { t = localization.coll_trim,              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 16, 17 }, scale = 10 }

labels[#labels + 1] = { t = localization.motorised_tail,  x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.motor_idle_thr,  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 250,  vals = { 3 }, scale = 10 }
fields[#fields + 1] = { t = localization.center_trim,     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -500,  max = 500,  vals = { 4,5 }, scale = 10 }

return {
    read        = 42, -- MSP_MIXER_CONFIG
    write       = 43, -- MSP_SET_MIXER_CONFIG
    eepromWrite = true,
    reboot      = false,
    title       = localization.mixer,
    minBytes    = 19,
    labels      = labels,
    fields      = fields,
}
