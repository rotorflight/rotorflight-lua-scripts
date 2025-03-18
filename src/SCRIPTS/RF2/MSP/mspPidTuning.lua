local function getPidTuning(data, callback, callbackParam)
    local message = {
        command = 112, -- MSP_PID_TUNING
        processReply = function(self, buf)
            data.roll_p.value = rf2.mspHelper.readU16(buf)
            data.roll_i.value = rf2.mspHelper.readU16(buf)
            data.roll_d.value = rf2.mspHelper.readU16(buf)
            data.roll_f.value = rf2.mspHelper.readU16(buf)
            data.pitch_p.value = rf2.mspHelper.readU16(buf)
            data.pitch_i.value = rf2.mspHelper.readU16(buf)
            data.pitch_d.value = rf2.mspHelper.readU16(buf)
            data.pitch_f.value = rf2.mspHelper.readU16(buf)
            data.yaw_p.value = rf2.mspHelper.readU16(buf)
            data.yaw_i.value = rf2.mspHelper.readU16(buf)
            data.yaw_d.value = rf2.mspHelper.readU16(buf)
            data.yaw_f.value = rf2.mspHelper.readU16(buf)
            data.roll_b.value = rf2.mspHelper.readU16(buf)
            data.pitch_b.value = rf2.mspHelper.readU16(buf)
            data.yaw_b.value = rf2.mspHelper.readU16(buf)
            data.roll_o.value = rf2.mspHelper.readU16(buf)
            data.pitch_o.value = rf2.mspHelper.readU16(buf)
            callback(callbackParam)
        end,
        simulatorResponse = {70, 0, 225, 0, 90, 0, 120, 0, 100, 0, 200, 0, 70, 0, 120, 0, 100, 0, 125, 0, 83, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 0, 25, 0 },
    }
    rf2.mspQueue:add(message)
end

local function setPidTuning(data)
    local message = {
        command = 202, -- MSP_SET_PID_TUNING
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU16(message.payload, data.roll_p.value)
    rf2.mspHelper.writeU16(message.payload, data.roll_i.value)
    rf2.mspHelper.writeU16(message.payload, data.roll_d.value)
    rf2.mspHelper.writeU16(message.payload, data.roll_f.value)
    rf2.mspHelper.writeU16(message.payload, data.pitch_p.value)
    rf2.mspHelper.writeU16(message.payload, data.pitch_i.value)
    rf2.mspHelper.writeU16(message.payload, data.pitch_d.value)
    rf2.mspHelper.writeU16(message.payload, data.pitch_f.value)
    rf2.mspHelper.writeU16(message.payload, data.yaw_p.value)
    rf2.mspHelper.writeU16(message.payload, data.yaw_i.value)
    rf2.mspHelper.writeU16(message.payload, data.yaw_d.value)
    rf2.mspHelper.writeU16(message.payload, data.yaw_f.value)
    rf2.mspHelper.writeU16(message.payload, data.roll_b.value)
    rf2.mspHelper.writeU16(message.payload, data.pitch_b.value)
    rf2.mspHelper.writeU16(message.payload, data.yaw_b.value)
    rf2.mspHelper.writeU16(message.payload, data.roll_o.value)
    rf2.mspHelper.writeU16(message.payload, data.pitch_o.value)
    rf2.mspQueue:add(message)
end

local function getDefaults()
    local defaults = {}
    defaults.roll_p = { min = 0, max = 1000 }
    defaults.roll_i = { min = 0, max = 1000 }
    defaults.roll_d = { min = 0, max = 1000 }
    defaults.roll_f = { min = 0, max = 1000 }
    defaults.pitch_p = { min = 0, max = 1000 }
    defaults.pitch_i = { min = 0, max = 1000 }
    defaults.pitch_d = { min = 0, max = 1000 }
    defaults.pitch_f = { min = 0, max = 1000 }
    defaults.yaw_p = { min = 0, max = 1000 }
    defaults.yaw_i = { min = 0, max = 1000 }
    defaults.yaw_d = { min = 0, max = 1000 }
    defaults.yaw_f = { min = 0, max = 1000 }
    defaults.roll_b = { min = 0, max = 1000 }
    defaults.pitch_b = { min = 0, max = 1000 }
    defaults.yaw_b = { min = 0, max = 1000 }
    defaults.roll_o = { min = 0, max = 1000 }
    defaults.pitch_o = { min = 0, max = 1000 }
    return defaults
end

return {
    read = getPidTuning,
    write = setPidTuning,
    getDefaults = getDefaults
}