local onOff = {
    [0] = "Off",
    "On",
}

local startupPower = {
    [0] = "0.031",
    "0.047",
    "0.063",
    "0.094",
    "0.125",
    "0.188",
    "0.25",
    "0.38",
    "0.50",
    "0.75",
    "1.00",
    "1.25",
    "1.50",
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

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

local function normalizePpm(raw)
    if raw == nil then return nil end
    return raw * 4 + 1000
end

local function encodePpm(value)
    if value == nil then return nil end
    return clamp(math.floor(((value - 1000) / 4) + 0.5), 0, 255)
end

local function getFirmwareVersion(major, minor)
    if not(major and minor) then return "UNKNOWN" end
    return string.format("Firmware: %d.%d", major, minor)
end

local function getDefaults()
    return {
        esc_signature = nil,
        esc_command = nil,
        main_revision = nil,
        sub_revision = nil,
        layout_revision = nil,
        p_gain = nil,
        i_gain = nil,
        governor_mode = nil,
        low_voltage_limit = nil,
        motor_gain = nil,
        motor_idle = nil,
        startup_power = { min = 0, max = #startupPower, table = startupPower },
        pwm_frequency = nil,
        motor_direction = { min = 0, max = #motorDirection, table = motorDirection },
        input_pwm_polarity = nil,
        mode_raw = nil,
        programming_by_tx = { min = 0, max = #onOff, table = onOff },
        rearm_at_start = nil,
        governor_setup_target = nil,
        startup_rpm = nil,
        startup_acceleration = nil,
        volt_comp = nil,
        commutation_timing = { min = 0, max = #commutationTiming, table = commutationTiming },
        damping_force = nil,
        governor_range = nil,
        startup_method = nil,
        ppm_min_throttle = { min = 1000, max = 1500 },
        ppm_max_throttle = { min = 1504, max = 2020 },
        beep_strength = { min = 1, max = 255 },
        beacon_strength = { min = 1, max = 255 },
        beacon_delay = { min = 0, max = #beaconDelay, table = beaconDelay },
        throttle_rate = nil,
        demag_compensation = { min = 0, max = #demagCompensation, table = demagCompensation },
        bec_voltage = nil,
        ppm_center_throttle = { min = 1000, max = 2020 },
        spoolup_time = nil,
        temperature_protection = { min = 0, max = #temperatureProtection, table = temperatureProtection },
        low_rpm_power_protection = { min = 0, max = #onOff, table = onOff },
        pwm_input = nil,
        pwm_dither = nil,
        brake_on_stop = { min = 0, max = #onOff, table = onOff },
        led_control = nil,
        reserved_29 = nil,
        reserved_2a = nil,
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
            if data.main_revision ~= 16 then
                return
            end
            data.sub_revision = rf2.mspHelper.readU8(buf)
            data.layout_revision = rf2.mspHelper.readU8(buf)
            data.p_gain = rf2.mspHelper.readU8(buf)
            data.i_gain = rf2.mspHelper.readU8(buf)
            data.governor_mode = rf2.mspHelper.readU8(buf)
            data.low_voltage_limit = rf2.mspHelper.readU8(buf)
            data.motor_gain = rf2.mspHelper.readU8(buf)
            data.motor_idle = rf2.mspHelper.readU8(buf)
            data.startup_power.value = rf2.mspHelper.readU8(buf) - 1
            data.pwm_frequency = rf2.mspHelper.readU8(buf)
            data.motor_direction.value = rf2.mspHelper.readU8(buf) - 1
            data.input_pwm_polarity = rf2.mspHelper.readU8(buf)
            data.mode_raw = rf2.mspHelper.readU16(buf)
            data.programming_by_tx.value = rf2.mspHelper.readU8(buf)
            data.rearm_at_start = rf2.mspHelper.readU8(buf)
            data.governor_setup_target = rf2.mspHelper.readU8(buf)
            data.startup_rpm = rf2.mspHelper.readU8(buf)
            data.startup_acceleration = rf2.mspHelper.readU8(buf)
            data.volt_comp = rf2.mspHelper.readU8(buf)
            data.commutation_timing.value = rf2.mspHelper.readU8(buf) - 1
            data.damping_force = rf2.mspHelper.readU8(buf)
            data.governor_range = rf2.mspHelper.readU8(buf)
            data.startup_method = rf2.mspHelper.readU8(buf)
            data.ppm_min_throttle.value = normalizePpm(rf2.mspHelper.readU8(buf))
            data.ppm_max_throttle.value = normalizePpm(rf2.mspHelper.readU8(buf))
            data.beep_strength.value = rf2.mspHelper.readU8(buf)
            data.beacon_strength.value = rf2.mspHelper.readU8(buf)
            data.beacon_delay.value = rf2.mspHelper.readU8(buf) - 1
            data.throttle_rate = rf2.mspHelper.readU8(buf)
            data.demag_compensation.value = rf2.mspHelper.readU8(buf) - 1
            data.bec_voltage = rf2.mspHelper.readU8(buf)
            data.ppm_center_throttle.value = normalizePpm(rf2.mspHelper.readU8(buf))
            data.spoolup_time = rf2.mspHelper.readU8(buf)
            data.temperature_protection.value = rf2.mspHelper.readU8(buf)
            data.low_rpm_power_protection.value = rf2.mspHelper.readU8(buf)
            data.pwm_input = rf2.mspHelper.readU8(buf)
            data.pwm_dither = rf2.mspHelper.readU8(buf)
            data.brake_on_stop.value = rf2.mspHelper.readU8(buf)
            data.led_control = rf2.mspHelper.readU8(buf)
            data.reserved_29 = rf2.mspHelper.readU8(buf)
            data.reserved_2a = rf2.mspHelper.readU8(buf)
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

        --simulatorResponseBluejay = { 193, 0, 0, 21, 208, 255, 102, 1, 255, 50, 255, 9, 24, 2, 255, 85, 170, 255, 0, 255, 255, 255, 255, 4, 255, 255, 255, 255, 255, 40, 80, 4, 255, 2, 255, 255, 255, 0, 255, 255, 255, 0, 0, 2, 100, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 }
        simulatorResponse = { 193, 0, 16, 7, 33, 255, 255, 255, 255, 255, 255, 10, 255, 3, 255, 85, 170, 1, 255, 255, 255, 255, 255, 3, 255, 255, 255, 37, 208, 40, 80, 4, 255, 2, 255, 122, 255, 7, 1, 255, 255, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 }
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
    rf2.mspHelper.writeU8(message.payload, data.p_gain)
    rf2.mspHelper.writeU8(message.payload, data.i_gain)
    rf2.mspHelper.writeU8(message.payload, data.governor_mode)
    rf2.mspHelper.writeU8(message.payload, data.low_voltage_limit)
    rf2.mspHelper.writeU8(message.payload, data.motor_gain)
    rf2.mspHelper.writeU8(message.payload, data.motor_idle)
    rf2.mspHelper.writeU8(message.payload, data.startup_power.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.pwm_frequency)
    rf2.mspHelper.writeU8(message.payload, data.motor_direction.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.input_pwm_polarity)
    rf2.mspHelper.writeU16(message.payload, data.mode_raw)
    rf2.mspHelper.writeU8(message.payload, data.programming_by_tx.value)
    rf2.mspHelper.writeU8(message.payload, data.rearm_at_start)
    rf2.mspHelper.writeU8(message.payload, data.governor_setup_target)
    rf2.mspHelper.writeU8(message.payload, data.startup_rpm)
    rf2.mspHelper.writeU8(message.payload, data.startup_acceleration)
    rf2.mspHelper.writeU8(message.payload, data.volt_comp)
    rf2.mspHelper.writeU8(message.payload, data.commutation_timing.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.damping_force)
    rf2.mspHelper.writeU8(message.payload, data.governor_range)
    rf2.mspHelper.writeU8(message.payload, data.startup_method)
    rf2.mspHelper.writeU8(message.payload, encodePpm(data.ppm_min_throttle.value))
    rf2.mspHelper.writeU8(message.payload, encodePpm(data.ppm_max_throttle.value))
    rf2.mspHelper.writeU8(message.payload, data.beep_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.beacon_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.beacon_delay.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.throttle_rate)
    rf2.mspHelper.writeU8(message.payload, data.demag_compensation.value + 1)
    rf2.mspHelper.writeU8(message.payload, data.bec_voltage)
    rf2.mspHelper.writeU8(message.payload, encodePpm(data.ppm_center_throttle.value))
    rf2.mspHelper.writeU8(message.payload, data.spoolup_time)
    rf2.mspHelper.writeU8(message.payload, data.temperature_protection.value)
    rf2.mspHelper.writeU8(message.payload, data.low_rpm_power_protection.value)
    rf2.mspHelper.writeU8(message.payload, data.pwm_input)
    rf2.mspHelper.writeU8(message.payload, data.pwm_dither)
    rf2.mspHelper.writeU8(message.payload, data.brake_on_stop.value)
    rf2.mspHelper.writeU8(message.payload, data.led_control)
    rf2.mspHelper.writeU8(message.payload, data.reserved_29)
    rf2.mspHelper.writeU8(message.payload, data.reserved_2a)
    rf2.mspHelper.writeU8(message.payload, data.reserved_2b)
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









