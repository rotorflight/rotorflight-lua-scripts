local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local sp = template.listSpacing.field
template = nil
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local rateSwitcher = rf2.executeScript("PAGES/helpers/rateSwitcher.lua")
local rcTuning = rf2.useApi("mspRcTuning").getDefaults()
collectgarbage()

local tableStartY = yMinLim - lineSpacing
y = tableStartY
labels = {}
fields = {}

fields[#fields + 1] = { t = "Current rate profile", x = x, y = incY(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = rateSwitcher.startPidEditing, postEdit = rateSwitcher.endPidEditing }
incY(lineSpacing * 0.5)

local responseTime = "Response time"
local maxAcceleration = "Max acceleration"
local setpointBoostGain = "Setp boost gain"
local setpointBoostCutoff = "Setp boost cutoff"

labels[#labels + 1] = { t = "Roll Dynamics",       x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = responseTime,          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.roll_response_time }
fields[#fields + 1] = { t = maxAcceleration,       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.roll_accel_limit }
if rf2.apiVersion >= 12.08 then
    fields[#fields + 1] = { t = setpointBoostGain,     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.roll_setpoint_boost_gain }
    fields[#fields + 1] = { t = setpointBoostCutoff,   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.roll_setpoint_boost_cutoff }
end

labels[#labels + 1] = { t = "Pitch Dynamics",      x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = responseTime,          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.pitch_response_time }
fields[#fields + 1] = { t = maxAcceleration,       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.pitch_accel_limit }
if rf2.apiVersion >= 12.08 then
    fields[#fields + 1] = { t = setpointBoostGain,     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.pitch_setpoint_boost_gain }
    fields[#fields + 1] = { t = setpointBoostCutoff,   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.pitch_setpoint_boost_cutoff }
end

labels[#labels + 1] = { t = "Yaw Dynamics",        x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = responseTime,          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.yaw_response_time }
fields[#fields + 1] = { t = maxAcceleration,       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.yaw_accel_limit }
if rf2.apiVersion >= 12.08 then
    fields[#fields + 1] = { t = setpointBoostGain,     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.yaw_setpoint_boost_gain }
    fields[#fields + 1] = { t = setpointBoostCutoff,   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.yaw_setpoint_boost_cutoff }
end

labels[#labels + 1] = { t = "Collective Dynamics", x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = responseTime,          x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.collective_response_time }
fields[#fields + 1] = { t = maxAcceleration,       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.collective_accel_limit }
if rf2.apiVersion >= 12.08 then
    fields[#fields + 1] = { t = setpointBoostGain,     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.collective_setpoint_boost_gain }
    fields[#fields + 1] = { t = setpointBoostCutoff,   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.collective_setpoint_boost_cutoff }
end

if rf2.apiVersion >= 12.08 then
    incY(lineSpacing * 0.5)
    labels[#labels + 1] = { t = "Dynamic",             x = x,          y = incY(lineSpacing) }
    fields[#fields + 1] = { t = "Ceiling gain",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.yaw_dynamic_ceiling_gain }
    fields[#fields + 1] = { t = "Deadband gain",       x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.yaw_dynamic_deadband_gain }
    fields[#fields + 1] = { t = "Deadband filter",     x = x + indent, y = incY(lineSpacing), sp = x + sp, data = rcTuning.yaw_dynamic_deadband_filter }
end

local function receivedRcTuning(page)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        self.rateSwitcher.getStatus(self)
        rf2.useApi("mspRcTuning").read(receivedRcTuning, self, rcTuning)
    end,
    write = function(self)
        rf2.useApi("mspRcTuning").write(rcTuning)
        rf2.settingsSaved(true, false)
    end,
    title       = "Rate Dynamics",
    labels      = labels,
    fields      = fields,
    rateSwitcher = rateSwitcher,

    timer = function(self)
        self.rateSwitcher.checkStatus(self)
    end
}
