local MSP_SET_RTC = 246

local timeIsSet = false
local lastRunTS = 0
local INTERVAL = 50

local function processMspReply(cmd,rx_buf,err)
    if cmd == MSP_SET_RTC and not err then
        timeIsSet = true
        playTone(1600, 500, 0, PLAY_BACKGROUND)
    end
end

local function setRtc()
    if lastRunTS == 0 or lastRunTS + INTERVAL < getTime() then
        -- only send datetime one time after telemetry connection became available
        -- or when connection is restored after e.g. lipo refresh

        local values = {}
        local now = getRtcTime()

        -- format: seconds after the epoch (32) / milliseconds (16)
        for i = 1, 4 do
            values[i] = bit32.band(now, 0xFF)
            now = bit32.rshift(now, 8)
        end

        values[5] = 0 -- we don't have milliseconds
        values[6] = 0

        rf2.protocol.mspWrite(MSP_SET_RTC, values)
        lastRunTS = getTime()
    end

    mspProcessTxQ()
    processMspReply(mspPollReply())

    return timeIsSet
end

return { f = setRtc, t = "" }
