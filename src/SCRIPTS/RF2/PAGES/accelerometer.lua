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
local mspAccTrim = rf2.useApi("mspAccTrim")
local accTrimData = mspAccTrim.getDefaults()

labels[#labels + 1] = { t = "Accelerometer Trim", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = accTrimData.roll_trim }
fields[#fields + 1] = { t = "Pitch",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = accTrimData.pitch_trim }

local function receivedGovernorProfile(page)
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspAccTrim.read(accTrimData, receivedGovernorProfile, self)
    end,
    write = function(self)
        mspAccTrim.write(accTrimData)
        rf2.settingsSaved()
    end,
    eepromWrite = true,
    reboot      = false,
    title       = "Accelerometer",
    labels      = labels,
    fields      = fields
}
