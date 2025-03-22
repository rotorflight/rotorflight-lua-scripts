local template = assert(rf2.loadScript(rf2.radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
template = nil
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local profileSwitcher = assert(rf2.loadScript("PAGES/helpers/profileSwitcher.lua"))()
local pidProfile = rf2.useApi("mspPidProfile").getDefaults()
collectgarbage()

fields[#fields + 1] = { t = "Current PID profile",     x = x,          y = incY(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = profileSwitcher.startPidEditing, postEdit = profileSwitcher.endPidEditing }

incY(lineSpacing * 0.25)
fields[#fields + 1] = { t = "I-term relax type",       x = x,          y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_type }
fields[#fields + 1] = { t = "Cutoff point R",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_cutoff_roll }
fields[#fields + 1] = { t = "Cutoff point P",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_cutoff_pitch }
fields[#fields + 1] = { t = "Cutoff point Y",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_cutoff_yaw }
-- TODO? toggle 'I-term limits', off = 1000

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Main Rotor",              x = x,            y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Coll to pitch gain",      x = x + indent,   y = incY(lineSpacing), sp = x + sp, data = pidProfile.pitch_collective_ff_gain }
labels[#labels + 1] = { t = "Cross-Coupling",          x = x + indent,   y = incY(lineSpacing), bold = false }
fields[#fields + 1] = { t = "Gain",                    x = x + indent*2, y = incY(lineSpacing), sp = x + sp, data = pidProfile.cyclic_cross_coupling_gain }
fields[#fields + 1] = { t = "Ratio",                   x = x + indent*2, y = incY(lineSpacing), sp = x + sp, data = pidProfile.cyclic_cross_coupling_ratio }
fields[#fields + 1] = { t = "Cutoff",                  x = x + indent*2, y = incY(lineSpacing), sp = x + sp, data = pidProfile.cyclic_cross_coupling_cutoff }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Tail Rotor",              x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "CW stop gain",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_cw_stop_gain }
fields[#fields + 1] = { t = "CCW stop gain",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_ccw_stop_gain }
fields[#fields + 1] = { t = "Precomp cutoff",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_precomp_cutoff }
fields[#fields + 1] = { t = "Cyclic FF gain",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_cyclic_ff_gain }
fields[#fields + 1] = { t = "Coll FF gain",            x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_collective_ff_gain }
if rf2.apiVersion >= 12.08 then
    fields[#fields + 1] = { t = "Inertia gain",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_inertia_precomp_gain }
    fields[#fields + 1] = { t = "Inertia cutoff",      x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_inertia_precomp_cutoff }
else
    fields[#fields + 1] = { t = "Coll imp FF gain",    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_collective_dynamic_gain }
    fields[#fields + 1] = { t = "Coll imp FF decay",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.yaw_collective_dynamic_decay }
end

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Acro Trainer",            x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.angle_level_strength }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.angle_level_limit }
labels[#labels + 1] = { t = "Angle Mode",              x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.angle_level_strength }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.angle_level_limit }
labels[#labels + 1] = { t = "Horizon Mode",            x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.horizon_level_strength }

incY(lineSpacing * 0.25)
fields[#fields + 1] = { t = "Piro compensation",       x = x,          y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_rotation }
labels[#labels + 1] = { t = "Error Decay Ground",      x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Time",                    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_decay_time_ground }
labels[#labels + 1] = { t = "Error Decay Cyclic",      x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Time",                    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_decay_time_cyclic }
fields[#fields + 1] = { t = "Limit",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_decay_limit_cyclic }
labels[#labels + 1] = { t = "Error Decay Yaw",         x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Time",                    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_decay_time_yaw }
fields[#fields + 1] = { t = "Limit",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_decay_limit_yaw }
labels[#labels + 1] = { t = "Error Limit",             x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Roll",                    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_limit_roll }
fields[#fields + 1] = { t = "Pitch",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_limit_pitch }
fields[#fields + 1] = { t = "Yaw",                     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_limit_yaw }
labels[#labels + 1] = { t = "HSI Offset Limit",        x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Roll",                    x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.offset_limit_roll }
fields[#fields + 1] = { t = "Pitch",                   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.offset_limit_pitch }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "PID Controller",          x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "R bandwidth",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.gyro_cutoff_roll }
fields[#fields + 1] = { t = "P bandwidth",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.gyro_cutoff_pitch }
fields[#fields + 1] = { t = "Y bandwidth",             x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.gyro_cutoff_yaw }
fields[#fields + 1] = { t = "R D-term cutoff",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.dterm_cutoff_roll }
fields[#fields + 1] = { t = "P D-term cutoff",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.dterm_cutoff_pitch }
fields[#fields + 1] = { t = "Y D-term cutoff",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.dterm_cutoff_yaw }
fields[#fields + 1] = { t = "R B-term cutoff",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.bterm_cutoff_roll }
fields[#fields + 1] = { t = "P B-term cutoff",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.bterm_cutoff_pitch }
fields[#fields + 1] = { t = "Y B-term cutoff",         x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.bterm_cutoff_yaw }

local function receivedPidProfile(page, _)
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        rf2.useApi("mspPidProfile").read(receivedPidProfile, self, pidProfile)
    end,
    write = function(self)
        rf2.useApi("mspPidProfile").write(pidProfile)
        rf2.settingsSaved()
    end,
    title       = "Profile - Various",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields,
    profileSwitcher = profileSwitcher,

    postLoad = function(self)
        self.profileSwitcher.getStatus(self)
    end,

    timer = function(self)
        self.profileSwitcher.checkStatus(self)
    end,
}
