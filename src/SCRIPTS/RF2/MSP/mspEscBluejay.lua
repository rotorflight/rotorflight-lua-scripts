local onOff = {
    [0] = "Off",
    "On",
}

local motorDirection = {
    [0] = "Normal",
    "Reversed",
    "Forward/Reverse (3D)",
    "Forward/Reverse (3D) Rev",
}

local commutationTiming = {
    [0] = "Low",
    "Medium Low",
    "Medium",
    "Medium High",
    "High",
}

local demagCompensation = {
    [0] = "Off",
    "Low",
    "High",
}

local beaconDelay = {
    [0] = "1 minute",
    "2 minutes",
    "5 minutes",
    "10 minutes",
    "Infinite",
}

local temperatureProtection = {
    [0] = "Disabled",
    "80 C",
    "90 C",
    "100 C",
    "110 C",
    "120 C",
    "130 C",
    "140 C",
}

local rampupPower = {
    [0] = "Off",
    "1x (More protection)",
    "2x",
    "3x",
    "4x",
    "5x",
    "6x",
    "7x",
    "8x",
    "9x",
    "10x",
    "11x",
    "12x",
    "13x (Less protection)"
}

local edtOnOff = {
    [100] = "Off",
    [1] = "On",
}

local powerRating = { [0] = "1S", "2S+"}

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

local function getFirmwareVersion(major, minor)
    if not(major and minor) then return "UNKNOWN" end
    return string.format("Firmware: %d.%d", major, minor)
end

local function normalizeStartupPowerMin(raw)
    if raw == nil then return nil end
    return math.floor((raw * 1000 / 2047) + 1000 + 0.5)
end

local function encodeStartupPowerMin(value)
    if value == nil then return nil end
    return clamp(math.floor(((value - 1000) * 2047) / 1000 + 0.5), 0, 255)
end

local function normalizeStartupPowerMax(raw)
    if raw == nil then return nil end
    return math.floor((raw * 1000 / 250) + 1000 + 0.5)
end

local function encodeStartupPowerMax(value)
    if value == nil then return nil end
    return clamp(math.floor(((value - 1000) * 250) / 1000 + 0.5), 0, 255)
end

local function getDefaults()
    local d = {}
	d.esc_signature = nil
	d.esc_command = nil
	d.main_revision = nil
	d.sub_revision = nil
	d.layout_revision = nil
	d.reserved_03 = nil
	d.startup_power_min = { min = 1000, max = 1125, mult = 5 }
	d.startup_beep = nil
	d.dithering = nil
	d.startup_power_max = { min = 1004, max = 1300, mult = 4 }
	d.reserved_08 = nil
	d.rpm_power_slope = { min = 0, max = 255, table = rampupPower }
	d.pwm_frequency = nil
	d.motor_direction = { min = 0, max = #motorDirection, table = motorDirection }
	d.reserved_0c = nil
	d.mode_raw = nil
	d.reserved_0f = nil
	d.breaking_strength = { min = 0, max = 255 }
	d.reserved_11_14 = nil
	d.commutation_timing = { min = 0, max = #commutationTiming, table = commutationTiming }
	d.reserved_16_19 = nil
	d.reserved_1a = nil
	d.beep_strength = { min = 1, max = 255 }
	d.beacon_strength = { min = 1, max = 255 }
	d.beacon_delay = { min = 0, max = #beaconDelay, table = beaconDelay }
	d.reserved_1e = nil
	d.demag_compensation = { min = 0, max = #demagCompensation, table = demagCompensation }
	d.reserved_20_21 = nil
	d.reserved_22 = nil
	d.temperature_protection = { min = 0, max = #temperatureProtection, table = temperatureProtection }
	d.low_rpm_power_protection = { min = 0, max = #onOff, table = onOff }
	d.reserved_25_26 = nil
	d.brake_on_stop = { min = 0, max = #onOff, table = onOff }
	d.led_control = nil
	d.power_rating = { min = 0, max = #powerRating, table = powerRating }
	d.force_edt_arm = { min = 0, max = #onOff, table = edtOnOff }
	d.reserved_2b = nil
	d.reserved_2c_2f = nil
	d.reserved_30_33 = nil
	d.reserved_34_37 = nil
	d.reserved_38_3b = nil
	d.reserved_3c_3f = nil
    return d
end

local function getEscParameters(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        retryDelay = 2,
        processReply = function(self, buf)
            local signature = rf2.mspHelper.readU8(buf)
            if signature ~= 193 then
                return
            end

            data.esc_signature = signature
            data.esc_command = rf2.mspHelper.readU8(buf)
            data.main_revision = rf2.mspHelper.readU8(buf)
            if data.main_revision ~= 0 then
                return
            end
            data.sub_revision = rf2.mspHelper.readU8(buf)
            data.layout_revision = rf2.mspHelper.readU8(buf)
            data.reserved_03 = rf2.mspHelper.readU8(buf)
            data.startup_power_min.value = normalizeStartupPowerMin(rf2.mspHelper.readU8(buf))
            data.startup_beep = rf2.mspHelper.readU8(buf)
            data.dithering = rf2.mspHelper.readU8(buf)
            data.startup_power_max.value = normalizeStartupPowerMax(rf2.mspHelper.readU8(buf))
            data.reserved_08 = rf2.mspHelper.readU8(buf)
            data.rpm_power_slope.value = rf2.mspHelper.readU8(buf)
            data.pwm_frequency = rf2.mspHelper.readU8(buf)
            data.motor_direction.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_0c = rf2.mspHelper.readU8(buf)
            data.mode_raw = rf2.mspHelper.readU16(buf)
            data.reserved_0f = rf2.mspHelper.readU8(buf)
            data.breaking_strength.value = rf2.mspHelper.readU8(buf)
            data.reserved_11_14 = rf2.mspHelper.readU32(buf)
            data.commutation_timing.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_16_19 = rf2.mspHelper.readU32(buf)
            data.reserved_1a = rf2.mspHelper.readU8(buf)
            data.beep_strength.value = rf2.mspHelper.readU8(buf)
            data.beacon_strength.value = rf2.mspHelper.readU8(buf)
            data.beacon_delay.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_1e = rf2.mspHelper.readU8(buf)
            data.demag_compensation.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_20_21 = rf2.mspHelper.readU16(buf)
            data.reserved_22 = rf2.mspHelper.readU8(buf)
            data.temperature_protection.value = rf2.mspHelper.readU8(buf)
            data.low_rpm_power_protection.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_25_26 = rf2.mspHelper.readU16(buf)
            data.brake_on_stop.value = rf2.mspHelper.readU8(buf)
            data.led_control = rf2.mspHelper.readU8(buf)
            data.power_rating.value = rf2.mspHelper.readU8(buf) - 1
            data.force_edt_arm.value = rf2.mspHelper.readU8(buf)
            data.reserved_2b = rf2.mspHelper.readU8(buf)
            data.reserved_2c_2f = rf2.mspHelper.readU32(buf)
            data.reserved_30_33 = rf2.mspHelper.readU32(buf)
            data.reserved_34_37 = rf2.mspHelper.readU32(buf)
            data.reserved_38_3b = rf2.mspHelper.readU32(buf)
            data.reserved_3c_3f = rf2.mspHelper.readU32(buf)

            -- Derived fields
            data.firmwareVersion = getFirmwareVersion(data.main_revision, data.sub_revision)

            callback(callbackParam, data)
        end,

        simulatorResponse =   { 193, 0, 0, 21, 208, 255, 102, 1, 255, 50, 255, 9, 24, 2, 255, 85, 170, 255, 0, 255, 255, 255, 255, 4, 255, 255, 255, 255, 255, 40, 80, 4, 255, 2, 255, 255, 255, 0, 255, 255, 255, 0, 0, 2, 100, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 },
        --simulatorResponse = { 193, 0, 0, 21, 208, 255, 40, 1, 255, 60, 255, 0, 24, 1, 255, 85, 170, 255, 122, 255, 255, 255, 255, 1, 255, 255, 255, 255, 255, 147, 168, 4, 255, 3, 255, 255, 255, 4, 255, 255, 255, 1, 0, 2, 100, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 },
    }
    rf2.mspQueue:add(message)
end

local function setEscParameters(data)
    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        retryDelay = 1,
        postSendDelay = 2,
        payload = {}
    }

    rf2.mspHelper.writeU8(message.payload, data.esc_signature)
    rf2.mspHelper.writeU8(message.payload, data.esc_command)
    rf2.mspHelper.writeU8(message.payload, data.main_revision)
    rf2.mspHelper.writeU8(message.payload, data.sub_revision)
    rf2.mspHelper.writeU8(message.payload, data.layout_revision)
    rf2.mspHelper.writeU8(message.payload, data.reserved_03)
    rf2.mspHelper.writeU8(message.payload, encodeStartupPowerMin(data.startup_power_min.value))
    rf2.mspHelper.writeU8(message.payload, data.startup_beep)
    rf2.mspHelper.writeU8(message.payload, data.dithering)
    rf2.mspHelper.writeU8(message.payload, encodeStartupPowerMax(data.startup_power_max.value))
    rf2.mspHelper.writeU8(message.payload, data.reserved_08)
    rf2.mspHelper.writeU8(message.payload, data.rpm_power_slope.value)
    rf2.mspHelper.writeU8(message.payload, data.pwm_frequency)
    rf2.mspHelper.writeU8(message.payload, data.motor_direction.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.reserved_0c)
    rf2.mspHelper.writeU16(message.payload, data.mode_raw)
    rf2.mspHelper.writeU8(message.payload, data.reserved_0f)
    rf2.mspHelper.writeU8(message.payload, data.breaking_strength.value)
    rf2.mspHelper.writeU32(message.payload, data.reserved_11_14)
    rf2.mspHelper.writeU8(message.payload, data.commutation_timing.value + 1)
    rf2.mspHelper.writeU32(message.payload, data.reserved_16_19)
    rf2.mspHelper.writeU8(message.payload, data.reserved_1a)
    rf2.mspHelper.writeU8(message.payload, data.beep_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.beacon_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.beacon_delay.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.reserved_1e)
    rf2.mspHelper.writeU8(message.payload, data.demag_compensation.value + 1)
    rf2.mspHelper.writeU16(message.payload, data.reserved_20_21)
    rf2.mspHelper.writeU8(message.payload, data.reserved_22)
    rf2.mspHelper.writeU8(message.payload, data.temperature_protection.value)
    rf2.mspHelper.writeU8(message.payload, data.low_rpm_power_protection.value)
    rf2.mspHelper.writeU16(message.payload, data.reserved_25_26)
    rf2.mspHelper.writeU8(message.payload, data.brake_on_stop.value)
    rf2.mspHelper.writeU8(message.payload, data.led_control)
    rf2.mspHelper.writeU8(message.payload, data.power_rating.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.force_edt_arm.value)
    rf2.mspHelper.writeU8(message.payload, data.reserved_2b)
    rf2.mspHelper.writeU32(message.payload, data.reserved_2c_2f)
    rf2.mspHelper.writeU32(message.payload, data.reserved_30_33)
    rf2.mspHelper.writeU32(message.payload, data.reserved_34_37)
    rf2.mspHelper.writeU32(message.payload, data.reserved_38_3b)
    rf2.mspHelper.writeU32(message.payload, data.reserved_3c_3f)

    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}









