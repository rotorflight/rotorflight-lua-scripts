local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local batteryConfig = rf2.useApi("mspBatteryConfig").getDefaults()

labels[#labels + 1] = { t = "Battery",                  x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Voltage Source",           x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.voltageMeterSource }
fields[#fields + 1] = { t = "Current Source",           x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.currentMeterSource }
fields[#fields + 1] = { t = "Cell Count",               x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.batteryCellCount }
fields[#fields + 1] = { t = "Consumption Warning",      x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.consumptionWarningPercentage }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Voltages",                 x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Maximum Cell",             x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.vbatmaxcellvoltage }
fields[#fields + 1] = { t = "Full Cell",                x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.vbatfullcellvoltage }
fields[#fields + 1] = { t = "Warning Cell",             x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.vbatwarningcellvoltage }
fields[#fields + 1] = { t = "Minimum Cell",             x = x,          y = incY(lineSpacing), sp = x + sp, data = batteryConfig.vbatmincellvoltage }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Capacity",                 x = x,          y = incY(lineSpacing) }

if rf2.apiVersion < 12.09 then
    fields[#fields + 1] = { t = "Capacity",             x = x, w = 100, y = incY(lineSpacing), sp = x + sp, data = batteryConfig.batteryCapacity }
else
    for i = 0, 5 do
        fields[#fields + 1] = { t = "Battery " .. tostring(i+1), x = x, w = 100, y = incY(lineSpacing), sp = x + sp, data = batteryConfig.batteryCapacity[i] }
    end
end

local function receivedBatteryConfig(page, _)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi("mspBatteryConfig").read(receivedBatteryConfig, self, batteryConfig)
    end,
    write = function(self)
        if batteryConfig.voltageMeterSource.value then
            rf2.useApi("mspBatteryConfig").write(batteryConfig)
            rf2.settingsSaved(true, true)
        end
    end,
    title       = "Battery",
    labels      = labels,
    fields      = fields,
}
