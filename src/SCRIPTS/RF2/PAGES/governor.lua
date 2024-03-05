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

x = margin
y = yMinLim - tableSpacing.header

fields[#fields + 1] = { t = localization.mode,               x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4,     vals = { 1 }, table = { [0]="OFF", "PASSTHROUGH", "STANDARD", "MODE1", "MODE2" } }
fields[#fields + 1] = { t = localization.handover_throttle,  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 50,   vals = { 20 } }
fields[#fields + 1] = { t = localization.startup_time,       x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 2,3 }, scale = 10 }
fields[#fields + 1] = { t = localization.spoolup_time,       x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 4,5 }, scale = 10 }
fields[#fields + 1] = { t = localization.tracking_time,      x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 6,7 }, scale = 10 }
fields[#fields + 1] = { t = localization.recovery_time,      x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 8,9 }, scale = 10 }
fields[#fields + 1] = { t = localization.ar_bailout_time,    x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 16,17 }, scale = 10 }
fields[#fields + 1] = { t = localization.ar_timeout,         x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 14,15 }, scale = 10 }
fields[#fields + 1] = { t = localization.ar_min_entry_time,  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 18,19 }, scale = 10 }
fields[#fields + 1] = { t = localization.zero_throttle_to,   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 10,11 }, scale = 10 }
fields[#fields + 1] = { t = localization.hs_signal_timeout,  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 12,13 }, scale = 10 }
fields[#fields + 1] = { t = localization.hs_filter_cutoff,   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 22 } }
fields[#fields + 1] = { t = localization.volt_filter_cutoff, x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 21 } }
fields[#fields + 1] = { t = localization.tta_bandwidth,      x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 23 } }
fields[#fields + 1] = { t = localization.precomp_bandwidth,  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 24 } }

return {
    read        = 142, -- MSP_GOVERNOR_CONFIG
    write       = 143, -- MSP_SET_GOVERNOR_CONFIG
    title       = localization.governor,
    reboot      = true,
    eepromWrite = true,
    minBytes    = 24,
    labels      = labels,
    fields      = fields,
}
