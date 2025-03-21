local template = assert(rf2.loadScript(rf2.radio.template))()
local mspSetProfile = assert(rf2.loadScript("MSP/mspSetProfile.lua"))()
local mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))()
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
local mspRcTuning = rf2.useApi("mspRcTuning")
local rcTuning = mspRcTuning.getDefaults()
local editing = false
local profileAdjustmentTS = nil

local startEditing = function(field, page)
    editing = true
end

local endRateEditing = function(field, page)
    mspSetProfile.setRateProfile(field.data.value, function() rf2.reloadPage() end, nil)
end

local function copyProfile(field, page)
    local source = page.fields[14].data.value
    local dest = page.fields[15].data.value
    if source == dest then return end

    local mspCopyProfile = {
        command = 183, -- MSP_COPY_PROFILE
        payload = { 1, dest, source } -- 1 = copy rates
    }

    rf2.mspQueue:add(mspCopyProfile)
    rf2.settingsSaved()
end

local function buildForm()
    local tableStartY = yMinLim - lineSpacing
    y = tableStartY
    labels = {}
    fields = {}
    labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "Roll",  x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "Pitch", x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "Yaw",   x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "Coll",  x = x, y = inc.y(tableSpacing.row) }

    x = x + tableSpacing.col
    y = tableStartY
    labels[#labels + 1] = { t = rcTuning.columnHeaders[1],      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = rcTuning.columnHeaders[2],      x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.roll_rcRates }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.pitch_rcRates }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.yaw_rcRates }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.collective_rcRates }

    x = x + tableSpacing.col
    y = tableStartY
    labels[#labels + 1] = { t = rcTuning.columnHeaders[3],      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = rcTuning.columnHeaders[4],      x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.roll_rates }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.pitch_rates }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.yaw_rates }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.collective_rates }

    x = x + tableSpacing.col
    y = tableStartY
    labels[#labels + 1] = { t = rcTuning.columnHeaders[5],      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = rcTuning.columnHeaders[6],      x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.roll_rcExpo }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.pitch_rcExpo }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.yaw_rcExpo }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), data = rcTuning.collective_rcExpo }

    x = margin
    inc.y(lineSpacing * 0.5)
    fields[13] = { t = "Rates type",                   x = x,          y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.rates_type, postEdit = function(self, page) page.updateRatesType(page, true) end }

    inc.y(lineSpacing * 0.5)
    fields[14] = { t = "Current rate profile",         x = x,          y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endRateEditing }
    fields[15] = { t = "Destination profile",          x = x,          y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } } }
    fields[#fields + 1] = { t = "[Copy Current to Dest]", x = x + indent, y = inc.y(lineSpacing), preEdit = copyProfile }

    inc.y(lineSpacing * 0.5)
    labels[#labels + 1] = { t = "Roll Dynamics",       x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.roll_response_time }
    fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.roll_accel_limit }
    labels[#labels + 1] = { t = "Pitch Dynamics",      x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.pitch_response_time }
    fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.pitch_accel_limit }
    labels[#labels + 1] = { t = "Yaw Dynamics",        x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.yaw_response_time }
    fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.yaw_accel_limit }
    labels[#labels + 1] = { t = "Collective Dynamics", x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.collective_response_time }
    fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = rcTuning.collective_accel_limit }
end

buildForm()

local function rebuildForm(page)
    labels = nil
    fields = nil
    page.labels = nil
    page.fields = nil
    collectgarbage()
    buildForm()
    page.labels = labels
    page.fields = fields
end

local function receivedRcTuning(page)
    rebuildForm(page)
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspRcTuning.read(receivedRcTuning, self, rcTuning)
    end,
    write = function(self)
        mspRcTuning.write(rcTuning)
        rf2.settingsSaved()
    end,
    title       = "Rates",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields,

    updateRatesType = function(self, applyDefaults)
        mspRcTuning.getRateDefaults(rcTuning, rcTuning.rates_type.value)
        rebuildForm(self)
    end,

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
        local currentField = self.fields[14]
        if currentField.data.value ~= status.rateProfile and not editing then
            if currentField.data.value then
                profileAdjustmentTS = rf2.clock()
            end
            currentField.data.value = status.rateProfile
        end
        local destField = self.fields[15]
        if not destField.data.value then
            if status.rateProfile < 5 then
                destField.data.value = status.rateProfile + 1
            else
                destField.data.value = 4
            end
        end
        rf2.lcdNeedsInvalidate = true
        self.isReady = true
    end,
}
