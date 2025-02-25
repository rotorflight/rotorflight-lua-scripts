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

local function copyProfile(field, page)
    local source = page.fields[16].data.value
    local dest = page.fields[17].data.value
    if source == dest then return end

    local mspCopyProfile = {
        command = 183, -- MSP_COPY_PROFILE
        payload = { 0, dest, source } -- 0 = copy pids
    }

    rf2.mspQueue:add(mspCopyProfile)
    rf2.settingsSaved()
end

x = margin
local tableStartY = yMinLim - lineSpacing
y = tableStartY
labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Roll",  x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Pitch", x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "Yaw",   x = x, y = inc.y(tableSpacing.row) }

x = x + tableSpacing.col
y = tableStartY
labels[#labels + 1] = { t = "P",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 1,2 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 9,10 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 17,18 } }

x = x + colSpacing
y = tableStartY
labels[#labels + 1] = { t = "I",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 3,4 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 11,12 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 19,20 } }

x = x + colSpacing
y = tableStartY
labels[#labels + 1] = { t = "D",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 5,6 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 13,14 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 21,22 } }

x = x + colSpacing
y = tableStartY
labels[#labels + 1] = { t = "FF",    x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 7,8 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 15,16 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 23,24 } }

x = x + colSpacing
y = tableStartY
labels[#labels + 1] = { t = "B",     x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 25,26 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 27,28 } }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 1000, vals = { 29,30 } }

x = margin
inc.y(lineSpacing * 0.5)
fields[16] = { t = "Current PID profile",             x = x,          y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endPidEditing }
fields[17] = { t = "Destination profile",             x = x,          y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } } }
fields[#fields + 1] = { t = "[Copy Current to Dest]", x = x + indent, y = inc.y(lineSpacing), preEdit = copyProfile }

inc.y(lineSpacing * 0.5)
labels[#labels + 1] = { t = "HSI Offset Gain",        x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 31,32 } }
fields[#fields + 1] = { t = "Pitch",                  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 33,34 } }

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
        if profileAdjustmentTS and rf2.clock() - profileAdjustmentTS > 0.35 then
            rf2.reloadPage()
        elseif rf2.mspQueue:isProcessed() and not editing then
            mspStatus.getStatus(self.onProcessedMspStatus, self)
        end
    end,

    onProcessedMspStatus = function(self, status)
        local currentField = self.fields[16]
        if currentField.data.value ~= status.profile and not editing then
            if currentField.data.value then
                profileAdjustmentTS = rf2.clock()
            end
            currentField.data.value = status.profile
        end

        local destField = self.fields[17]
        if not destField.data.value then
            if status.profile < 5 then
                destField.data.value = status.profile + 1
            else
                destField.data.value = 4
            end
        end

        rf2.lcdNeedsInvalidate = true
        self.isReady = true
    end,
}
