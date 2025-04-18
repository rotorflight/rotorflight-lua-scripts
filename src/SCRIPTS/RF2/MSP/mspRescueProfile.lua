local function getDefaults()
    local defaults = {}
    defaults.mode = { value = nil, min = 0, max = 1, table = { [0] = "Off", "On" } }
    defaults.flip_mode = { value = nil, min = 0, max = 1, table = { [0] = "No Flip", "Flip" } }
    defaults.flip_gain = { value = nil, min = 5, max = 250 }
    defaults.level_gain = { value = nil, min = 5, max = 250 }
    defaults.pull_up_time = { value = nil, min = 0, max = 250, scale = 10, unit = rf2.units.seconds }
    defaults.climb_time = { value = nil, min = 0, max = 250, scale = 10, unit = rf2.units.seconds }
    defaults.flip_time = { value = nil, min = 0, max = 250, scale = 10, unit = rf2.units.seconds }
    defaults.exit_time = { value = nil, min = 0, max = 250, scale = 10, unit = rf2.units.seconds }
    defaults.pull_up_collective = { value = nil, min = 0, max = 1000, mult = 10, scale = 10, unit = rf2.units.percentage }
    defaults.climb_collective = { value = nil, min = 0, max = 1000, mult = 10, scale = 10, unit = rf2.units.percentage }
    defaults.hover_collective = { value = nil, min = 0, max = 1000, mult = 10, scale = 10, unit = rf2.units.percentage }
    defaults.hover_altitude = { value = nil, min = 0, max = 10000, mult = 10, scale = 100 }
    defaults.alt_p_gain = { value = nil, min = 0, max = 10000 }
    defaults.alt_i_gain = { value = nil, min = 0, max = 10000 }
    defaults.alt_d_gain = { value = nil, min = 0, max = 10000 }
    defaults.max_collective = { value = nil, min = 1, max = 1000, mult = 10, scale = 10, unit = rf2.units.percentage }
    defaults.max_setpoint_rate = { value = nil, min = 1, max = 1000, mult = 10, unit = rf2.units.degreesPerSecond }
    defaults.max_setpoint_accel = { value = nil, min = 1, max = 10000, mult = 10 }
    return defaults
end

local function getRescueProfile(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 146, -- MSP_RESCUE_PROFILE
        processReply = function(self, buf)
            --rf2.print("buf length: "..#buf)
            data.mode.value = rf2.mspHelper.readU8(buf)
            data.flip_mode.value = rf2.mspHelper.readU8(buf)
            data.flip_gain.value = rf2.mspHelper.readU8(buf)
            data.level_gain.value = rf2.mspHelper.readU8(buf)
            data.pull_up_time.value = rf2.mspHelper.readU8(buf)
            data.climb_time.value = rf2.mspHelper.readU8(buf)
            data.flip_time.value = rf2.mspHelper.readU8(buf)
            data.exit_time.value = rf2.mspHelper.readU8(buf)
            data.pull_up_collective.value = rf2.mspHelper.readU16(buf)
            data.climb_collective.value = rf2.mspHelper.readU16(buf)
            data.hover_collective.value = rf2.mspHelper.readU16(buf)
            data.hover_altitude.value = rf2.mspHelper.readU16(buf)
            data.alt_p_gain.value = rf2.mspHelper.readU16(buf)
            data.alt_i_gain.value = rf2.mspHelper.readU16(buf)
            data.alt_d_gain.value = rf2.mspHelper.readU16(buf)
            data.max_collective.value = rf2.mspHelper.readU16(buf)
            data.max_setpoint_rate.value = rf2.mspHelper.readU16(buf)
            data.max_setpoint_accel.value = rf2.mspHelper.readU16(buf)
            callback(callbackParam, data)
        end,
        simulatorResponse = { 1, 0, 200, 100, 5, 3, 10, 5, 182, 3, 188, 2, 194, 1, 244, 1, 20, 0, 20, 0, 10, 0, 232, 3, 44, 1, 184, 11 }
    }
    rf2.mspQueue:add(message)
end

local function setRescueProfile(data)
    local message = {
        command = 147, -- MSP_SET_RESCUE_PROFILE
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, data.mode.value)
    rf2.mspHelper.writeU8(message.payload, data.flip_mode.value)
    rf2.mspHelper.writeU8(message.payload, data.flip_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.level_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.pull_up_time.value)
    rf2.mspHelper.writeU8(message.payload, data.climb_time.value)
    rf2.mspHelper.writeU8(message.payload, data.flip_time.value)
    rf2.mspHelper.writeU8(message.payload, data.exit_time.value)
    rf2.mspHelper.writeU16(message.payload, data.pull_up_collective.value)
    rf2.mspHelper.writeU16(message.payload, data.climb_collective.value)
    rf2.mspHelper.writeU16(message.payload, data.hover_collective.value)
    rf2.mspHelper.writeU16(message.payload, data.hover_altitude.value)
    rf2.mspHelper.writeU16(message.payload, data.alt_p_gain.value)
    rf2.mspHelper.writeU16(message.payload, data.alt_i_gain.value)
    rf2.mspHelper.writeU16(message.payload, data.alt_d_gain.value)
    rf2.mspHelper.writeU16(message.payload, data.max_collective.value)
    rf2.mspHelper.writeU16(message.payload, data.max_setpoint_rate.value)
    rf2.mspHelper.writeU16(message.payload, data.max_setpoint_accel.value)
    rf2.mspQueue:add(message)
end

return {
    read = getRescueProfile,
    write = setRescueProfile,
    getDefaults = getDefaults
}