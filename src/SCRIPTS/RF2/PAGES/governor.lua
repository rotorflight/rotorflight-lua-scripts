local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local governorConfig = rf2.useApi("mspGovernorConfig").getDefaults()

x = margin
y = yMinLim - tableSpacing.header

fields[#fields + 1] = { t = "Mode",                         x = x, y = incY(lineSpacing), w = 150, sp = x + sp, data = governorConfig.gov_mode }
if rf2.apiVersion >= 12.09 then
    fields[#fields + 1] = { t = "Autorotation TO",          x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_autorotation_timeout }
    fields[#fields + 1] = { t = "Throttle hold TO",         x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_throttle_hold_timeout }
    incY(lineSpacing * 0.5)
    labels[#labels + 1] = { t = "Throttle",                 x = x, y = incY(lineSpacing) }
    fields[#fields + 1] = { t = "Throttle type",            x = x, y = incY(lineSpacing), w = 150, sp = x + sp, data = governorConfig.gov_throttle_type }
    fields[#fields + 1] = { t = "Idle throttle",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_idle_throttle }
    fields[#fields + 1] = { t = "Auto throttle",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_auto_throttle }
    fields[#fields + 1] = { t = "Handover throttle",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_handover_throttle }
    incY(lineSpacing * 0.5)
    labels[#labels + 1] = { t = "Motor Ramp",               x = x, y = incY(lineSpacing) }
    fields[#fields + 1] = { t = "Startup time",             x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_startup_time }
    fields[#fields + 1] = { t = "Spoolup time",             x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_spoolup_time }
    fields[#fields + 1] = { t = "Spooldown time",           x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_spooldown_time }
    fields[#fields + 1] = { t = "Tracking time",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_tracking_time }
    fields[#fields + 1] = { t = "Recovery time",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_recovery_time }
    incY(lineSpacing * 0.5)
    labels[#labels + 1] = { t = "Filters",                  x = x, y = incY(lineSpacing) }
    fields[#fields + 1] = { t = "Headspeed cutoff",         x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_rpm_filter }
    fields[#fields + 1] = { t = "Battery volt. cutoff",     x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_pwr_filter }
    fields[#fields + 1] = { t = "TTA bandwidth",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_tta_filter }
    fields[#fields + 1] = { t = "Precomp bandwidth",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_ff_filter }
    fields[#fields + 1] = { t = "D-term cutoff",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_d_filter }
else -- < 12.09
    fields[#fields + 1] = { t = "Handover throttle",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_handover_throttle }
    fields[#fields + 1] = { t = "Startup time",             x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_startup_time }
    fields[#fields + 1] = { t = "Spoolup time",             x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_spoolup_time }
    if rf2.apiVersion >= 12.08 then
        fields[#fields + 1] = { t = "Spoolup min throt.",   x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_spoolup_min_throttle }
    end
    fields[#fields + 1] = { t = "Tracking time",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_tracking_time }
    fields[#fields + 1] = { t = "Recovery time",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_recovery_time }
    fields[#fields + 1] = { t = "AR bailout time",          x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_autorotation_bailout_time }
    fields[#fields + 1] = { t = "AR timeout",               x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_autorotation_timeout }
    fields[#fields + 1] = { t = "AR min entry time",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_autorotation_min_entry_time }
    fields[#fields + 1] = { t = "Zero throttle TO",         x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_throttle_hold_timeout }
    fields[#fields + 1] = { t = "HS signal timeout",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_lost_headspeed_timeout }
    fields[#fields + 1] = { t = "HS filter cutoff",         x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_rpm_filter }
    fields[#fields + 1] = { t = "Volt. filter cutoff",      x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_pwr_filter }
    fields[#fields + 1] = { t = "TTA bandwidth",            x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_tta_filter }
    fields[#fields + 1] = { t = "Precomp bandwidth",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_ff_filter }
end

local function receivedGovernorConfig(page, _)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi("mspGovernorConfig").read(receivedGovernorConfig, self, governorConfig)
    end,
    write = function(self)
        rf2.useApi("mspGovernorConfig").write(governorConfig)
        rf2.settingsSaved(true, true)
    end,
    title       = "Governor",
    labels      = labels,
    fields      = fields
}
