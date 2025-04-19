local function getData(callback, callbackParam)
    local message = {
        command = 32, -- MSP_BATTERY_CONFIG
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)


            config.batteryCapacity              = rf2.mspHelper.readU16(buf)
            config.batteryCellCount             = rf2.mspHelper.readU8(buf)
            config.voltageMeterSource           = rf2.mspHelper.readU8(buf)
            config.currentMeterSource           = rf2.mspHelper.readU8(buf)
            config.vbatmincellvoltage           = rf2.mspHelper.readU16(buf)
            config.vbatmaxcellvoltage           = rf2.mspHelper.readU16(buf)
            config.vbatfullcellvoltage          = rf2.mspHelper.readU16(buf)
            config.vbatwarningcellvoltage       = rf2.mspHelper.readU16(buf)
            config.lvcPercentage                = rf2.mspHelper.readU8(buf)
            config.consumptionWarningPercentage = rf2.mspHelper.readU8(buf)

            rf2.log("Processing battery config reply...")
            rf2.log("batteryCapacity: %d", config.batteryCapacity)
            rf2.log("batteryCellCount: %d", config.batteryCellCount)
            rf2.log("voltageMeterSource: %d", config.voltageMeterSource)
            rf2.log("currentMeterSource: %d", config.currentMeterSource)
            rf2.log("vbatmincellvoltage: %d", config.vbatmincellvoltage)
            rf2.log("vbatmaxcellvoltage: %d", config.vbatmaxcellvoltage)
            rf2.log("vbatfullcellvoltage: %d", config.vbatfullcellvoltage)
            rf2.log("vbatwarningcellvoltage: %d", config.vbatwarningcellvoltage)
            rf2.log("lvcPercentage: %d", config.lvcPercentage)
            rf2.log("consumptionWarningPercentage: %d", config.consumptionWarningPercentage)

            callback(callbackParam, config)
        end,

        simulatorResponse = {
            0x94, 0x11, -- batteryCapacity = 4500
            0x06,       -- batteryCellCount = 6
            0x01,       -- voltageMeterSource = 1
            0x01,       -- currentMeterSource = 1
            0x4A, 0x01, -- vbatmincellvoltage = 330
            0xAE, 0x01, -- vbatmaxcellvoltage = 430
            0xA4, 0x01, -- vbatfullcellvoltage = 420
            0x5E, 0x01, -- vbatwarningcellvoltage = 350
            0x4B,       -- lvcPercentage = 75
            0x50        -- consumptionWarningPercentage = 80
        }
    }
    rf2.mspQueue:add(message)
end

-- local function setData(config)
--     local message = {
--         command = 33, -- MSP_SET_BATTERY_CONFIG
--         payload = {},
--         simulatorResponse = {}
--     }

--     rf2.mspHelper.writeU16(message.payload, config.batteryCapacity.value)
--     rf2.mspHelper.writeU8(message.payload, config.batteryCellCount.value)
--     rf2.mspHelper.writeU8(message.payload, config.voltageMeterSource.value)
--     rf2.mspHelper.writeU8(message.payload, config.currentMeterSource.value)
--     rf2.mspHelper.writeU16(message.payload, config.vbatmincellvoltage.value)
--     rf2.mspHelper.writeU16(message.payload, config.vbatmaxcellvoltage.value)
--     rf2.mspHelper.writeU16(message.payload, config.vbatfullcellvoltage.value)
--     rf2.mspHelper.writeU16(message.payload, config.vbatwarningcellvoltage.value)
--     rf2.mspHelper.writeU8(message.payload, config.lvcPercentage.value)
--     rf2.mspHelper.writeU8(message.payload, config.consumptionWarningPercentage.value)

--     rf2.mspQueue:add(message)
-- end

return {
    getData = getData,
    -- setData = setData
}
