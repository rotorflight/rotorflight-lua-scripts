local function getDefaults()
    local defaults = {}
    defaults.protocol = { min = 0, max = 14, table = { [0] = "NONE", "BLHELI32", "HOBBYWING V4", "HOBBYWING V5", "SCORPION", "KONTRONIK", "OMP", "ZTW", "APD", "OPENYGE", "FLYROTOR", "GRAUPNER", "XDFLY", "FrSky F.BUS", "RECORD" } }
    defaults.half_duplex = { min = 0, max = 1, table = { [0] = "Off", "On" } }
    defaults.update_hz = { min = 10, max = 500, unit = rf2.units.herz }
    defaults.current_offset = { min = 0, max = 1000 }
    defaults.hw4_current_offset = { min = 0, max = 1000 }
    defaults.hw4_current_gain = { min = 0, max = 250 }
    defaults.hw4_voltage_gain = { min = 0, max = 250 }
    if rf2.apiVersion >= 12.07 then
        defaults.pin_swap = { min = 0, max = 1, table = { [0] = "Off", "On" } }
    end
    if rf2.apiVersion >= 12.08 then
        defaults.voltage_correction = { min = -99, max = 125, unit = rf2.units.percentage }
        defaults.current_correction = { min = -99, max = 125, unit = rf2.units.percentage }
        defaults.consumption_correction = { min = -99, max = 125, unit = rf2.units.percentage }
    end
    return defaults
end

local function getEscSensorConfig(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 123, -- MSP_ESC_SENSOR_CONFIG
        processReply = function(self, buf)
            data.protocol.value = rf2.mspHelper.readU8(buf)
            data.half_duplex.value = rf2.mspHelper.readU8(buf)
            data.update_hz.value = rf2.mspHelper.readU16(buf)
            data.current_offset.value = rf2.mspHelper.readU16(buf)
            data.hw4_current_offset.value = rf2.mspHelper.readU16(buf)
            data.hw4_current_gain.value = rf2.mspHelper.readU8(buf)
            data.hw4_voltage_gain.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion >= 12.07 then
                data.pin_swap.value = rf2.mspHelper.readU8(buf)
            else
                buf.offset = buf.offset + 1
            end
            if rf2.apiVersion >= 12.08 then
                data.voltage_correction.value = rf2.mspHelper.readS8(buf)
                data.current_correction.value = rf2.mspHelper.readS8(buf)
                data.consumption_correction.value = rf2.mspHelper.readS8(buf)
            else
                buf.offset = buf.offset + 3
            end
            callback(callbackParam, data)
        end,
        simulatorResponse = { 0, 0, 200, 0, 15, 0, 0, 0, 0, 30, 0, 0, 0, 0 }
    }
    rf2.mspQueue:add(message)
end

local function setEscSensorConfig(config)
    local message = {
        command = 216, -- MSP_SET_ESC_SENSOR_CONFIG
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, config.protocol.value)
    rf2.mspHelper.writeU8(message.payload, config.half_duplex.value)
    rf2.mspHelper.writeU16(message.payload, config.update_hz.value)
    rf2.mspHelper.writeU16(message.payload, config.current_offset.value)
    rf2.mspHelper.writeU16(message.payload, config.hw4_current_offset.value)
    rf2.mspHelper.writeU8(message.payload, config.hw4_current_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.hw4_voltage_gain.value)
    if rf2.apiVersion >= 12.07 then
        rf2.mspHelper.writeU8(message.payload, config.pin_swap.value)
    else
        rf2.mspHelper.writeU8(message.payload, 0)
    end
    if rf2.apiVersion >= 12.08 then
        rf2.mspHelper.writeU8(message.payload, config.voltage_correction.value)
        rf2.mspHelper.writeU8(message.payload, config.current_correction.value)
        rf2.mspHelper.writeU8(message.payload, config.consumption_correction.value)
    else
        rf2.mspHelper.writeU8(message.payload, 0)
        rf2.mspHelper.writeU8(message.payload, 0)
        rf2.mspHelper.writeU8(message.payload, 0)
    end
    rf2.mspQueue:add(message)
end

return {
    read = getEscSensorConfig,
    write = setEscSensorConfig,
    getDefaults = getDefaults
}
