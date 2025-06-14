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
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.trainer_gain }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.trainer_angle_limit }
labels[#labels + 1] = { t = "Angle Mode",              x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.angle_level_strength }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.angle_level_limit }
labels[#labels + 1] = { t = "Horizon Mode",            x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.horizon_level_strength }

local function receivedPidProfile(page, _)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        self.profileSwitcher.getStatus(self)
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

    timer = function(self)
        self.profileSwitcher.checkStatus(self)
    end,
}
