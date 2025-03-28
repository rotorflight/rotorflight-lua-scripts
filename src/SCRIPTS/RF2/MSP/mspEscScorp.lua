local flightMode = {
    [0] = "Heli Governor",
    "Heli Governor (stored)",
    "VBar Governor",
    "External Governor",
    "Airplane mode",
    "Boat mode",
    "Quad mode",
}

local becVoltage = {
    [0] = "5.1V",
    "6.1V",
    "7.3V",
    "8.3V",
    "Disabled",
}

local rotation = {
    [0] = "CCW",
    "CW",
}

local teleProtocol = {
    [0] = "Standard",
    "VBar",
    "Jeti Exbus",
    "Unsolicited",
    "Futaba SBUS",
}

local onOff = {
    [0] = "On",
    "Off"
}

local function getDefaults()
    return {
        esc_signature = nil,
        command = nil,
        esc_type_name = nil,
        flight_mode = { min = 0, max = #flightMode, table = flightMode },
        bec_voltage = { min = 0, max = #becVoltage, table = becVoltage },
        rotation = { min = 0, max = #rotation, table = rotation },
        telemetry_protocol = { min = 0, max = #teleProtocol, table = teleProtocol },
        protection_delay = { min = 0, max = 5000,  scale = 1000, mult = 100, unit = rf2.units.seconds },
        min_voltage = { min = 0, max = 7000,  scale = 100,  mult = 10 },
        max_temp = { min = 0, max = 40000, scale = 100,  mult = 100 },
        max_current = { min = 0, max = 30000, scale = 100,  mult = 100 },
        cutoff_handling = { min = 0, max = 10000, scale = 100,  mult = 100, unit = rf2.units.percentage },
        max_ah_used = { min = 0, max = 6000,  scale = 100,  mult = 10 },
        startup_sound = { min = 0, max = #onOff, table = onOff },
        serial_number = nil,
        firmware_version = nil,
        start_time = { min = 0, max = 60000,  scale = 1000, mult = 100, unit = rf2.units.seconds },
        runup_time = { min = 0, max = 60000,  scale = 1000, mult = 100, unit = rf2.units.seconds },
        bailout = { min = 0, max = 100000, scale = 1000, mult = 100, unit = rf2.units.seconds },
        p_gain = { min = 0, max = 180, scale = 100 },
        i_gain = { min = 0, max = 250, scale = 100 },
        stick_max = nil,
        stick_zero = nil
    }
end

local function getEscParameters(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        processReply = function(self, buf)
            local signature = rf2.mspHelper.readU8(buf)
            if signature ~= 83 then
                --rf2.print("warning: Invalid ESC signature: " .. signature)
                return
            end
            data.esc_signature = signature
            data.command = rf2.mspHelper.readU8(buf)
            data.esc_type_name = rf2.mspHelper.readText(buf, 32)
            data.flight_mode.value = rf2.mspHelper.readU16(buf)
            data.bec_voltage.value = rf2.mspHelper.readU16(buf)
            data.rotation.value = rf2.mspHelper.readU16(buf)
            data.telemetry_protocol.value = rf2.mspHelper.readU16(buf)
            data.protection_delay.value = rf2.mspHelper.readU16(buf)
            data.min_voltage.value = rf2.mspHelper.readU16(buf)
            data.max_temp.value = rf2.mspHelper.readU16(buf)
            data.max_current.value = rf2.mspHelper.readU16(buf)
            data.cutoff_handling.value = rf2.mspHelper.readU16(buf)
            data.max_ah_used.value = rf2.mspHelper.readU16(buf)
            data.startup_sound.value = rf2.mspHelper.readU16(buf)
            data.serial_number = rf2.mspHelper.readU32(buf)
            data.firmware_version = rf2.mspHelper.readU16(buf)
            data.start_time.value = rf2.mspHelper.readU16(buf)
            data.runup_time.value = rf2.mspHelper.readU16(buf)
            data.bailout.value = rf2.mspHelper.readU16(buf)
            data.p_gain.value = rf2.mspHelper.readU32(buf)
            data.i_gain.value = rf2.mspHelper.readU32(buf)
            data.stick_max = rf2.mspHelper.readU32(buf)
            data.stick_zero = rf2.mspHelper.readU32(buf)
            callback(callbackParam, data)
        end,
        simulatorResponse = { 83, 128, 84, 114, 105, 98, 117, 110, 117, 115, 32, 69, 83, 67, 45, 54, 83, 45, 56, 48, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 3, 0, 3, 0, 1, 0, 3, 0, 136, 19, 22, 3, 16, 39, 64, 31, 136, 19, 0, 0, 1, 0, 7, 2, 0, 6, 63, 0, 160, 15, 64, 31, 208, 7, 100, 0, 0, 0, 200, 0, 0, 0, 1, 0, 0, 0, 200, 250, 0, 0 },
        --[[
        simulatorResponse = {
            83,  -- signature
            128, -- command
            84, 114, 105, 98, 117, 110, 117, 115, 32, 69, 83, 67, 45, 54, 83, 45, 56, 48, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, -- esc type name
            3, 0, -- flight mode
            3, 0, -- bec voltage
            1, 0, -- rotation
            3, 0, -- telemetry protocol
            136, 19, -- protection delay
            22, 3, -- min voltage
            16, 39, --max temp
            64, 31, -- max current
            136, 19, -- cutoff handling
            0, 0, -- max ah used
            1, 0, -- startup sound
            7, 2, 0, 6, -- serial number
            63, 0, -- firmware version
            160, 15, -- start time
            64, 31, --runup time
            208, 7, --bailout
            100, 0, 0, 0, -- p-gain
            200, 0, 0, 0, -- i-gain
            1, 0, 0, 0, -- stick max
            200, 250, 0, 0 -- stick zero
        }
        --]]
    }
    rf2.mspQueue:add(message)
end

local function setEscParameters(data)
    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        payload = {},
    }
    rf2.mspHelper.writeU8(message.payload, data.esc_signature)
    rf2.mspHelper.writeU8(message.payload, data.command)
    rf2.mspHelper.writeText(message.payload, data.esc_type_name)
    rf2.mspHelper.writeU16(message.payload, data.flight_mode.value)
    rf2.mspHelper.writeU16(message.payload, data.bec_voltage.value)
    rf2.mspHelper.writeU16(message.payload, data.rotation.value)
    rf2.mspHelper.writeU16(message.payload, data.telemetry_protocol.value)
    rf2.mspHelper.writeU16(message.payload, data.protection_delay.value)
    rf2.mspHelper.writeU16(message.payload, data.min_voltage.value)
    rf2.mspHelper.writeU16(message.payload, data.max_temp.value)
    rf2.mspHelper.writeU16(message.payload, data.max_current.value)
    rf2.mspHelper.writeU16(message.payload, data.cutoff_handling.value)
    rf2.mspHelper.writeU16(message.payload, data.max_ah_used.value)
    rf2.mspHelper.writeU16(message.payload, data.startup_sound.value)
    rf2.mspHelper.writeU32(message.payload, data.serial_number)
    rf2.mspHelper.writeU16(message.payload, data.firmware_version)
    rf2.mspHelper.writeU16(message.payload, data.start_time.value)
    rf2.mspHelper.writeU16(message.payload, data.runup_time.value)
    rf2.mspHelper.writeU16(message.payload, data.bailout.value)
    rf2.mspHelper.writeU32(message.payload, data.p_gain.value)
    rf2.mspHelper.writeU32(message.payload, data.i_gain.value)
    rf2.mspHelper.writeU32(message.payload, data.stick_max)
    rf2.mspHelper.writeU32(message.payload, data.stick_zero)
    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}