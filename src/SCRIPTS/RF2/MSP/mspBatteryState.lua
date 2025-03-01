local function getData(callback, callbackParam)
    local message = {
        command = 130, -- MSP_BATTERY_STATE
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)
            config.batteryState                = rf2.mspHelper.readU8(buf)
            config.batteryCellCount            = rf2.mspHelper.readU8(buf)
            config.batteryCapacity             = rf2.mspHelper.readU16(buf)
            config.batteryCapacityUsed         = rf2.mspHelper.readU16(buf)
            config.batteryVoltage              = rf2.mspHelper.readU16(buf)
            config.batteryCurrent              = rf2.mspHelper.readU16(buf)
            config.batteryPercentageRemaining  = rf2.mspHelper.readU8(buf)

            rf2.log("Processing battery status reply...")
            rf2.log("batteryState: %d",          config.batteryState)
            rf2.log("batteryCellCount: %d",      config.batteryCellCount)
            rf2.log("batteryCapacity: %d",       config.batteryCapacity)
            rf2.log("batteryCapacityUsed: %d",   config.batteryCapacityUsed)
            rf2.log("batteryVoltage: %d",        config.batteryVoltage)
            rf2.log("batteryCurrent: %d",        config.batteryCurrent)
            rf2.log("batteryPercentageRemaining: %d", config.batteryPercentageRemaining)

            callback(callbackParam, config)
        end,

        simulatorResponse = {
            0x01,       -- batteryState = 1
            0x06,       -- batteryCellCount = 6
            0x94, 0x11, -- batteryCapacity = 4500
            0xE8, 0x03, -- batteryCapacityUsed = 1000
            0x24, 0x09, -- batteryVoltage = 2340  3.9*6
            0x82, 0x00, -- batteryCurrent = 130
            0x4B        -- batteryPercentageRemaining = 75
        }
    }
    rf2.mspQueue:add(message)
end

return {
    getData = getData
}
