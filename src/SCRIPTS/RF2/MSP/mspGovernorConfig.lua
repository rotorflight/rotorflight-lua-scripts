local function getGovernorConfig(callback, callbackParam)
    local message = {
        command = 142, -- MSP_GOVERNOR_CONFIG
        processReply = function(self, buf)
            local config = {}
            --rf2.print("buf length: "..#buf)
            config.gov_mode = { value = rf2.mspHelper.readU8(buf), min = 0, max = 4, table = { [0] = "OFF", "PASSTHROUGH", "STANDARD", "MODE1", "MODE2" } }
            config.gov_startup_time = { value = rf2.mspHelper.readU16(buf), min = 0, max = 600, scale = 10 }
            config.gov_spoolup_time = { value = rf2.mspHelper.readU16(buf), min = 0, max = 600, scale = 10 }
            config.gov_tracking_time = { value = rf2.mspHelper.readU16(buf), min = 0, max = 100, scale = 10 }
            config.gov_recovery_time = { value = rf2.mspHelper.readU16(buf), min = 0, max = 100, scale = 10 }
            config.gov_zero_throttle_timeout = { value = rf2.mspHelper.readU16(buf), min = 0, max = 100, scale = 10 }
            config.gov_lost_headspeed_timeout = { value = rf2.mspHelper.readU16(buf), min = 0, max = 100, scale = 10 }
            config.gov_autorotation_timeout = { value = rf2.mspHelper.readU16(buf), min = 0, max = 100, scale = 10 }
            config.gov_autorotation_bailout_time = { value = rf2.mspHelper.readU16(buf), min = 0, max = 100, scale = 10 }
            config.gov_autorotation_min_entry_time = { value = rf2.mspHelper.readU16(buf), min = 0, max = 100, scale = 10 }
            config.gov_handover_throttle = { value = rf2.mspHelper.readU8(buf), min = 10, max = 50 }
            config.gov_pwr_filter = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.gov_rpm_filter = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.gov_tta_filter = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            config.gov_ff_filter = { value = rf2.mspHelper.readU8(buf), min = 0, max = 250 }
            callback(callbackParam, config)
        end,
        simulatorResponse = { 3, 200, 0, 100, 0, 20, 0, 20, 0, 30, 0, 10, 0, 0, 0, 0, 0, 50, 0, 10, 5, 10, 0, 10 }
    }
    rf2.mspQueue:add(message)
end

local function setGovernorConfig(config)
    local message = {
        command = 143, -- MSP_SET_GOVERNOR_CONFIG
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, config.gov_mode.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_startup_time.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_spoolup_time.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_tracking_time.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_recovery_time.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_zero_throttle_timeout.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_lost_headspeed_timeout.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_autorotation_timeout.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_autorotation_bailout_time.value)
    rf2.mspHelper.writeU16(message.payload, config.gov_autorotation_min_entry_time.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_handover_throttle.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_pwr_filter.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_rpm_filter.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_tta_filter.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_ff_filter.value)
    rf2.mspQueue:add(message)
end

return {
    getGovernorConfig = getGovernorConfig,
    setGovernorConfig = setGovernorConfig
}