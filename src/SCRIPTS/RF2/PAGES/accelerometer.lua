local template = assert(rf2.loadScript(rf2.radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
template = nil
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local mspAccTrim = "mspAccTrim"
local data = rf2.useApi(mspAccTrim).getDefaults()

labels[#labels + 1] = { t = "Accelerometer Trim", x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Roll",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = data.roll_trim }
fields[#fields + 1] = { t = "Pitch",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = data.pitch_trim }

local function receivedData(page)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi(mspAccTrim).read(receivedData, self, data)
    end,
    write = function(self)
        rf2.useApi(mspAccTrim).write(data)
        rf2.settingsSaved()
    end,
    eepromWrite = true,
    reboot      = false,
    title       = "Accelerometer",
    labels      = labels,
    fields      = fields
}
