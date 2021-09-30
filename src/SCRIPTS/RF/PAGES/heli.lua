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

    labels[#labels + 1] = { t = "Yaw Collective FF", x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Gain",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2000, vals = { 1,2 } }
    fields[#fields + 1] = { t = "Impulse Gain",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2000, vals = { 3,4 } }
    fields[#fields + 1] = { t = "Impulse Freq",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 5,6 } }
    labels[#labels + 1] = { t = "Yaw Cyclic  FF",    x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Gain",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 7,8 } }
end

return {
    read        = 140, -- MSP_HELI_CONFIG
    write       = 141, -- MSP_SET_HELI_CONFIG
    title       = "Heli",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 8,
    labels      = labels,
    fields      = fields,
}
