local template = assert(rf2.loadScript(rf2.radio.template))()
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

fields[#fields + 1] = { t = "Mode",                 x = x, y = incY(lineSpacing), w = 150, sp = x + sp, data = governorConfig.gov_mode,                      id = "govMode" }
fields[#fields + 1] = { t = "Handover throttle",    x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_handover_throttle,         id = "govHandoverThrottle" }
fields[#fields + 1] = { t = "Startup time",         x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_startup_time,              id = "govStartupTime" }
fields[#fields + 1] = { t = "Spoolup time",         x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_spoolup_time,              id = "govSpoolupTime" }
if rf2.apiVersion >= 12.08 then
    fields[#fields + 1] = { t = "Spoolup min throt.", x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_spoolup_min_throttle,    id = "govSpoolupMinimumThrottle" }
end
fields[#fields + 1] = { t = "Tracking time",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_tracking_time,             id = "govTrackingTime" }
fields[#fields + 1] = { t = "Recovery time",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_recovery_time,             id = "govRecoveryTime" }
fields[#fields + 1] = { t = "AR bailout time",      x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_autorotation_bailout_time, id = "govAutoBailoutTime" }
fields[#fields + 1] = { t = "AR timeout",           x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_autorotation_timeout,      id = "govAutoTimeout" }
fields[#fields + 1] = { t = "AR min entry time",    x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_autorotation_min_entry_time, id = "govAutoMinEntryTime" }
fields[#fields + 1] = { t = "Zero throttle TO",     x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_zero_throttle_timeout,     id = "govZeroThrottleTimeout" }
fields[#fields + 1] = { t = "HS signal timeout",    x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_lost_headspeed_timeout,    id = "govLostHeadspeedTimeout" }
fields[#fields + 1] = { t = "HS filter cutoff",     x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_rpm_filter,                id = "govHeadspeedFilterHz" }
fields[#fields + 1] = { t = "Volt. filter cutoff",  x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_pwr_filter,                id = "govVoltageFilterHz" }
fields[#fields + 1] = { t = "TTA bandwidth",        x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_tta_filter,                id = "govTTAFilterHz" }
fields[#fields + 1] = { t = "Precomp bandwidth",    x = x, y = incY(lineSpacing), sp = x + sp, data = governorConfig.gov_ff_filter,                 id = "govFFFilterHz" }

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
