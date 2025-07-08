local template = rf2.executeScript(rf2.radio.template)
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
local profileSwitcher = rf2.executeScript("PAGES/helpers/profileSwitcher.lua")
local pidProfile = rf2.useApi("mspPidProfile").getDefaults()
collectgarbage()

fields[#fields + 1] = { t = "Current PID profile",     x = x,          y = incY(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = profileSwitcher.startPidEditing, postEdit = profileSwitcher.endPidEditing }

incY(lineSpacing * 0.25)
fields[#fields + 1] = { t = "Piro compensation",       x = x,          y = incY(lineSpacing), sp = x + sp, data = pidProfile.error_rotation }
fields[#fields + 1] = { t = "I-term relax type",       x = x,          y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_type }
fields[#fields + 1] = { t = "Cutoff point R",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_cutoff_roll }
fields[#fields + 1] = { t = "Cutoff point P",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_cutoff_pitch }
fields[#fields + 1] = { t = "Cutoff point Y",          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = pidProfile.iterm_relax_cutoff_yaw }
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
    rf2.onPageReady(page)
end

return {
    read = function(self)
        self.profileSwitcher.getStatus(self)
        rf2.useApi("mspPidProfile").read(receivedPidProfile, self, pidProfile)
    end,
    write = function(self)
        rf2.useApi("mspPidProfile").write(pidProfile)
        rf2.settingsSaved(true, false)
    end,
    title       = "PID Controller Settings",
    labels      = labels,
    fields      = fields,
    profileSwitcher = profileSwitcher,

    timer = function(self)
        self.profileSwitcher.checkStatus(self)
    end,
}
