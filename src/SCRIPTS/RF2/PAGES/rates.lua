--rf2.showMemoryUsage(">>>>> PAGE LOAD <<<<<<")
local template = assert(rf2.loadScript(rf2.radio.template))()
--rf2.showMemoryUsage("after template")
local mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))()
--rf2.showMemoryUsage("after mspStatus")
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
local rcTuning = rf2.useApi("mspRcTuning").getDefaults()
--rf2.showMemoryUsage("after getDefaults")
collectgarbage()
local editing = false
local profileAdjustmentTS = nil

local startEditing = function(field, page)
    editing = true
end

local endRateEditing = function(field, page)
    rf2.useApi("mspSetProfile").setRateProfile(field.data.value, function() rf2.reloadPage() end, nil)
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
    --rf2.showMemoryUsage("before buildform")
    local tableStartY = yMinLim - lineSpacing
    y = tableStartY
    labels = {}
    fields = {}

    labels[#labels + 1] = { t = "",      x = x, y = incY(tableSpacing.header) }
    labels[#labels + 1] = { t = "",      x = x, y = incY(tableSpacing.header) }
    labels[#labels + 1] = { t = "Roll",  x = x, y = incY(tableSpacing.row) }
    labels[#labels + 1] = { t = "Pitch", x = x, y = incY(tableSpacing.row) }
    labels[#labels + 1] = { t = "Yaw",   x = x, y = incY(tableSpacing.row) }
    labels[#labels + 1] = { t = "Coll",  x = x, y = incY(tableSpacing.row) }

    x = x + tableSpacing.col
    y = tableStartY
    labels[#labels + 1] = { t = rcTuning.columnHeaders[1], x = x, y = incY(tableSpacing.header) }
    labels[#labels + 1] = { t = rcTuning.columnHeaders[2], x = x, y = incY(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.roll_rcRates }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.pitch_rcRates }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.yaw_rcRates }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.collective_rcRates }

    x = x + tableSpacing.col
    y = tableStartY
    labels[#labels + 1] = { t = rcTuning.columnHeaders[3], x = x, y = incY(tableSpacing.header) }
    labels[#labels + 1] = { t = rcTuning.columnHeaders[4], x = x, y = incY(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.roll_rates }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.pitch_rates }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.yaw_rates }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.collective_rates }

    x = x + tableSpacing.col
    y = tableStartY
    labels[#labels + 1] = { t = rcTuning.columnHeaders[5], x = x, y = incY(tableSpacing.header) }
    labels[#labels + 1] = { t = rcTuning.columnHeaders[6], x = x, y = incY(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.roll_rcExpo }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.pitch_rcExpo }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.yaw_rcExpo }
    fields[#fields + 1] = {              x = x, y = incY(tableSpacing.row), data = rcTuning.collective_rcExpo }

    x = margin
    incY(lineSpacing * 0.5)
    fields[13] = { t = "Rates type",                      x = x,          y = incY(lineSpacing), sp = x + sp, data = rcTuning.rates_type, postEdit = function(self, page) page.updateRatesType(page) end }

    incY(lineSpacing * 0.5)
    fields[14] = { t = "Current rate profile",            x = x,          y = incY(lineSpacing), sp = x + sp * 1.17, data = { min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endRateEditing }
    fields[15] = { t = "Destination profile",             x = x,          y = incY(lineSpacing), sp = x + sp * 1.17, data = { min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } } }
    fields[#fields + 1] = { t = "[Copy Current to Dest]", x = x + indent, y = incY(lineSpacing), preEdit = copyProfile }
    --rf2.showMemoryUsage("after buildform")
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
        rf2.useApi("mspRcTuning").read(receivedRcTuning, self, rcTuning)
    end,
    write = function(self)
        rf2.useApi("mspRcTuning").write(rcTuning)
        rf2.settingsSaved()
    end,
    title       = "Rates",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields,

    updateRatesType = function(self, applyDefaults)
        rf2.useApi("mspRcTuning").getRateDefaults(rcTuning, rcTuning.rates_type.value)
        rebuildForm(self)
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
