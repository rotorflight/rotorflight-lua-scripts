local template = assert(rf2.loadScript(rf2.radio.template))()
local mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))()
local mspDataflash = assert(rf2.loadScript("MSP/mspDataflash.lua"))()
local mspSetProfile = assert(rf2.loadScript("MSP/mspSetProfile.lua"))()
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
local fcStatus = {}
local dataflashSummary = {}
local erasingDataflash = false
local editing = false

local startEditing = function(field, page)
    editing = true
end

local endPidEditing = function(field, page)
    editing = false
    mspSetProfile.setPidProfile(field.data.value)
end

local endRateEditing = function(field, page)
    editing = false
    mspSetProfile.setRateProfile(field.data.value)
end

fields[#fields + 1] = { t = "Current PID profile",   x = x,              y = incY(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endPidEditing }
fields[#fields + 1] = { t = "Current rate profile",  x = x,              y = incY(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endRateEditing }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Arming Disabled Flags", x = x,              y = incY(lineSpacing) }
labels[#labels + 1] = { t = "---",                   x = x + indent,     y = incY(lineSpacing), bold = false }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Dataflash Free Space",  x = x,              y = incY(lineSpacing) }
labels[#labels + 1] = { t = "---",                   x = x + indent,     y = incY(lineSpacing), bold = false }
fields[#fields + 1] = { t = "[Erase]",               x = x + indent * 7, y = y }

incY(lineSpacing * 0.25)
fields[#fields + 1] = { t = "Real-time load",        x = x,              y = incY(lineSpacing), sp = x + sp, data = { value = 0, scale = 10, unit = rf2.units.percentage }, readOnly = true }
fields[#fields + 1] = { t = "CPU load",              x = x,              y = incY(lineSpacing), sp = x + sp, data = { value = 0, scale = 10, unit = rf2.units.percentage }, readOnly = true }

local function armingDisableFlagsToString(flags)
    local t = ""
    for i = 0, 25 do
        if bit32.band(flags, bit32.lshift(1, i)) ~= 0 then
            if t ~= "" then t = t .. ", " end
            if i == 0 then t = t .. "No Gyro" end
            if i == 1 then t = t .. "Fail Safe" end
            if i == 2 then t = t .. "RX Fail Safe" end
            if i == 3 then t = t .. "Bad RX Recovery" end
            if i == 4 then t = t .. "Box Fail Safe" end
            if i == 5 then t = t .. "Governor" end
            if i == 6 then t = t .. "RPM Signal" end
            if i == 7 then t = t .. "Throttle" end
            if i == 8 then t = t .. "Angle" end
            if i == 9 then t = t .. "Boot Grace Time" end
            if i == 10 then t = t .. "No Pre Arm" end
            if i == 11 then t = t .. "Load" end
            if i == 12 then t = t .. "Calibrating" end
            if i == 13 then t = t .. "CLI" end
            if i == 14 then t = t .. "CMS Menu" end
            if i == 15 then t = t .. "BST" end
            if i == 16 then t = t .. "MSP" end
            if i == 17 then t = t .. "Paralyze" end
            if i == 18 then t = t .. "GPS" end
            if i == 19 then t = t .. "Resc" end
            if i == 20 then t = t .. "RPM Filter" end
            if i == 21 then t = t .. "Reboot Required" end
            if i == 22 then t = t .. "DSHOT Bitbang" end
            if i == 23 then t = t .. "Acc Calibration" end
            if i == 24 then t = t .. "Motor Protocol" end
            if i == 25 then t = t .. "Arm Switch" end
        end
    end
    if t == "" then t = "-" end
    return t
end

local function getFreeDataflashSpace()
    if not dataflashSummary.supported then return "N/A" end
    local freeSpace = dataflashSummary.totalSize - dataflashSummary.usedSize
    return string.format("%.1f MB", freeSpace / (1024 * 1024))
end

return {
    read = function(self)
        mspStatus.getStatus(self.onProcessedMspStatus, self)
        mspDataflash.getDataflashSummary(self.onReceivedDataflashSummary, self)
    end,
    write       = nil,
    reboot      = false,
    eepromWrite = false,
    title       = "Status",
    labels      = labels,
    fields      = fields,
    readOnly    = true,

    timer = function(self)
        if rf2.mspQueue:isProcessed() then
            if not editing then
                mspStatus.getStatus(self.onProcessedMspStatus, self)
            end
            if erasingDataflash then
                mspDataflash.getDataflashSummary(self.onReceivedDataflashSummary, self)
            end
        end
    end,

    onProcessedMspStatus = function(self, status)
        fcStatus = status
        labels[2].t = armingDisableFlagsToString(fcStatus.armingDisableFlags)
        if not editing and (fields[1].data.value ~= fcStatus.profile or fields[2].data.value ~= fcStatus.rateProfile) then
            fields[1].data.value = fcStatus.profile
            fields[2].data.value = fcStatus.rateProfile
            rf2.onPageReady(self) -- force page redraw (important for ui_lvgl)
        end
        fields[4].data.value = fcStatus.realTimeLoad
        fields[5].data.value = fcStatus.cpuLoad
        rf2.lcdNeedsInvalidate = true
    end,

    onErasedDataflash = function(self, _)
        mspDataflash.getDataflashSummary(self.onReceivedDataflashSummary, self)
    end,

    onClickErase = function(field, self)
        erasingDataflash = true
        rf2.setWaitMessage("Erasing...")
        mspDataflash.eraseDataflash(self.onErasedDataflash, self)
        rf2.lcdNeedsInvalidate = true
    end,

    onReceivedDataflashSummary = function(self, summary)
        dataflashSummary = summary
        if summary.ready and erasingDataflash then
            erasingDataflash = false
            rf2.clearWaitMessage()
        end
        labels[4].t = getFreeDataflashSpace()
        if dataflashSummary.supported then
            fields[3].preEdit = self.onClickErase
        end
        rf2.onPageReady(self)
    end,
}
