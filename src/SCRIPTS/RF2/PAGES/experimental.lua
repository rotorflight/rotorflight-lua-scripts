local template = assert(rf2.loadScript(rf2.radio.template))()
local margin = template.margin
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local mspExperimental = rf2.useApi("mspExperimental")
local experimental = mspExperimental.getDefaults()
local total_bytes = 16

x = margin
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "Byte",  x = x, y = incY(lineSpacing) }
for i = 1, total_bytes do
    labels[#labels + 1] = { t = tostring(i),  x = x, y = incY(lineSpacing) }
end

-- Draw uint8 fields
x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "UINT8",  x = x, y = incY(lineSpacing) }
for i= 1, total_bytes do
    fields[#fields + 1] = { x = x, y = incY(lineSpacing), data = experimental[i] }
end

-- Draw int8 fields: not supported anymore since data can't have multiple representations

local function receivedExperimental(page)
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspExperimental.read(receivedExperimental, self, experimental)
    end,
    write = function(self)
        mspExperimental.write(experimental)
        rf2.settingsSaved()
    end,
    title       = "Experimental",
    eepromWrite = true,
    labels      = labels,
    fields      = fields
}
