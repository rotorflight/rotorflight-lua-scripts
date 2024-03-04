local localization = require('localization.' .. locale)

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

-- TODO can i use a global variable for strings?

labels[#labels + 1] = { t = strings.accelerometer_trim,     x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -300, max = 300, vals = { 3, 4 } }
fields[#fields + 1] = { t = "Pitch",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -300, max = 300, vals = { 1, 2 } }

return {
    read        = 240, -- MSP_ACC_TRIM
    write       = 239, -- MSP_SET_ACC_TRIM
    eepromWrite = true,
    reboot      = false,
    title       = "Accelerometer",
    minBytes    = 4,
    labels      = labels,
    fields      = fields,
}
