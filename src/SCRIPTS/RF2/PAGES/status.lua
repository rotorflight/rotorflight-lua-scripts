local template = assert(rf2.loadScript(rf2.radio.template))()
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
local fcStatus = {}

fields[#fields + 1] = { x = 1000, y = y, min = 0, max = 0 }
labels[#labels + 1] = { t = "Arming disabled flags", x = x,          y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "",                      x = x + indent, y = inc.y(lineSpacing) }

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
            --if i == 6 then t = t .. "Crash Detected" end
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
    return t
end

local function setValues()
    labels[2].t = armingDisableFlagsToString(fcStatus.armingDisableFlags)
end

return {
    read = function(self)
        mspStatus.getStatus(self.onProcessedMspStatus, self)
    end,
    write       = nil,
    reboot      = false,
    eepromWrite = true,
    title       = "Copy",
    minBytes    = 3,
    labels      = labels,
    fields      = fields,
    timer = function(self)
        if rf2.mspQueue:isProcessed() then
            mspStatus.getStatus(self.onProcessedMspStatus, self)
        end
    end,
    onProcessedMspStatus = function(self, status)
        fcStatus = status
        setValues()
        self.isReady = true
    end,
}
