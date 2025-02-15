local function getGovernorProfile(defaults, callback, callbackParam)
    local message = {
        command = 148, -- MSP_GOVERNOR_PROFILE
        processReply = function(self, buf)
            --rf2.print("buf length: "..#buf)
            defaults.headspeed.value = rf2.mspHelper.readU16(buf)
            defaults.gain.value = rf2.mspHelper.readU8(buf)
            defaults.p_gain.value = rf2.mspHelper.readU8(buf)
            defaults.i_gain.value = rf2.mspHelper.readU8(buf)
            defaults.d_gain.value = rf2.mspHelper.readU8(buf)
            defaults.f_gain.value = rf2.mspHelper.readU8(buf)
            defaults.tta_gain.value = rf2.mspHelper.readU8(buf)
            defaults.tta_limit.value = rf2.mspHelper.readU8(buf)
            defaults.yaw_ff_weight.value = rf2.mspHelper.readU8(buf)
            defaults.cyclic_ff_weight.value = rf2.mspHelper.readU8(buf)
            defaults.collective_ff_weight.value = rf2.mspHelper.readU8(buf)
            defaults.max_throttle.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion >= 12.07 then
                defaults.min_throttle.value = rf2.mspHelper.readU8(buf)
            end
            callback(callbackParam)
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

local function getDefaults()
    local defaults = {}
    defaults.headspeed = { value = nil, min = 0, max = 50000, mult = 10 }
    defaults.gain = { value = nil, min = 0, max = 250 }
    defaults.p_gain = { value = nil, min = 0, max = 250 }
    defaults.i_gain = { value = nil, min = 0, max = 250 }
    defaults.d_gain = { value = nil, min = 0, max = 250 }
    defaults.f_gain = { value = nil, min = 0, max = 250 }
    defaults.tta_gain = { value = nil, min = 0, max = 250 }
    defaults.tta_limit = { value = nil, min = 0, max = 250 }
    defaults.yaw_ff_weight = { value = nil, min = 0, max = 250 }
    defaults.cyclic_ff_weight = { value = nil, min = 0, max = 250 }
    defaults.collective_ff_weight = { value = nil, min = 0, max = 250 }
    defaults.max_throttle = { value = nil, min = 0, max = 100 }
    if rf2.apiVersion >= 12.07 then
        defaults.min_throttle = { value = nil, min = 0, max = 100 }
    end
    return defaults
end

return {
    read = getGovernorProfile,
    write = setGovernorProfile,
    getDefaults = getDefaults
}