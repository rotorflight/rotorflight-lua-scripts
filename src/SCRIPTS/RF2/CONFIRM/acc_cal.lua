local template = rf2.executeScript(rf2.radio.template)
local lineSpacing = template.lineSpacing
local yMinLim = rf2.radio.yMinLimit
local x = template.margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

labels[#labels + 1] = { t = "Make sure the craft is level", x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "and stable, then press",       x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "[ENTER] to calibrate, or",     x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "[EXIT] to cancel.",            x = x, y = inc.y(lineSpacing) }
fields[#fields + 1] = { x = x, y = inc.y(lineSpacing), value = "", readOnly = true }

return {
    title  = "Accelerometer",
    labels = labels,
    fields = fields,
    init   = rf2.executeScript("acc_cal"),
}
