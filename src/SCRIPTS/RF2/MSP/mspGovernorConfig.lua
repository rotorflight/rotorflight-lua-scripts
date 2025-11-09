local function getDefaults()
    local defaults = {}
    if rf2.apiVersion < 12.09 then
        defaults.gov_mode = { min = 0, max = 4, table = { [0] = "OFF", "PASSTHROUGH", "STANDARD", "MODE1", "MODE2" } }
    else
        defaults.gov_mode = { min = 0, max = 3, table = { [0] = "OFF", "EXTERNAL", "ELECTRIC", "NITRO" } }
    end
    defaults.gov_startup_time = { min = 0, max = 600, scale = 10, unit = rf2.units.seconds }
    defaults.gov_spoolup_time = { min = 0, max = 600, scale = 10, unit = rf2.units.seconds }
    defaults.gov_tracking_time = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_recovery_time = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    defaults.gov_throttle_hold_timeout = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
    if rf2.apiVersion < 12.09 then
        defaults.gov_lost_headspeed_timeout = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
        defaults.gov_autorotation_timeout = { min = 0, max = 600, scale = 10, unit = rf2.units.seconds }
        defaults.gov_autorotation_bailout_time = { min = 0, max = 100, scale = 10, unit = rf2.units.seconds }
        defaults.gov_autorotation_min_entry_time = { min = 0, max = 600, scale = 10, unit = rf2.units.seconds }
    end
    defaults.gov_handover_throttle = { min = 10, max = 50, unit = rf2.units.percentage }
    defaults.gov_pwr_filter = { min = 0, max = 250, unit = rf2.units.herz }
    defaults.gov_rpm_filter = { min = 0, max = 250, unit = rf2.units.herz }
    defaults.gov_tta_filter = { min = 0, max = 250, unit = rf2.units.herz }
    defaults.gov_ff_filter = { min = 0, max = 250, unit = rf2.units.herz }
    if rf2.apiVersion >= 12.08 and rf2.apiVersion < 12.09 then
        defaults.gov_spoolup_min_throttle = { min = 0, max = 50, unit = rf2.units.percentage }
    end
    if rf2.apiVersion >= 12.09 then
        defaults.gov_d_filter = { min = 0, max = 250, unit = rf2.units.herz }
        defaults.gov_spooldown_time = { min = 0, max = 600, scale = 10, unit = rf2.units.seconds }
        defaults.gov_throttle_type = { min = 0, max = 3, table = { [0] = "NORMAL", "OFF_ON", "OFF_IDLE_ON", "OFF_IDLE_AUTO_ON" } }
        defaults.gov_idle_collective = { min = -100, max = 100 }
        defaults.gov_wot_collective = { min = -100, max = 100 }
        defaults.gov_idle_throttle = { min = 0, max = 250, scale = 10, unit = rf2.units.percentage }
        defaults.gov_auto_throttle = { min = 0, max = 250, scale = 10, unit = rf2.units.percentage }
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
            data.gov_throttle_hold_timeout.value = rf2.mspHelper.readU16(buf)
            if rf2.apiVersion < 12.09 then
                data.gov_lost_headspeed_timeout.value = rf2.mspHelper.readU16(buf)
                data.gov_autorotation_timeout.value = rf2.mspHelper.readU16(buf)
                data.gov_autorotation_bailout_time.value = rf2.mspHelper.readU16(buf)
                data.gov_autorotation_min_entry_time.value = rf2.mspHelper.readU16(buf)
            else
                buf.offset = buf.offset + 4*2
            end
            data.gov_handover_throttle.value = rf2.mspHelper.readU8(buf)
            data.gov_pwr_filter.value = rf2.mspHelper.readU8(buf)
            data.gov_rpm_filter.value = rf2.mspHelper.readU8(buf)
            data.gov_tta_filter.value = rf2.mspHelper.readU8(buf)
            data.gov_ff_filter.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion >= 12.08 and rf2.apiVersion < 12.09 then
                data.gov_spoolup_min_throttle.value = rf2.mspHelper.readU8(buf)
            else
                buf.offset = buf.offset + 1
            end
            if rf2.apiVersion >= 12.09 then
                data.gov_d_filter.value = rf2.mspHelper.readU8(buf)
                data.gov_spooldown_time.value = rf2.mspHelper.readU16(buf)
                data.gov_throttle_type.value = rf2.mspHelper.readU8(buf)
                data.gov_idle_collective.value = rf2.mspHelper.readS8(buf)
                data.gov_wot_collective.value = rf2.mspHelper.readS8(buf)
                data.gov_idle_throttle.value = rf2.mspHelper.readU8(buf)
                data.gov_auto_throttle.value = rf2.mspHelper.readU8(buf)
            end
            callback(callbackParam, data)
        end,
        simulatorResponse = { 2, 200, 0, 100, 0, 20, 0, 20, 0, 30, 0, 10, 0, 0, 0, 0, 0, 50, 0, 10, 5, 10, 0, 10, 5,  0, 30, 0, 0, 161, 246, 0, 0 }
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
    rf2.mspHelper.writeU16(message.payload, config.gov_throttle_hold_timeout.value)
    if rf2.apiVersion < 12.09 then
        rf2.mspHelper.writeU16(message.payload, config.gov_lost_headspeed_timeout.value)
        rf2.mspHelper.writeU16(message.payload, config.gov_autorotation_timeout.value)
        rf2.mspHelper.writeU16(message.payload, config.gov_autorotation_bailout_time.value)
        rf2.mspHelper.writeU16(message.payload, config.gov_autorotation_min_entry_time.value)
    else
        rf2.mspHelper.writeU16(message.payload, 0)
        rf2.mspHelper.writeU16(message.payload, 0)
        rf2.mspHelper.writeU16(message.payload, 0)
        rf2.mspHelper.writeU16(message.payload, 0)
    end
    rf2.mspHelper.writeU8(message.payload, config.gov_handover_throttle.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_pwr_filter.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_rpm_filter.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_tta_filter.value)
    rf2.mspHelper.writeU8(message.payload, config.gov_ff_filter.value)
    if rf2.apiVersion >= 12.08 and rf2.apiVersion < 12.09 then
        rf2.mspHelper.writeU8(message.payload, config.gov_spoolup_min_throttle.value)
    else
        rf2.mspHelper.writeU8(message.payload, 0)
    end
    if rf2.apiVersion >= 12.09 then
        rf2.mspHelper.writeU8(message.payload, config.gov_d_filter.value)
        rf2.mspHelper.writeU16(message.payload, config.gov_spooldown_time.value)
        rf2.mspHelper.writeU8(message.payload, config.gov_throttle_type.value)
        rf2.mspHelper.writeU8(message.payload, config.gov_idle_collective.value)
        rf2.mspHelper.writeU8(message.payload, config.gov_wot_collective.value)
        rf2.mspHelper.writeU8(message.payload, config.gov_idle_throttle.value)
        rf2.mspHelper.writeU8(message.payload, config.gov_auto_throttle.value)
    end
    rf2.mspQueue:add(message)
end

return {
    read = getGovernorConfig,
    write = setGovernorConfig,
    getDefaults = getDefaults
}