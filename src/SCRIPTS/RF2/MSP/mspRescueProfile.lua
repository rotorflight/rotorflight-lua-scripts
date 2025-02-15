local function getRescueProfile(defaults, callback, callbackParam)
    local message = {
        command = 146, -- MSP_RESCUE_PROFILE
        processReply = function(self, buf)
            --rf2.print("buf length: "..#buf)
            defaults.mode.value = rf2.mspHelper.readU8(buf)
            defaults.flip_mode.value = rf2.mspHelper.readU8(buf)
            defaults.flip_gain.value = rf2.mspHelper.readU8(buf)
            defaults.level_gain.value = rf2.mspHelper.readU8(buf)
            defaults.pull_up_time.value = rf2.mspHelper.readU8(buf)
            defaults.climb_time.value = rf2.mspHelper.readU8(buf)
            defaults.flip_time.value = rf2.mspHelper.readU8(buf)
            defaults.exit_time.value = rf2.mspHelper.readU8(buf)
            defaults.pull_up_collective.value = rf2.mspHelper.readU16(buf)
            defaults.climb_collective.value = rf2.mspHelper.readU16(buf)
            defaults.hover_collective.value = rf2.mspHelper.readU16(buf)
            defaults.hover_altitude.value = rf2.mspHelper.readU16(buf)
            defaults.alt_p_gain.value = rf2.mspHelper.readU16(buf)
            defaults.alt_i_gain.value = rf2.mspHelper.readU16(buf)
            defaults.alt_d_gain.value = rf2.mspHelper.readU16(buf)
            defaults.max_collective.value = rf2.mspHelper.readU16(buf)
            defaults.max_setpoint_rate.value = rf2.mspHelper.readU16(buf)
            defaults.max_setpoint_accel.value = rf2.mspHelper.readU16(buf)
            callback(callbackParam)
        end,
        simulatorResponse = { 1, 0, 200, 100, 5, 3, 10, 5, 182, 3, 188, 2, 194, 1, 244, 1, 20, 0, 20, 0, 10, 0, 232, 3, 44, 1, 184, 11 }
    }
    rf2.mspQueue:add(message)
end

local function setRescueProfile(config)
    local message = {
        command = 147, -- MSP_SET_RESCUE_PROFILE
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, config.mode.value)
    rf2.mspHelper.writeU8(message.payload, config.flip_mode.value)
    rf2.mspHelper.writeU8(message.payload, config.flip_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.level_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.pull_up_time.value)
    rf2.mspHelper.writeU8(message.payload, config.climb_time.value)
    rf2.mspHelper.writeU8(message.payload, config.flip_time.value)
    rf2.mspHelper.writeU8(message.payload, config.exit_time.value)
    rf2.mspHelper.writeU16(message.payload, config.pull_up_collective.value)
    rf2.mspHelper.writeU16(message.payload, config.climb_collective.value)
    rf2.mspHelper.writeU16(message.payload, config.hover_collective.value)
    rf2.mspHelper.writeU16(message.payload, config.hover_altitude.value)
    rf2.mspHelper.writeU16(message.payload, config.alt_p_gain.value)
    rf2.mspHelper.writeU16(message.payload, config.alt_i_gain.value)
    rf2.mspHelper.writeU16(message.payload, config.alt_d_gain.value)
    rf2.mspHelper.writeU16(message.payload, config.max_collective.value)
    rf2.mspHelper.writeU16(message.payload, config.max_setpoint_rate.value)
    rf2.mspHelper.writeU16(message.payload, config.max_setpoint_accel.value)
    rf2.mspQueue:add(message)
end

local function getDefaults()
    local defaults = {}
    defaults.mode = { value = nil, min = 0, max = 1, table = { [0] = "Off", "On" } }
    defaults.flip_mode = { value = nil, min = 0, max = 1, table = { [0] = "No Flip", "Flip" } }
    defaults.flip_gain = { value = nil, min = 5, max = 250 }
    defaults.level_gain = { value = nil, min = 5, max = 250 }
    defaults.pull_up_time = { value = nil, min = 0, max = 250, scale = 10 }
    defaults.climb_time = { value = nil, min = 0, max = 250, scale = 10 }
    defaults.flip_time = { value = nil, min = 0, max = 250, scale = 10 }
    defaults.exit_time = { value = nil, min = 0, max = 250, scale = 10 }
    defaults.pull_up_collective = { value = nil, min = 0, max = 1000, mult = 10, scale = 10 }
    defaults.climb_collective = { value = nil, min = 0, max = 1000, mult = 10, scale = 10 }
    defaults.hover_collective = { value = nil, min = 0, max = 1000, mult = 10, scale = 10 }
    defaults.hover_altitude = { value = nil, min = 0, max = 10000, mult = 10, scale = 100 }
    defaults.alt_p_gain = { value = nil, min = 0, max = 10000 }
    defaults.alt_i_gain = { value = nil, min = 0, max = 10000 }
    defaults.alt_d_gain = { value = nil, min = 0, max = 10000 }
    defaults.max_collective = { value = nil, min = 1, max = 1000, mult = 10, scale = 10 }
    defaults.max_setpoint_rate = { value = nil, min = 1, max = 1000, mult = 10 }
    defaults.max_setpoint_accel = { value = nil, min = 1, max = 10000, mult = 10 }
    return defaults
end

return {
    read = getRescueProfile,
    write = setRescueProfile,
    getDefaults = getDefaults
}