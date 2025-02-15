local function getGovernorProfile(callback, callbackParam)
    local message = {
        command = 148, -- MSP_GOVERNOR_PROFILE
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)
            config.headspeed = { value = rf2.mspHelper.readU16(buf), min = 0, max = 50000, mult = 10 }
            config.gain = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.p_gain = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.i_gain = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.d_gain = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.f_gain = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.tta_gain = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.tta_limit = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.yaw_ff_weight = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.cyclic_ff_weight = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.collective_ff_weight = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.max_throttle = { value = rf2.mspHelper.readU8(buf), min = 0, max = 100 }
            if rf2.apiVersion >= 12.07 then
                config.min_throttle = { value = rf2.mspHelper.readU8(buf), min = 0, max = 100 }
            end
            callback(callbackParam, config)
        end,
        simulatorResponse = { 208, 7, 100, 10, 125, 5, 20, 0, 20, 10, 40, 100, 100, 10 }
    }
    rf2.mspQueue:add(message)
end

local function setGovernorProfile(config)
    local message = {
        command = 149, -- MSP_SET_GOVERNOR_PROFILE
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU16(message.payload, config.headspeed.value)
    rf2.mspHelper.writeU8(message.payload, config.gain.value)
    rf2.mspHelper.writeU8(message.payload, config.p_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.i_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.d_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.f_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.tta_gain.value)
    rf2.mspHelper.writeU8(message.payload, config.tta_limit.value)
    rf2.mspHelper.writeU8(message.payload, config.yaw_ff_weight.value)
    rf2.mspHelper.writeU8(message.payload, config.cyclic_ff_weight.value)
    rf2.mspHelper.writeU8(message.payload, config.collective_ff_weight.value)
    rf2.mspHelper.writeU8(message.payload, config.max_throttle.value)
    if rf2.apiVersion >= 12.07 then
        rf2.mspHelper.writeU8(message.payload, config.min_throttle.value)
    end
    rf2.mspQueue:add(message)
end

return {
    getGovernorProfile = getGovernorProfile,
    setGovernorProfile = setGovernorProfile
}