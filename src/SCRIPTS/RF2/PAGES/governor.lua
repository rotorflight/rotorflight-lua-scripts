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

fields[#fields + 1] = { t = "Mode",                x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4,     vals = { 1 }, table = { [0]="OFF", "PASSTHROUGH", "STANDARD", "MODE1", "MODE2" }, id="govMode" }
fields[#fields + 1] = { t = "Handover throttle%",  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 50,   vals = { 20 },                 id="govHandoverThrottle" }
fields[#fields + 1] = { t = "Startup time",        x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 2,3 }, scale = 10,    id="govStartupTime" }
fields[#fields + 1] = { t = "Spoolup time",        x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 4,5 }, scale = 10,    id="govSpoolupTime" }
fields[#fields + 1] = { t = "Tracking time",       x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 6,7 }, scale = 10,    id="govTrackingTime" }
fields[#fields + 1] = { t = "Recovery time",       x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 8,9 }, scale = 10,    id="govRecoveryTime" }
fields[#fields + 1] = { t = "AR bailout time",     x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 16,17 }, scale = 10,  id="govAutoBailoutTime" }
fields[#fields + 1] = { t = "AR timeout",          x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 14,15 }, scale = 10,  id="govAutoTimeout" }
fields[#fields + 1] = { t = "AR min entry time",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 18,19 }, scale = 10,  id="govAutoMinEntryTime" }
fields[#fields + 1] = { t = "Zero throttle TO",    x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 10,11 }, scale = 10,  id="govZeroThrottleTimeout" }
fields[#fields + 1] = { t = "HS signal timeout",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 12,13 }, scale = 10,  id="govLostHeadspeedTimeout" }
fields[#fields + 1] = { t = "HS filter cutoff",    x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 22 },                 id="govHeadspeedFilterHz" }
fields[#fields + 1] = { t = "Volt. filter cutoff", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 21 },                 id="govVoltageFilterHz" }
fields[#fields + 1] = { t = "TTA bandwidth",       x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 23 },                 id="govTTAFilterHz" }
fields[#fields + 1] = { t = "Precomp bandwidth",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 24 },                 id="govFFFilterHz" }

return {
    read        = 142, -- MSP_GOVERNOR_CONFIG
    write       = 143, -- MSP_SET_GOVERNOR_CONFIG
    title       = "Governor",
    reboot      = true,
    eepromWrite = true,
    minBytes    = 24,
    labels      = labels,
    fields      = fields,
}
