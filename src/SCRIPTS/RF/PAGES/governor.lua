local template = loadScript(radio.templateHome.."heli.lua")
if template then
    template = template()
else
    template = assert(loadScript(radio.templateHome.."default_template.lua"))()
end
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

if apiVersion >= 1.043 then
    x = margin
    y = yMinLim - tableSpacing.header

    fields[#fields + 1] = { t = "Mode",              x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4,  vals = { 1 }, table = { [0]="OFF", "PASSTHROUGH", "STANDARD", "MODE1", "MODE2" } }
    fields[#fields + 1] = { t = "Max Headspeed",     x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 2,3 }, mult = 10 }
    fields[#fields + 1] = { t = "Spoolup Time",      x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 600,   vals = { 4,5 }, scale = 10 }
    fields[#fields + 1] = { t = "Tracking Time",     x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 6,7 }, scale = 10 }
    fields[#fields + 1] = { t = "Recovery Time",     x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 8,9 }, scale = 10 }
    fields[#fields + 1] = { t = "AR Timeout",        x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 10,11 }, scale = 10 }
    fields[#fields + 1] = { t = "AR Bailout Time",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 12,13 }, scale = 10 }
    fields[#fields + 1] = { t = "AR Min Entry Time", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 14,15 } }
    fields[#fields + 1] = { t = "Lost Throttle TO",  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 16,17 }, scale = 10 }
    fields[#fields + 1] = { t = "Lost Headspeed TO", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100,   vals = { 18,19 }, scale = 10 }
    fields[#fields + 1] = { t = "Gear Ratio",        x = x, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 30000,   vals = { 20,21 }, scale = 1000 }
    fields[#fields + 1] = { t = "Power Filter",      x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,   vals = { 22,23 } }
    fields[#fields + 1] = { t = "RPM Filter",        x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,   vals = { 24,25 } }
    fields[#fields + 1] = { t = "Gain",              x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500,   vals = { 26,27 } }
    fields[#fields + 1] = { t = "P Gain",            x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500,   vals = { 28,29 } }
    fields[#fields + 1] = { t = "I Gain",            x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500,   vals = { 30,31 } }
    fields[#fields + 1] = { t = "D Gain",            x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500,   vals = { 32,33 } }
    fields[#fields + 1] = { t = "F Gain",            x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500,   vals = { 34,35 } }
    fields[#fields + 1] = { t = "Cyclic FF Weight",  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500,   vals = { 36,37 } }
    fields[#fields + 1] = { t = "Coll. FF Weight",   x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500,   vals = { 38,39 } }
end

return {
    read        = 142, -- MSP_GOVERNOR
    write       = 143, -- MSP_SET_GOVERNOR
    title       = "Governor",
    reboot      = true,
    eepromWrite = true,
    minBytes    = 39,
    labels      = labels,
    fields      = fields,
}
