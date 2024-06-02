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

fields[#fields + 1] = { t = localization.pid_mode,   x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 2, vals = { 1 }, table = { [0] = "MODE 0", "MODE 1", "MODE 2" } }

labels[#labels + 1] = { t = localization.error_decay_ground,   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.time,  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 2 }, scale = 10 }

labels[#labels + 1] = { t = localization.error_decay_cyclic,   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.time,   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 3 }, scale = 10 }
fields[#fields + 1] = { t = localization.limit,   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 5 } }

labels[#labels + 1] = { t = localization.error_decay_yaw,   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.time,   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 4 }, scale = 10 }
fields[#fields + 1] = { t = localization.limit,   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 6 } }

labels[#labels + 1] = { t = localization.error_limit,   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.roll,  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 8 } }
fields[#fields + 1] = { t = localization.pitch,   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 9 } }
fields[#fields + 1] = { t = localization.yaw,   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 10 } }

labels[#labels + 1] = { t = localization.offset_limit,          x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.roll,                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 37 } }
fields[#fields + 1] = { t = localization.localization.pitch,    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 38 } }

fields[#fields + 1] = { t = localization.error_rotation,      x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 7 }, table = { [0] = "OFF", "ON" } }

-- TODO? toggle 'I-term limilocalization.ts', off = 1000

fields[#fields + 1] = { t = localization.i_term_relax_type,   x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 17 }, table = { [0] = "OFF", "RP", "RPY" } }
fields[#fields + 1] = { t = localization.cut_off_point_r,     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 18 } }
fields[#fields + 1] = { t = localization.cut_off_point_p,     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 19 } }
fields[#fields + 1] = { t = localization.cut_off_point_y,     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 20 } }

labels[#labels + 1] = { t = localization.yaw,               x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.cw_stop_gain,      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 250, vals = { 21 } }
fields[#fields + 1] = { t = localization.ccw_stop_gain,     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 250, vals = { 22 } }

fields[#fields + 1] = { t = localization.precomp_cutoff,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 23 } }
fields[#fields + 1] = { t = localization.cyclic_ff_gain,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 24 } }
fields[#fields + 1] = { t = localization.col_ff_gain,           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 25 } }
fields[#fields + 1] = { t = localization.col_imp_ff_gain,       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 26 } }
fields[#fields + 1] = { t = localization.col_imp_ff_decay,      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 27 } }

labels[#labels + 1] = { t = localization.pitch,         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.col_ff_gain,   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 28 } }

labels[#labels + 1] = { t = localization.pid_controller,    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.r_bandwidth,       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 11 } }
fields[#fields + 1] = { t = localization.p_bandwidth,       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 12 } }
fields[#fields + 1] = { t = localization.y_bandwidth,       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 13 } }
fields[#fields + 1] = { t = localization.r_d_term_cut_off,    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 14 } }
fields[#fields + 1] = { t = localization.p_d_term_cut_off,    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 15 } }
fields[#fields + 1] = { t = localization.y_d_term_cut_off,    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 16 } }
fields[#fields + 1] = { t = localization.r_b_term_cut_off,    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 39 } }
fields[#fields + 1] = { t = localization.p_b_term_cut_off,    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 40 } }
fields[#fields + 1] = { t = localization.y_b_term_cut_off,    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 41 } }

labels[#labels + 1] = { t = localization.cross_coupling,        x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.gain,                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 34 } }
fields[#fields + 1] = { t = localization.ratio,                 x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 35 } }
fields[#fields + 1] = { t = localization.cutoff,                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 250, vals = { 36 } }

labels[#labels + 1] = { t = localization.acro_trainer,         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.leveling_gain,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 255, vals = { 32 } }
fields[#fields + 1] = { t = localization.maximum_angle,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 80, vals = { 33 } }

labels[#labels + 1] = { t = localization.angle_mode,           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.leveling_gain,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 29 } }
fields[#fields + 1] = { t = localization.maximum_angle,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 90, vals = { 30 } }

labels[#labels + 1] = { t = localization.horizon_mode,         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = localization.leveling_gain,        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 31 } }

return {
    read        = 94, -- MSP_PID_PROFILE
    write       = 95, -- MSP_SET_PID_PROFILE
    title       = localization.profile,
    reboot      = false,
    eepromWrite = true,
    minBytes    = 41,
    labels      = labels,
    fields      = fields,
}
