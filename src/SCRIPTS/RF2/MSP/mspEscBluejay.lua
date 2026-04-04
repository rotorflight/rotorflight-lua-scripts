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
    return {
        esc_signature = nil,
        esc_command = nil,
        main_revision = nil,
        sub_revision = nil,
        layout_revision = nil,
        reserved_03 = nil,
        startup_power_min = { min = 1000, max = 1125, mult = 5 },
        startup_beep = nil,
        dithering = nil,
        startup_power_max = { min = 1004, max = 1300, mult = 4 },
        reserved_08 = nil,
        rpm_power_slope = { min = 0, max = 255, table = rampupPower },
        pwm_frequency = nil,
        motor_direction = { min = 0, max = #motorDirection, table = motorDirection },
        reserved_0c = nil,
        mode_raw = nil,
        reserved_0f = nil,
        breaking_strength = { min = 0, max = 255 },
        reserved_11 = nil,
        reserved_12 = nil,
        reserved_13 = nil,
        reserved_14 = nil,
        commutation_timing = { min = 0, max = #commutationTiming, table = commutationTiming },
        reserved_16 = nil,
        reserved_17 = nil,
        reserved_18 = nil,
        reserved_19 = nil,
        reserved_1a = nil,
        beep_strength = { min = 1, max = 255 },
        beacon_strength = { min = 1, max = 255 },
        beacon_delay = { min = 0, max = #beaconDelay, table = beaconDelay },
        reserved_1e = nil,
        demag_compensation = { min = 0, max = #demagCompensation, table = demagCompensation },
        reserved_20 = nil,
        reserved_21 = nil,
        reserved_22 = nil,
        temperature_protection = { min = 0, max = #temperatureProtection, table = temperatureProtection },
        low_rpm_power_protection = { min = 0, max = #onOff, table = onOff },
        reserved_25 = nil,
        reserved_26 = nil,
        brake_on_stop = { min = 0, max = #onOff, table = onOff },
        led_control = nil,
        power_rating = { min = 0, max = #powerRating, table = powerRating },
        force_edt_arm = { min = 0, max = #onOff, table = edtOnOff },
        reserved_2b = nil,
        reserved_2c = nil,
        reserved_2d = nil,
        reserved_2e = nil,
        reserved_2f = nil,
        reserved_30 = nil,
        reserved_31 = nil,
        reserved_32 = nil,
        reserved_33 = nil,
        reserved_34 = nil,
        reserved_35 = nil,
        reserved_36 = nil,
        reserved_37 = nil,
        reserved_38 = nil,
        reserved_39 = nil,
        reserved_3a = nil,
        reserved_3b = nil,
        reserved_3c = nil,
        reserved_3d = nil,
        reserved_3e = nil,
        reserved_3f = nil,
    }
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
            data.reserved_11 = rf2.mspHelper.readU8(buf)
            data.reserved_12 = rf2.mspHelper.readU8(buf)
            data.reserved_13 = rf2.mspHelper.readU8(buf)
            data.reserved_14 = rf2.mspHelper.readU8(buf)
            data.commutation_timing.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_16 = rf2.mspHelper.readU8(buf)
            data.reserved_17 = rf2.mspHelper.readU8(buf)
            data.reserved_18 = rf2.mspHelper.readU8(buf)
            data.reserved_19 = rf2.mspHelper.readU8(buf)
            data.reserved_1a = rf2.mspHelper.readU8(buf)
            data.beep_strength.value = rf2.mspHelper.readU8(buf)
            data.beacon_strength.value = rf2.mspHelper.readU8(buf)
            data.beacon_delay.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_1e = rf2.mspHelper.readU8(buf)
            data.demag_compensation.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_20 = rf2.mspHelper.readU8(buf)
            data.reserved_21 = rf2.mspHelper.readU8(buf)
            data.reserved_22 = rf2.mspHelper.readU8(buf)
            data.temperature_protection.value = rf2.mspHelper.readU8(buf)
            data.low_rpm_power_protection.value = rf2.mspHelper.readU8(buf) - 1
            data.reserved_25 = rf2.mspHelper.readU8(buf)
            data.reserved_26 = rf2.mspHelper.readU8(buf)
            data.brake_on_stop.value = rf2.mspHelper.readU8(buf)
            data.led_control = rf2.mspHelper.readU8(buf)
            data.power_rating.value = rf2.mspHelper.readU8(buf) - 1
            data.force_edt_arm.value = rf2.mspHelper.readU8(buf)
            data.reserved_2b = rf2.mspHelper.readU8(buf)
            data.reserved_2c = rf2.mspHelper.readU8(buf)
            data.reserved_2d = rf2.mspHelper.readU8(buf)
            data.reserved_2e = rf2.mspHelper.readU8(buf)
            data.reserved_2f = rf2.mspHelper.readU8(buf)
            data.reserved_30 = rf2.mspHelper.readU8(buf)
            data.reserved_31 = rf2.mspHelper.readU8(buf)
            data.reserved_32 = rf2.mspHelper.readU8(buf)
            data.reserved_33 = rf2.mspHelper.readU8(buf)
            data.reserved_34 = rf2.mspHelper.readU8(buf)
            data.reserved_35 = rf2.mspHelper.readU8(buf)
            data.reserved_36 = rf2.mspHelper.readU8(buf)
            data.reserved_37 = rf2.mspHelper.readU8(buf)
            data.reserved_38 = rf2.mspHelper.readU8(buf)
            data.reserved_39 = rf2.mspHelper.readU8(buf)
            data.reserved_3a = rf2.mspHelper.readU8(buf)
            data.reserved_3b = rf2.mspHelper.readU8(buf)
            data.reserved_3c = rf2.mspHelper.readU8(buf)
            data.reserved_3d = rf2.mspHelper.readU8(buf)
            data.reserved_3e = rf2.mspHelper.readU8(buf)
            data.reserved_3f = rf2.mspHelper.readU8(buf)

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
    rf2.mspHelper.writeU8(message.payload, data.reserved_11)
    rf2.mspHelper.writeU8(message.payload, data.reserved_12)
    rf2.mspHelper.writeU8(message.payload, data.reserved_13)
    rf2.mspHelper.writeU8(message.payload, data.reserved_14)
    rf2.mspHelper.writeU8(message.payload, data.commutation_timing.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.reserved_16)
    rf2.mspHelper.writeU8(message.payload, data.reserved_17)
    rf2.mspHelper.writeU8(message.payload, data.reserved_18)
    rf2.mspHelper.writeU8(message.payload, data.reserved_19)
    rf2.mspHelper.writeU8(message.payload, data.reserved_1a)
    rf2.mspHelper.writeU8(message.payload, data.beep_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.beacon_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.beacon_delay.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.reserved_1e)
    rf2.mspHelper.writeU8(message.payload, data.demag_compensation.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.reserved_20)
    rf2.mspHelper.writeU8(message.payload, data.reserved_21)
    rf2.mspHelper.writeU8(message.payload, data.reserved_22)
    rf2.mspHelper.writeU8(message.payload, data.temperature_protection.value)
    rf2.mspHelper.writeU8(message.payload, data.low_rpm_power_protection.value)
    rf2.mspHelper.writeU8(message.payload, data.reserved_25)
    rf2.mspHelper.writeU8(message.payload, data.reserved_26)
    rf2.mspHelper.writeU8(message.payload, data.brake_on_stop.value)
    rf2.mspHelper.writeU8(message.payload, data.led_control)
    rf2.mspHelper.writeU8(message.payload, data.power_rating.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.force_edt_arm.value)
    rf2.mspHelper.writeU8(message.payload, data.reserved_2c)
    rf2.mspHelper.writeU8(message.payload, data.reserved_2d)
    rf2.mspHelper.writeU8(message.payload, data.reserved_2e)
    rf2.mspHelper.writeU8(message.payload, data.reserved_2f)
    rf2.mspHelper.writeU8(message.payload, data.reserved_30)
    rf2.mspHelper.writeU8(message.payload, data.reserved_31)
    rf2.mspHelper.writeU8(message.payload, data.reserved_32)
    rf2.mspHelper.writeU8(message.payload, data.reserved_33)
    rf2.mspHelper.writeU8(message.payload, data.reserved_34)
    rf2.mspHelper.writeU8(message.payload, data.reserved_35)
    rf2.mspHelper.writeU8(message.payload, data.reserved_36)
    rf2.mspHelper.writeU8(message.payload, data.reserved_37)
    rf2.mspHelper.writeU8(message.payload, data.reserved_38)
    rf2.mspHelper.writeU8(message.payload, data.reserved_39)
    rf2.mspHelper.writeU8(message.payload, data.reserved_3a)
    rf2.mspHelper.writeU8(message.payload, data.reserved_3b)
    rf2.mspHelper.writeU8(message.payload, data.reserved_3c)
    rf2.mspHelper.writeU8(message.payload, data.reserved_3d)
    rf2.mspHelper.writeU8(message.payload, data.reserved_3e)
    rf2.mspHelper.writeU8(message.payload, data.reserved_3f)

    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}









