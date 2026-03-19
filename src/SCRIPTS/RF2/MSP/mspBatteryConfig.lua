local function getDefaults()
    local defaults = {}
    if rf2.apiVersion < 12.09 then
        defaults.batteryCapacity = { min = 0, max = 20000, mult = 25, unit = rf2.units.mah }
    end
    defaults.batteryCellCount = { min = 0, max = 24 }
    defaults.voltageMeterSource = { min = 0, max = 3, table = { [0] = "None", "ADC", "ESC" } }
    defaults.currentMeterSource = { min = 0, max = 3, table = { [0] = "None", "ADC", "ESC" } }
    defaults.vbatmincellvoltage = { min = 100, max = 500, scale = 100, unit =  rf2.units.volt }
    defaults.vbatmaxcellvoltage = { min = 100, max = 500, scale = 100, unit =  rf2.units.volt }
    defaults.vbatfullcellvoltage = { min = 100, max = 500, scale = 100, unit =  rf2.units.volt }
    defaults.vbatwarningcellvoltage = { min = 100, max = 500, scale = 100, unit =  rf2.units.volt }
    defaults.lvcPercentage = { min = 0, max = 100, unit = rf2.units.percentage }
    defaults.consumptionWarningPercentage = { min = 0, max = 100, unit = rf2.units.percentage }
    if rf2.apiVersion >= 12.09 then
        defaults.batteryCapacity = { }
        for i = 0, 5 do
            defaults.batteryCapacity[i] = { min = 0, max = 20000, mult = 25, units = rf2.units.mah }
        end
    end

    return defaults
end

local function getBatteryConfig(callback, callbackParam, config)
    if not config then config = getDefaults() end
    local message = {
        command = 32, -- MSP_BATTERY_CONFIG
        processReply = function(self, buf)
            local activeBatteryCapacity =  rf2.mspHelper.readU16(buf)
            if rf2.apiVersion < 12.09 then
                config.batteryCapacity.value = activeBatteryCapacity
            end
            config.batteryCellCount.value = rf2.mspHelper.readU8(buf)
            config.voltageMeterSource.value = rf2.mspHelper.readU8(buf)
            config.currentMeterSource.value = rf2.mspHelper.readU8(buf)
            config.vbatmincellvoltage.value = rf2.mspHelper.readU16(buf)
            config.vbatmaxcellvoltage.value = rf2.mspHelper.readU16(buf)
            config.vbatfullcellvoltage.value = rf2.mspHelper.readU16(buf)
            config.vbatwarningcellvoltage.value = rf2.mspHelper.readU16(buf)
            config.lvcPercentage.value = rf2.mspHelper.readU8(buf)
            config.consumptionWarningPercentage.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion >= 12.09 then
                for i = 0, 5 do
                    config.batteryCapacity[i].value = rf2.mspHelper.readU16(buf)
                end
            end
            if callback then callback(callbackParam, config) end
        end,
        simulatorResponse = { 184, 11, 12, 2, 2, 64, 1, 174, 1, 154, 1, 94, 1, 100, 10, 152, 8, 184, 11, 172, 13, 160, 15, 0, 0, 0, 0 }
    }
    rf2.mspQueue:add(message)
end

local function setBatteryConfig(config)
    local message = {
        command = 33, -- MSP_SET_BATTERY_CONFIG
        payload = {},
        simulatorResponse = {}
    }
    if rf2.apiVersion < 12.09 then
        rf2.mspHelper.writeU16(message.payload, config.batteryCapacity.value)
    else
        rf2.mspHelper.writeU16(message.payload, config.batteryCapacity[0].value) -- will be overwritten later
    end
    rf2.mspHelper.writeU8(message.payload, config.batteryCellCount.value)
    rf2.mspHelper.writeU8(message.payload, config.voltageMeterSource .value)
    rf2.mspHelper.writeU8(message.payload, config.currentMeterSource .value)
    rf2.mspHelper.writeU16(message.payload, config.vbatmincellvoltage .value)
    rf2.mspHelper.writeU16(message.payload, config.vbatmaxcellvoltage .value)
    rf2.mspHelper.writeU16(message.payload, config.vbatfullcellvoltage .value)
    rf2.mspHelper.writeU16(message.payload, config.vbatwarningcellvoltage .value)
    rf2.mspHelper.writeU8(message.payload, config.lvcPercentage .value)
    rf2.mspHelper.writeU8(message.payload, config.consumptionWarningPercentage .value)
    if rf2.apiVersion >= 12.09 then
        for i = 0, 5 do
            rf2.mspHelper.writeU16(message.payload, config.batteryCapacity[i].value)
        end
    end

    rf2.mspQueue:add(message)
end

return {
    read = getBatteryConfig,
    write = setBatteryConfig,
    getDefaults = getDefaults
}