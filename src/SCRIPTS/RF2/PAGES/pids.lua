local template = assert(rf2.loadScript(rf2.radio.template))()
local mspSetProfile = assert(rf2.loadScript("MSP/mspSetProfile.lua"))()
local mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local colSpacing = tableSpacing.col * 0.65
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}
local editing = false
local profileAdjustmentTS = nil

local startEditing = function(field, page)
    editing = true
end

local endPidEditing = function(field, page)
    mspSetProfile.setPidProfile(field.data.value, function() rf2.reloadPage() end, nil)
end

fields[#fields + 1] = { t = "Current PID profile", x = x, y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endPidEditing }

x = margin
y = yMinLim + lineSpacing * 0.2
labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Roll",  x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Pitch", x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Yaw",   x = x, y = inc.y(tableSpacing.row) }

x = x + tableSpacing.firstCol
y = yMinLim + lineSpacing * 0.25
labels[#labels + 1] = { t = "P",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 1,2 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 9,10 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 17,18 } }

x = x + colSpacing
y = yMinLim + lineSpacing * 0.25
labels[#labels + 1] = { t = "I",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 3,4 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 11,12 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 19,20 } }

x = x + colSpacing
y = yMinLim + lineSpacing * 0.25
labels[#labels + 1] = { t = "D",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 5,6 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 13,14 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 21,22 } }

x = x + colSpacing
y = yMinLim + lineSpacing * 0.25
labels[#labels + 1] = { t = "FF",    x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 7,8 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 15,16 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 23,24 } }


-- ------------------ advance ---------------------------------------------------------------------
x = margin
inc.y(lineSpacing*1.5)
labels[#labels + 1] = { t = "Advance",       x = x,          y = inc.y(lineSpacing) }

local y2 = y
y = y2
labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Roll",  x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Pitch", x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Yaw",   x = x, y = inc.y(tableSpacing.row) }

x = x + tableSpacing.firstCol
y = y2
labels[#labels + 1] = { t = "B",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 25,26 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 27,28 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 29,30 } }

x = x + colSpacing
y = y2
labels[#labels + 1] = { t = "Offset", x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {               x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 31,32 } }
fields[#fields + 1] = {               x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 33,34 } }


return {
    read        = 112, -- MSP_PID_TUNING
    write       = 202, -- MSP_SET_PID_TUNING
    title       = "PIDs",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 34,
    labels      = labels,
    fields      = fields,
    simulatorResponse = {70, 0, 225, 0, 90, 0, 120, 0, 100, 0, 200, 0, 70, 0, 120, 0, 100, 0, 125, 0, 83, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 0, 25, 0 },
    postLoad = function(self)
        mspStatus.getStatus(self.onProcessedMspStatus, self)
    end,
    timer = function(self)
        if profileAdjustmentTS and rf2.clock() - profileAdjustmentTS > 0.5 then
            rf2.reloadPage()
        elseif rf2.mspQueue:isProcessed() and not editing then
            mspStatus.getStatus(self.onProcessedMspStatus, self)
        end
    end,
    onProcessedMspStatus = function(self, status)
        if fields[1].data.value ~= status.profile and not editing then
            if fields[1].data.value then
                profileAdjustmentTS = rf2.clock()
            end
            fields[1].data.value = status.profile
        end
        self.isReady = true
    end,
}
