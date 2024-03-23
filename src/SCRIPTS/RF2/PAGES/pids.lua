local template = assert(loadScript(radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local colSpacing = tableSpacing.col * 0.65
local sp = template.listSpacing.field
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

x = margin
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "",               x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Ro", t2="Roll",  x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Pi", t2="Pitch", x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Ya", t2="yaw",   x = x, y = inc.y(tableSpacing.row) }

local ident_factor = (LCD_W<480) and 0.5 or 0.8
x = x + tableSpacing.col * ident_factor
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "P",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 1,2 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 9,10 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 17,18 } }

x = x + colSpacing
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "I",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 3,4 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 11,12 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 19,20 } }

x = x + colSpacing
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "O",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 31,32 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 33,34 } }

x = x + colSpacing
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "D",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 5,6 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 13,14 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 21,22 } }

x = x + colSpacing
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "F",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 7,8 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 15,16 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 23,24 } }

x = x + colSpacing
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "B",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 25,26 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 27,28 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 29,30 } }

return {
    read        = 112, -- MSP_PID_TUNING
    write       = 202, -- MSP_SET_PID_TUNING
    title       = "PIDs",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 34,
    labels      = labels,
    fields      = fields,
}
