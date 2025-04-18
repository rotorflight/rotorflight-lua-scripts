local function getDefaults()
    local defaults = {}
    defaults.gov_mode = { min = 0, max = 4, table = { [0] = "OFF", "PASSTHROUGH", "STANDARD", "MODE1", "MODE2" } }
    defaults.gov_startup_time = { min = 0, max = 600, scale = 10, unit = rf2.units.seconds }
    defaults.gov_spoolup_time = { min = 0, max = 600, scale = 10, unit = rf2.units.seconds }
    defaults.gov_tracking_time = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_recovery_time = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_zero_throttle_timeout = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_lost_headspeed_timeout = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_autorotation_timeout = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_autorotation_bailout_time = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_autorotation_min_entry_time = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_handover_throttle = { min = 10, max = 50, unit = rf2.units.percentage }
    defaults.gov_pwr_filter = { min = 0, max = 250, unit = rf2.units.herz }
    defaults.gov_rpm_filter = { min = 0, max = 250, unit = rf2.units.herz }
    defaults.gov_tta_filter = { min = 0, max = 250, unit = rf2.units.herz }
    defaults.gov_ff_filter = { min = 0, max = 250, unit = rf2.units.herz }
    if rf2.apiVersion >= 12.08 then
        defaults.gov_spoolup_min_throttle = { min = 0, max = 50, unit = rf2.units.percentage }
    end
    return defaults
end

local function getGovernorConfig(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 142, -- MSP_GOVERNOR_CONFIG
        processReply = function(self, buf)
            data.gov_mode.value = rf2.mspHelper.readU8(buf)
            data.gov_startup_time.value = rf2.mspHelper.readU16(buf)
            data.gov_spoolup_time.value = rf2.mspHelper.readU16(buf)
            data.gov_tracking_time.value = rf2.mspHelper.readU16(buf)
            data.gov_recovery_time.value = rf2.mspHelper.readU16(buf)
            data.gov_zero_throttle_timeout.value = rf2.mspHelper.readU16(buf)
            data.gov_lost_headspeed_timeout.value = rf2.mspHelper.readU16(buf)
            data.gov_autorotation_timeout.value = rf2.mspHelper.readU16(buf)
            data.gov_autorotation_bailout_time.value = rf2.mspHelper.readU16(buf)
            data.gov_autorotation_min_entry_time.value = rf2.mspHelper.readU16(buf)
            data.gov_handover_throttle.value = rf2.mspHelper.readU8(buf)
            data.gov_pwr_filter.value = rf2.mspHelper.readU8(buf)
            data.gov_rpm_filter.value = rf2.mspHelper.readU8(buf)
            data.gov_tta_filter.value = rf2.mspHelper.readU8(buf)
            data.gov_ff_filter.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion >= 12.08 then
                data.gov_spoolup_min_throttle.value = rf2.mspHelper.readU8(buf)
            end
            callback(callbackParam, data)
        end,
        simulatorResponse = { 3, 200, 0, 100, 0, 20, 0, 20, 0, 30, 0, 10, 0, 0, 0, 0, 0, 50, 0, 10, 5, 10, 0, 10, 5 }
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
    if rf2.apiVersion >= 12.08 then
        rf2.mspHelper.writeU8(message.payload, config.gov_spoolup_min_throttle.value)
    end
rf2.mspQueue:add(message)
end

return {
    read = getGovernorConfig,
    write = setGovernorConfig,
    getDefaults = getDefaults
}