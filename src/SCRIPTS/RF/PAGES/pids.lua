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
labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Ro",     x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Pi",     x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Ya",     x = x, y = inc.y(tableSpacing.row) }

x = x + tableSpacing.col/2
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "P",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 1 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 5 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 9 } }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "I",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 2 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 6 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 10 } }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "D",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 3 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 7 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 11 } }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "F",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 4 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 8 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 250, vals = { 12 } }

return {
    read        = 112, -- MSP_PID
    write       = 202, -- MSP_SET_PID
    title       = "PIDs",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 12,
    labels      = labels,
    fields      = fields,
}
