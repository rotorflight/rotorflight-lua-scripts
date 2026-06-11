local function getDefaults()
    local defaults = {}
    if rf2.apiVersion >= 12.09 then
        defaults.smartfuel_charge_drop_rate = { min = 0, max = 250, scale = 100, unit = rf2.units.percentagePerSecond }
        defaults.smartfuel_mode = { min = 0, max = 3, table = { [0] = "OFF", "VOLTAGE", "CURRENT", "COMBINED" } }
        defaults.smartfuel_sag_gain = { min = 0, max = 100, unit = rf2.units.percentage }
        defaults.smartfuel_voltage_drop_rate = { min = 0, max = 250, unit = rf2.units.millivoltsPerSecond }
    end
    return defaults
end

local function getSmartFuelConfig(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 16384, -- MSP2_GET_SMARTFUEL_CONFIG (0x4000)
        processReply = function(self, buf)
            if rf2.apiVersion >= 12.09 then
                data.smartfuel_mode.value = rf2.mspHelper.readU8(buf)
                data.smartfuel_voltage_drop_rate.value = rf2.mspHelper.readU8(buf)
                data.smartfuel_charge_drop_rate.value = rf2.mspHelper.readU8(buf)
                data.smartfuel_sag_gain.value = rf2.mspHelper.readU8(buf)
            end
            if callback then callback(callbackParam, data) end
        end,
        simulatorResponse = { 12, 3, 42, 52 }
    }
    rf2.mspQueue:add(message)
end

local function setSmartFuelConfig(config)
    local message = {
        command = 16385, -- MSP2_SET_SMARTFUEL_CONFIG (0x4001)
        payload = {},
        simulatorResponse = {}
    }
    if rf2.apiVersion >= 12.09 then
        rf2.mspHelper.writeU8(message.payload, config.smartfuel_mode.value)
        rf2.mspHelper.writeU8(message.payload, config.smartfuel_voltage_drop_rate.value)
        rf2.mspHelper.writeU8(message.payload, config.smartfuel_charge_drop_rate.value)
        rf2.mspHelper.writeU8(message.payload, config.smartfuel_sag_gain.value)
    end
    rf2.mspQueue:add(message)
end

return {
    read = getSmartFuelConfig,
    write = setSmartFuelConfig,
    getDefaults = getDefaults
}
