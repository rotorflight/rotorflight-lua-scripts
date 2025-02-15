local function getRescueProfile(callback, callbackParam)
    local message = {
        command = 146, -- MSP_RESCUE_PROFILE
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)
            config.mode = { value = rf2.mspHelper.readU8(buf), min = 0, max = 1, table = { [0] = "Off", "On" } }
            config.flip_mode = { value = rf2.mspHelper.readU8(buf), min = 0, max = 1, table = { [0] = "No Flip", "Flip" } }
            config.flip_gain = { value = rf2.mspHelper.readU8(buf), min = 5, max = 250 }
            config.level_gain = { value = rf2.mspHelper.readU8(buf), min = 5, max = 250 }
            config.pull_up_time = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250, scale = 10 }
            config.climb_time = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250, scale = 10 }
            config.flip_time = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250, scale = 10 }
            config.exit_time = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250, scale = 10 }
            config.pull_up_collective = { value = rf2.mspHelper.readU16(buf), min = 0, max = 1000, mult = 10, scale = 10 }
            config.climb_collective = { value = rf2.mspHelper.readU16(buf), min = 0, max = 1000, mult = 10, scale = 10 }
            config.hover_collective = { value = rf2.mspHelper.readU16(buf), min = 0, max = 1000, mult = 10, scale = 10 }
            config.hover_altitude = { value = rf2.mspHelper.readU16(buf), min = 0, max = 10000, mult = 10, scale = 100 }
            config.alt_p_gain = { value = rf2.mspHelper.readU16(buf), min = 0, max = 10000 }
            config.alt_i_gain = { value = rf2.mspHelper.readU16(buf), min = 0, max = 10000 }
            config.alt_d_gain = { value = rf2.mspHelper.readU16(buf), min = 0, max = 10000 }
            config.max_collective = { value = rf2.mspHelper.readU16(buf), min = 1, max = 1000, mult = 10, scale = 10 }
            config.max_setpoint_rate = { value = rf2.mspHelper.readU16(buf), min = 1, max = 1000, mult = 10 }
            config.max_setpoint_accel = { value = rf2.mspHelper.readU16(buf), min = 1, max = 10000, mult = 10 }
            callback(callbackParam, config)
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

return {
    getRescueProfile = getRescueProfile,
    setRescueProfile = setRescueProfile
}