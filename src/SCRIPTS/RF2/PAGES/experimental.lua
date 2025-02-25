local template = assert(rf2.loadScript(rf2.radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}
local total_bytes = 16

x = margin
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "Byte",  x = x, y = inc.y(lineSpacing) }
for i=0, total_bytes - 1 do
    labels[#labels + 1] = { t = tostring(i),  x = x, y = inc.y(lineSpacing) }
end

-- Draw uint8 fields
x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "UINT8",  x = x, y = inc.y(lineSpacing) }
for i=0, total_bytes - 1 do
    fields[#fields + 1] = { x = x, y = inc.y(lineSpacing), min = 0, max = 255, vals = { i + 1 } }
end

-- Draw int8 fields
x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "INT8",  x = x, y = inc.y(lineSpacing) }
for i=0, total_bytes - 1 do
    fields[#fields + 1] = { x = x, y = inc.y(lineSpacing), min = -128, max = 127, vals = { i + 1 } }
end

return {
    read =  158, -- MSP_EXPERIMENTAL
    write = 159, -- MSP_SET_EXPERIMENTAL
    title       = "Experimental",
    minBytes    = 0,
    eepromWrite = true,
    labels      = labels,
    fields      = fields
}
