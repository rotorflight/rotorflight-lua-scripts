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
local batteries = 6
local mspSetProfile = assert(rf2.loadScript("MSP/mspSetProfile.lua"))()
local mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))()
local editing = false
local profileAdjustmentTS = nil

local startEditing = function(field, page)
    editing = true
end

local endPidEditing = function(field, page)
    mspSetProfile.setBatteryProfile(field.data.value, function() rf2.reloadPage() end, nil)
end

fields[1] = { t = "Current Profile",        x = x,          y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endPidEditing }

y = inc.y(lineSpacing)
labels[#labels + 1] = { t = "Battery",  x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "Capacity",  x = x + tableSpacing.col, y = y }
labels[#labels + 1] = { t = "CellCount",  x = x + 2 * tableSpacing.col, y = y }

labels[#labels + 1] = { t = tostring(1),  x = x, y = inc.y(lineSpacing) }
fields[#fields + 1] = { x = x + tableSpacing.col, y = y, min = 0, max = 20000, vals = { 1, 2 } }
fields[#fields + 1] = { x = x + 2 * tableSpacing.col, y = y, min = 0, max = 24, vals = { 3 } }
for i=1, batteries - 1 do
    labels[#labels + 1] = { t = tostring(i + 1),  x = x, y = inc.y(lineSpacing) }
    fields[#fields + 1] = { x = x + tableSpacing.col, y = y, min = 0, max = 20000, vals = { 15 + (i - 1) * 3 + 1, 15 + (i - 1) * 3 + 2 } }
    fields[#fields + 1] = { x = x + 2 * tableSpacing.col, y = y, min = 0, max = 24, vals = { 15 + (i - 1) * 3 + 3 } }
end

return {
    read =  32, -- MSP_BATTERY_CONFIG
    write = 33, -- MSP_SET_BATTERY_CONFIG
    title       = "Battery Config",
    minBytes    = 30,
    eepromWrite = true,
    labels      = labels,
    fields      = fields,
    simulatorResponse = { 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 0, 3, 5, 0, 4, 6, 0, 5, 8, 0, 0, 12 },

    postLoad = function(self)
        mspStatus.getStatus(self.onProcessedMspStatus, self)
    end,

    timer = function(self)
        if profileAdjustmentTS and rf2.clock() - profileAdjustmentTS > 0.35 then
            rf2.reloadPage()
        elseif rf2.mspQueue:isProcessed() and not editing then
            mspStatus.getStatus(self.onProcessedMspStatus, self)
        end
    end,

    onProcessedMspStatus = function(self, status)
        local currentField = self.fields[1]
        if currentField.data.value ~= status.batteryProfile and not editing then
            if currentField.data.value then
                profileAdjustmentTS = rf2.clock()
            end
            currentField.data.value = status.batteryProfile
        end

        rf2.lcdNeedsInvalidate = true
        self.isReady = true
    end,
}
