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

fields[#fields + 1] = { t = localization.full_headspeed,         x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50000, vals = { 1, 2 }, mult = 10}
fields[#fields + 1] = { t = localization.max_throttle,           x = x, y = inc.y(lineSpacing), sp = x + sp, min = 40, max = 100, vals = { 13 } }
fields[#fields + 1] = { t = localization.pid_master_gain,        x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 3 } }
fields[#fields + 1] = { t = localization.p_gain,                 x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 4 } }
fields[#fields + 1] = { t = localization.i_gain,                 x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 5 } }
fields[#fields + 1] = { t = localization.d_gain,                 x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 6 } }
fields[#fields + 1] = { t = localization.f_gain,                 x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 7 } }
fields[#fields + 1] = { t = localization.yaw_precomp,            x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 10 } }
fields[#fields + 1] = { t = localization.cyclic_precomp,         x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 11 } }
fields[#fields + 1] = { t = localization.col_precomp,            x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 12 } }
fields[#fields + 1] = { t = localization.tta_gain,               x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 8 } }
fields[#fields + 1] = { t = localization.tta_limit,              x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 9 } }

return {
    read        = 148, -- MSP_GOVERNOR_PROFILE
    write       = 149, -- MSP_SET_GOVERNOR_PROFILE
    title       = localization.profile_governor,
    reboot      = false,
    eepromWrite = true,
    minBytes    = 13,
    labels      = labels,
    fields      = fields,
}
