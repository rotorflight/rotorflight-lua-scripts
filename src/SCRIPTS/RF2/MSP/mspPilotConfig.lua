local function getPilotConfig(callback, callbackParam)
    local message = {
        command = 12, -- MSP_PILOT_CONFIG
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)
            config.model_id = { value = rf2.mspHelper.readU8(buf), min = 0, max = 99 }
            config.model_param1_type = { value = rf2.mspHelper.readU8(buf), min = 0, max = 12, table = { [0] = "NONE", "TIMER1", "TIMER2", "TIMER3", "GV1", "GV2", "GV3", "GV4", "GV5", "GV6", "GV7", "GV8", "GV9" } }
            config.model_param1_value = { value = rf2.mspHelper.readS16(buf), min = -32000, max = 32000 }
            config.model_param2_type = { value = rf2.mspHelper.readU8(buf), min = 0, max = 12, table = { [0] = "NONE", "TIMER1", "TIMER2", "TIMER3", "GV1", "GV2", "GV3", "GV4", "GV5", "GV6", "GV7", "GV8", "GV9" } }
            config.model_param2_value = { value = rf2.mspHelper.readS16(buf), min = -32000, max = 32000 }
            config.model_param3_type = { value = rf2.mspHelper.readU8(buf), min = 0, max = 12, table = { [0] = "NONE", "TIMER1", "TIMER2", "TIMER3", "GV1", "GV2", "GV3", "GV4", "GV5", "GV6", "GV7", "GV8", "GV9" } }
            config.model_param3_value = { value = rf2.mspHelper.readS16(buf), min = -32000, max = 32000 }
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
    getPilotConfig = getPilotConfig,
    setPilotConfig = setPilotConfig
}