local function getGovernorProfile(data, callback, callbackParam)
    local message = {
        command = 148, -- MSP_GOVERNOR_PROFILE
        processReply = function(self, buf)
            --rf2.print("buf length: "..#buf)
            data.headspeed.value = rf2.mspHelper.readU16(buf)
            data.gain.value = rf2.mspHelper.readU8(buf)
            data.p_gain.value = rf2.mspHelper.readU8(buf)
            data.i_gain.value = rf2.mspHelper.readU8(buf)
            data.d_gain.value = rf2.mspHelper.readU8(buf)
            data.f_gain.value = rf2.mspHelper.readU8(buf)
            data.tta_gain.value = rf2.mspHelper.readU8(buf)
            data.tta_limit.value = rf2.mspHelper.readU8(buf)
            data.yaw_ff_weight.value = rf2.mspHelper.readU8(buf)
            data.cyclic_ff_weight.value = rf2.mspHelper.readU8(buf)
            data.collective_ff_weight.value = rf2.mspHelper.readU8(buf)
            data.max_throttle.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion >= 12.07 then
                data.min_throttle.value = rf2.mspHelper.readU8(buf)
            end
            callback(callbackParam)
        end,
        simulatorResponse = { 208, 7, 100, 10, 125, 5, 20, 0, 20, 10, 40, 100, 100, 10 }
    }
    rf2.mspQueue:add(message)
end

local function setGovernorProfile(data)
    local message = {
        command = 149, -- MSP_SET_GOVERNOR_PROFILE
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU16(message.payload, data.headspeed.value)
    rf2.mspHelper.writeU8(message.payload, data.gain.value)
    rf2.mspHelper.writeU8(message.payload, data.p_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.i_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.d_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.f_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.tta_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.tta_limit.value)
    rf2.mspHelper.writeU8(message.payload, data.yaw_ff_weight.value)
    rf2.mspHelper.writeU8(message.payload, data.cyclic_ff_weight.value)
    rf2.mspHelper.writeU8(message.payload, data.collective_ff_weight.value)
    rf2.mspHelper.writeU8(message.payload, data.max_throttle.value)
    if rf2.apiVersion >= 12.07 then
        rf2.mspHelper.writeU8(message.payload, data.min_throttle.value)
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