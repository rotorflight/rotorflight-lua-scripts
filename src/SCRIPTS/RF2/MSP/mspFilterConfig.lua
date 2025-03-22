local function getFilterConfig(data, callback, callbackParam)
    local message = {
        command = 92, -- MSP_FILTER_CONFIG
        processReply = function(self, buf)
            data.gyro_hardware_lpf.value = rf2.mspHelper.readU8(buf)
            data.gyro_lpf1_type.value = rf2.mspHelper.readU8(buf)
            data.gyro_lpf1_static_hz.value = rf2.mspHelper.readU16(buf)
            data.gyro_lpf2_type.value = rf2.mspHelper.readU8(buf)
            data.gyro_lpf2_static_hz.value = rf2.mspHelper.readU16(buf)
            data.gyro_soft_notch_hz_1.value = rf2.mspHelper.readU16(buf)
            data.gyro_soft_notch_cutoff_1.value = rf2.mspHelper.readU16(buf)
            data.gyro_soft_notch_hz_2.value = rf2.mspHelper.readU16(buf)
            data.gyro_soft_notch_cutoff_2.value = rf2.mspHelper.readU16(buf)
            data.gyro_lpf1_dyn_min_hz.value = rf2.mspHelper.readU16(buf)
            data.gyro_lpf1_dyn_max_hz.value = rf2.mspHelper.readU16(buf)
            data.dyn_notch_count.value = rf2.mspHelper.readU8(buf)
            data.dyn_notch_q.value = rf2.mspHelper.readU8(buf)
            data.dyn_notch_min_hz.value = rf2.mspHelper.readU16(buf)
            data.dyn_notch_max_hz.value = rf2.mspHelper.readU16(buf)
            if rf2.apiVersion >= 12.08 then
                data.preset.value = rf2.mspHelper.readU8(buf)
                data.min_hz.value = rf2.mspHelper.readU8(buf)
            end
            callback(callbackParam)
        end,
        simulatorResponse = { 0, 1, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 25, 25, 0, 245, 0 },
    }
    rf2.mspQueue:add(message)
end

local function setFilterConfig(data)
    local message = {
        command = 93, -- MSP_SET_FILTER_CONFIG
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, data.gyro_hardware_lpf.value)
    rf2.mspHelper.writeU8(message.payload, data.gyro_lpf1_type.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_lpf1_static_hz.value)
    rf2.mspHelper.writeU8(message.payload, data.gyro_lpf2_type.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_lpf2_static_hz.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_soft_notch_hz_1.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_soft_notch_cutoff_1.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_soft_notch_hz_2.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_soft_notch_cutoff_2.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_lpf1_dyn_min_hz.value)
    rf2.mspHelper.writeU16(message.payload, data.gyro_lpf1_dyn_max_hz.value)
    rf2.mspHelper.writeU8(message.payload, data.dyn_notch_count.value)
    rf2.mspHelper.writeU8(message.payload, data.dyn_notch_q.value)
    rf2.mspHelper.writeU16(message.payload, data.dyn_notch_min_hz.value)
    rf2.mspHelper.writeU16(message.payload, data.dyn_notch_max_hz.value)
    if rf2.apiVersion >= 12.08 then
        rf2.mspHelper.writeU8(message.payload, data.preset.value)
        rf2.mspHelper.writeU8(message.payload, data.min_hz.value)
    end
    rf2.mspQueue:add(message)
end

local function getDefaults()
    local gyroFilterType = { [0] = "NONE", "1ST", "2ND" }
    local defaults = {}
    defaults.gyro_hardware_lpf = {} --1
    defaults.gyro_lpf1_type = { min = 0, max = #gyroFilterType, table = gyroFilterType } -- 2
    defaults.gyro_lpf1_static_hz = { min = 0, max = 4000 } -- 3,4
    defaults.gyro_lpf2_type = { min = 0, max = #gyroFilterType, table = gyroFilterType } -- 5
    defaults.gyro_lpf2_static_hz = { min = 0, max = 4000 } -- 6,7
    defaults.gyro_soft_notch_hz_1 = { min = 0, max = 4000 } -- 8,9
    defaults.gyro_soft_notch_cutoff_1 = { min = 0, max = 4000 } -- 10,11
    defaults.gyro_soft_notch_hz_2 = { min = 0, max = 4000 } --12,13
    defaults.gyro_soft_notch_cutoff_2 = { min = 0, max = 4000 } --14,15
    defaults.gyro_lpf1_dyn_min_hz = { min = 0, max = 1000 } -- 16,17
    defaults.gyro_lpf1_dyn_max_hz = { min = 0, max = 1000 } -- 18,19
    defaults.dyn_notch_count = { min = 0, max = 8 } -- 20
    defaults.dyn_notch_q = { min = 10, max = 100, scale = 10 } -- 21
    defaults.dyn_notch_min_hz = { min = 10, max = 200 } -- 22,23
    defaults.dyn_notch_max_hz = { min = 100, max = 500 } -- 24,25
    if rf2.apiVersion >= 12.08 then
        defaults.preset = { min = 0, max = 3 }
        defaults.min_hz = { min = 1, max = 100 }
    end
return defaults
end

return {
    read = getFilterConfig,
    write = setFilterConfig,
    getDefaults = getDefaults
}