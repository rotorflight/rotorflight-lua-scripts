-- MSP2_GET_TUNE_ADVISOR (0x5F10, read one axis) and MSP2_CLEAR_TUNE_ADVISOR (0x5F11).
-- One axis per request so the reply (67 bytes) fits MSP over telemetry. Layout: see
-- rotorflight-firmware src/main/msp/msp.c. Firmware without them answers with an error.

local function readRatio(buf)
    local v = rf2.mspHelper.readU16(buf)
    if v >= 0x8000 then v = v - 0x10000 end
    return v / 1000
end

local function readBands(buf)
    local bands = {}
    for i = 1, 3 do
        bands[i] = { gain = readRatio(buf), count = rf2.mspHelper.readU16(buf) }
    end
    return bands
end

-- axis: 0 roll, 1 pitch, 2 yaw
local function getAxis(axis, callback, callbackParam, errorCallback)
    local message = {
        command = 0x5F10,
        payload = { axis },
        processReply = function(self, buf)
            local d = {}
            d.version = rf2.mspHelper.readU8(buf)
            d.collecting = rf2.mspHelper.readU8(buf) ~= 0
            d.seconds = rf2.mspHelper.readU16(buf)
            d.axis = rf2.mspHelper.readU8(buf)
            d.P = rf2.mspHelper.readU16(buf)
            d.F = rf2.mspHelper.readU16(buf)
            d.B = rf2.mspHelper.readU16(buf)
            d.relaxCutoff = rf2.mspHelper.readU8(buf)
            d.ratesType = rf2.mspHelper.readU8(buf)
            d.rcRate = rf2.mspHelper.readU8(buf)
            d.sRate = rf2.mspHelper.readU8(buf)
            d.ffCount = rf2.mspHelper.readU16(buf)
            d.ffGain = readRatio(buf)
            d.ffCorr = readRatio(buf)
            d.ffLagMs = rf2.mspHelper.readU16(buf)
            d.spBands = readBands(buf)
            d.collBands = readBands(buf)
            d.fullCount = rf2.mspHelper.readU16(buf)
            d.fullSatCount = rf2.mspHelper.readU16(buf)
            d.fullRatio = readRatio(buf)
            d.fullMaxRate = rf2.mspHelper.readU16(buf)
            d.releases = rf2.mspHelper.readU16(buf)
            d.bigRebounds = rf2.mspHelper.readU16(buf)
            d.meanRebound = readRatio(buf)
            d.meanOvershoot = readRatio(buf)
            d.meanCounter = readRatio(buf)
            d.meanIterm = readRatio(buf)
            callback(callbackParam, d)
        end,
        errorHandler = function(self)
            if errorCallback then errorCallback(callbackParam) end
        end,
        -- Cyclic of a real log with Actual rates (center 360, max 720): F hot (1.53x),
        -- 15% stop bounce-back
        simulatorResponse = { 1, 0, 147, 0, axis, 50, 0, 100, 0, 0, 0, 10, 4, 36, 72,
            211, 5, 250, 5, 202, 3, 90, 0,
            240, 5, 61, 5, 4, 6, 163, 0, 6, 4, 50, 0,
            216, 4, 129, 1, 4, 6, 251, 2, 194, 6, 100, 1,
            87, 0, 25, 0, 124, 1, 139, 1,
            35, 0, 18, 0, 150, 0, 190, 5, 20, 0, 3, 0 },
    }
    rf2.mspQueue:add(message)
end

local function clear(callback, callbackParam)
    local message = {
        command = 0x5F11,
        payload = {},
        processReply = function(self, buf)
            if callback then callback(callbackParam) end
        end,
        simulatorResponse = {},
    }
    rf2.mspQueue:add(message)
end

return {
    getAxis = getAxis,
    clear = clear,
}
