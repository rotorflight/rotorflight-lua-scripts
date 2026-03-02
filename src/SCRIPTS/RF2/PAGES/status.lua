local template = rf2.executeScript(rf2.radio.template)
local mspStatus = rf2.useApi("mspStatus")
local mspDataflash = rf2.useApi("mspDataflash")
local mspSetProfile = rf2.useApi("mspSetProfile.lua")
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
local help = {}
local t = rf2.i18n.t

help = {
    title = t("STATUS_Help_title"),
    msg = t("STATUS_Help_text")
}

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

fields[1] = { t = t("PAGE_Status_PID_Profile"),   x = x,              y = incY(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endPidEditing }
fields[2] = { t = t("PAGE_Status_Rate_Profile"),  x = x,              y = incY(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = startEditing, postEdit = endRateEditing }

incY(lineSpacing * 0.25)
fields[3] = { t = t("PAGE_Status_Real_Time_Load"),        x = x,              y = incY(lineSpacing), sp = x + sp, data = { value = 0, scale = 10, unit = rf2.units.percentage }, readOnly = true }
fields[4] = { t = t("PAGE_Status_CPU_Load"),              x = x,              y = incY(lineSpacing), sp = x + sp, data = { value = 0, scale = 10, unit = rf2.units.percentage }, readOnly = true }

incY(lineSpacing * 0.25)
labels[1] = { t = t("PAGE_Status_Arming_Flags"), x = x,              y = incY(lineSpacing) }
labels[2] = { t = "---",                   x = x + indent,     y = incY(lineSpacing), bold = false }

incY(lineSpacing * 0.25)
labels[3] = { t = t("PAGE_Status_Dataflash_Free"),  x = x,              y = incY(lineSpacing) }
labels[4] = { t = "---",                   x = x + indent,     y = incY(lineSpacing), bold = false }
fields[5] = { t = t("PAGE_Status_Erase"),               x = x + indent * 7, y = y }

local function armingDisableFlagsToString(flags)
    local s = ""
    for i = 0, 25 do
        if bit32.band(flags, bit32.lshift(1, i)) ~= 0 then
            if s ~= "" then s = s .. ", " end
            if i == 0 then s = s .. t("ARMING_DISABLED_NO_GYRO") end
            if i == 1 then s = s .. t("ARMING_DISABLED_FAIL_SAFE") end
            if i == 2 then s = s .. t("ARMING_DISABLED_RX_FAIL_SAFE") end
            if i == 3 then s = s .. t("ARMING_DISABLED_BAD_RX_RECOVERY") end
            if i == 4 then s = s .. t("ARMING_DISABLED_BOX_FAIL_SAFE") end
            if i == 5 then s = s .. t("ARMING_DISABLED_GOVERNOR") end
            if i == 6 then s = s .. t("ARMING_DISABLED_RPM_SIGNAL") end
            if i == 7 then s = s .. t("ARMING_DISABLED_THROTTLE") end
            if i == 8 then s = s .. t("ARMING_DISABLED_ANGLE") end
            if i == 9 then s = s .. t("ARMING_DISABLED_BOOT_GRACE_TIME") end
            if i == 10 then s = s .. t("ARMING_DISABLED_NO_PRE_ARM") end
            if i == 11 then s = s .. t("ARMING_DISABLED_LOAD") end
            if i == 12 then s = s .. t("ARMING_DISABLED_CALIBRATING") end
            if i == 13 then s = s .. t("ARMING_DISABLED_CLI") end
            if i == 14 then s = s .. t("ARMING_DISABLED_CMS_MENU") end
            if i == 15 then s = s .. t("ARMING_DISABLED_BST") end
            if i == 16 then s = s .. t("ARMING_DISABLED_MSP") end
            if i == 17 then s = s .. t("ARMING_DISABLED_PARALYZE") end
            if i == 18 then s = s .. t("ARMING_DISABLED_GPS") end
            if i == 19 then s = s .. t("ARMING_DISABLED_RESC") end
            if i == 20 then s = s .. t("ARMING_DISABLED_RPM_FILTER") end
            if i == 21 then s = s .. t("ARMING_DISABLED_REBOOT_REQUIRED") end
            if i == 22 then s = s .. t("ARMING_DISABLED_DSHOT_BITBANG") end
            if i == 23 then s = s .. t("ARMING_DISABLED_ACC_CALIBRATION") end
            if i == 24 then s = s .. t("ARMING_DISABLED_MOTOR_PROTOCOL") end
            if i == 25 then s = s .. t("ARMING_DISABLED_ARM_SWITCH") end
        end
    end
    if s == "" then s = "-" end
    return s
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
    title       = "Status",
    labels      = labels,
    fields      = fields,
    readOnly    = true,
    help        = help,

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
        fields[3].data.value = fcStatus.realTimeLoad
        fields[4].data.value = fcStatus.cpuLoad
        rf2.lcdNeedsInvalidate = true
    end,

    onErasedDataflash = function(self, _)
        mspDataflash.getDataflashSummary(self.onReceivedDataflashSummary, self)
    end,

    onClickErase = function(field, self)
        erasingDataflash = true
        rf2.setWaitMessage(t("MSG_Erasing"))
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
            fields[5].preEdit = self.onClickErase
        end
        rf2.onPageReady(self)
    end,
}
