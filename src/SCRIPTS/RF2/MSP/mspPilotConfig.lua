local function getDefaults()
    local defaults = {}
    defaults.model_id = { min = 0, max = 99 }
    local paramTypes = { [0] = "NONE", "TIMER1", "TIMER2", "TIMER3", "GV1", "GV2", "GV3", "GV4", "GV5", "GV6", "GV7", "GV8", "GV9" }
    defaults.model_param1_type = { min = 0, max = #paramTypes, table = paramTypes }
    defaults.model_param1_value = { min = -32000, max = 32000 }
    defaults.model_param2_type = { min = 0, max = #paramTypes, table = paramTypes }
    defaults.model_param2_value = { min = -32000, max = 32000 }
    defaults.model_param3_type = { min = 0, max = #paramTypes, table = paramTypes }
    defaults.model_param3_value = { min = -32000, max = 32000 }
    return defaults
end

local function getPilotConfig(callback, callbackParam, config)
    if not config then config = getDefaults() end
    local message = {
        command = 12, -- MSP_PILOT_CONFIG
        processReply = function(self, buf)
            config.model_id.value = rf2.mspHelper.readU8(buf)
            config.model_param1_type.value = rf2.mspHelper.readU8(buf)
            config.model_param1_value.value = rf2.mspHelper.readS16(buf)
            config.model_param2_type.value = rf2.mspHelper.readU8(buf)
            config.model_param2_value.value = rf2.mspHelper.readS16(buf)
            config.model_param3_type.value = rf2.mspHelper.readU8(buf)
            config.model_param3_value.value = rf2.mspHelper.readS16(buf)
            callback(callbackParam, config)
        end,
        simulatorResponse = { 21,  1, 240, 0,  0, 0, 0,  0, 0, 0 }
    }
    rf2.mspQueue:add(message)
end

local function setPilotConfig(config)
    local message = {
        command = 13, -- MSP_SET_PILOT_CONFIG
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, config.model_id.value)
    rf2.mspHelper.writeU8(message.payload, config.model_param1_type.value)
    rf2.mspHelper.writeU16(message.payload, config.model_param1_value.value)
    rf2.mspHelper.writeU8(message.payload, config.model_param2_type.value)
    rf2.mspHelper.writeU16(message.payload, config.model_param2_value.value)
    rf2.mspHelper.writeU8(message.payload, config.model_param3_type.value)
    rf2.mspHelper.writeU16(message.payload, config.model_param3_value.value)
    rf2.mspQueue:add(message)
end

return {
    read = getPilotConfig,
    write = setPilotConfig,
    getDefaults = getDefaults
}