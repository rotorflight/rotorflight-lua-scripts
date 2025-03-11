local motorDirection = { [0] = "CW", "CCW" }
local becLvVoltage = { [0] = "6.0V", "7.4V", "8.4V" }
local startupPower = { [0] = "Low", "Medium", "High" }
local fanControl = { [0] = "On", "Off" }
local ledColor = { [0] = "RED", "YELLOW", "ORANGE", "GREEN", "JADE GREEN", "BLUE", "CYAN", "PURPLE", "PINK", "WHITE" }
local becHvVoltage = { [0] = "6.0V", "6.2V", "6.4V", "6.6V", "6.8V", "7.0V", "7.2V", "7.4V", "7.6V", "7.8V", "8.0V", "8.2V", "8.4V", "8.6V", "8.8V", "9.0V", "9.2V", "9.4V", "9.6V", "9.8V", "10.0V", "10.2V", "10.4V", "10.6V", "10.8V", "11.0V", "11.2V", "11.4V", "11.6V", "11.8V", "12.0V" }
local lowVoltage = { [0] = "OFF", "2.7V", "3.0V", "3.2V", "3.4V", "3.6V", "3.8V" }
local timing = { [0] = "Auto", "Low", "Medium", "High" }
local accel = { [0] = "Fast", "Normal", "Slow", "Very Slow" }
local brakeType = { [0] = "Normal", "Reverse" }
local autoRestart = { [0] = "Off", "90s" }
local srFunc = { [0] = "On", "Off" }
local govMode = { [0] = "ESC Governor", "External Governor" , "Fixed Wing" }

local function getModelName(modelId)
    local escModels = { "RESERVED", "35A", "65A", "85A", "125A", "155A", "130A", "195A", "300A" }
    return "XDFly " .. (escModels[modelId] or "UNKNOWN")
end

local function getFirmwareVersion(version)
    if not version then return "UNKNOWN" end
    return string.format("Firmware: %d.%d", bit32.rshift(version, 4), bit32.band(version, 0x0F))
end

local function getEscParameters(data, callback, callbackParam)
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        processReply = function(self, buf)
            --rf2.print("buf length: "..#buf)
            local signature = rf2.mspHelper.readU8(buf)
            if signature ~= 166 then
                rf2.print("warning: Invalid ESC signature: " .. signature)
                return
            end
            data.esc_signature.value = signature
            data.esc_command.value = rf2.mspHelper.readU8(buf)
            data.esc_version.value = rf2.mspHelper.readU8(buf)
            data.esc_model.value = rf2.mspHelper.readU8(buf)
            data.governor.value = rf2.mspHelper.readU16(buf)
            data.cell_cutoff.value = rf2.mspHelper.readU16(buf)
            data.timing.value = rf2.mspHelper.readU16(buf)
            data.lv_bec_voltage.value = rf2.mspHelper.readU16(buf)
            data.motor_direction.value = rf2.mspHelper.readU16(buf)
            data.gov_p.value = rf2.mspHelper.readU16(buf) + 1
            data.gov_i.value = rf2.mspHelper.readU16(buf) + 1
            data.acceleration.value = rf2.mspHelper.readU16(buf)
            data.auto_restart_time.value = rf2.mspHelper.readU16(buf)
            data.hv_bec_voltage.value = rf2.mspHelper.readU16(buf)
            data.startup_power.value = rf2.mspHelper.readU16(buf)
            data.brake_type.value = rf2.mspHelper.readU16(buf)
            data.brake_force.value = rf2.mspHelper.readU16(buf)
            data.sr_function.value = rf2.mspHelper.readU16(buf)
            data.capacity_correction.value = rf2.mspHelper.readU16(buf) - 10
            data.pole_pairs.value = rf2.mspHelper.readU16(buf) + 1
            data.led_color.value = rf2.mspHelper.readU16(buf)
            data.smart_fan.value = rf2.mspHelper.readU16(buf)
            data.active_fields.value = rf2.mspHelper.readU32(buf)

            -- Derived fields
            data.modelName = getModelName(data.esc_model.value)
            data.firmwareVersion = getFirmwareVersion(data.esc_version.value)

            -- Set hidden flag if the corresponding activeFields bit is 0
            local activeFields = data.active_fields.value
            data.governor.hidden = bit32.rshift(activeFields, 1) % 2 == 0
            data.cell_cutoff.hidden = bit32.rshift(activeFields, 2) % 2 == 0
            data.timing.hidden = bit32.rshift(activeFields, 3) % 2 == 0
            data.lv_bec_voltage.hidden = bit32.rshift(activeFields, 4) % 2 == 0
            data.motor_direction.hidden = bit32.rshift(activeFields, 5) % 2 == 0
            data.gov_p.hidden = bit32.rshift(activeFields, 6) % 2 == 0
            data.gov_i.hidden = bit32.rshift(activeFields, 7) % 2 == 0
            data.acceleration.hidden = bit32.rshift(activeFields, 8) % 2 == 0
            data.auto_restart_time.hidden = bit32.rshift(activeFields, 9) % 2 == 0
            data.hv_bec_voltage.hidden = bit32.rshift(activeFields, 10) % 2 == 0
            data.startup_power.hidden = bit32.rshift(activeFields, 11) % 2 == 0
            data.brake_type.hidden = bit32.rshift(activeFields, 12) % 2 == 0
            data.brake_force.hidden = bit32.rshift(activeFields, 13) % 2 == 0
            data.sr_function.hidden = bit32.rshift(activeFields, 14) % 2 == 0
            data.capacity_correction.hidden = bit32.rshift(activeFields, 15) % 2 == 0
            data.pole_pairs.hidden = bit32.rshift(activeFields, 16) % 2 == 0
            data.led_color.hidden = bit32.rshift(activeFields, 17) % 2 == 0
            data.smart_fan.hidden = bit32.rshift(activeFields, 18) % 2 == 0

            callback(callbackParam)
        end,
        simulatorResponse = { 166, 0, 23, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 4, 0, 3, 0, 2, 0, 1, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 0, 1, 0, 0, 0, 0, 0, 0xEE, 0xFF, 1, 0 }
    }
    rf2.mspQueue:add(message)
end

local function setEscParameters(data)
    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        payload = {},
        postSendDelay = 2, -- A delay is needed since  MSP_SET_ESC_PARAMETERS gets processed asynchronously
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, data.esc_signature.value)
    rf2.mspHelper.writeU8(message.payload, data.esc_command.value)
    rf2.mspHelper.writeU8(message.payload, data.esc_version.value)
    rf2.mspHelper.writeU8(message.payload, data.esc_model.value)
    rf2.mspHelper.writeU16(message.payload, data.governor.value)
    rf2.mspHelper.writeU16(message.payload, data.cell_cutoff.value)
    rf2.mspHelper.writeU16(message.payload, data.timing.value)
    rf2.mspHelper.writeU16(message.payload, data.lv_bec_voltage.value)
    rf2.mspHelper.writeU16(message.payload, data.motor_direction.value)
    rf2.mspHelper.writeU16(message.payload, data.gov_p.value - 1)
    rf2.mspHelper.writeU16(message.payload, data.gov_i.value - 1)
    rf2.mspHelper.writeU16(message.payload, data.acceleration.value)
    rf2.mspHelper.writeU16(message.payload, data.auto_restart_time.value)
    rf2.mspHelper.writeU16(message.payload, data.hv_bec_voltage.value)
    rf2.mspHelper.writeU16(message.payload, data.startup_power.value)
    rf2.mspHelper.writeU16(message.payload, data.brake_type.value)
    rf2.mspHelper.writeU16(message.payload, data.brake_force.value)
    rf2.mspHelper.writeU16(message.payload, data.sr_function.value)
    rf2.mspHelper.writeU16(message.payload, data.capacity_correction.value + 10)
    rf2.mspHelper.writeU16(message.payload, data.pole_pairs.value - 1)
    rf2.mspHelper.writeU16(message.payload, data.led_color.value)
    rf2.mspHelper.writeU16(message.payload, data.smart_fan.value)
    rf2.mspHelper.writeU32(message.payload, data.active_fields.value)
    rf2.mspQueue:add(message)
end

local function getDefaults()
    local defaults = {
        esc_signature = { },
        esc_command = { },
        esc_model = { },
        esc_version = { },
        governor = { table = govMode, max = #govMode },
        cell_cutoff = { table = lowVoltage, max = #lowVoltage },
        timing = { table = timing, max = #timing },
        lv_bec_voltage = { table = becLvVoltage, max = #becLvVoltage },
        motor_direction = { table = motorDirection, max = #motorDirection },
        gov_p = { min = 1, max = 10 },
        gov_i = { min = 1, max = 10 },
        acceleration = { table = accel, max = #accel },
        auto_restart_time = { table = autoRestart, max = #autoRestart },
        hv_bec_voltage = { table = becHvVoltage, max = #becHvVoltage },
        startup_power = { table = startupPower, max = #startupPower },
        brake_type = { table = brakeType, max = #brakeType },
        brake_force = { min = 0, max = 100 },
        sr_function = { table = srFunc, max = #srFunc },
        capacity_correction = { min = -10, max = 10 },
        pole_pairs = { min = 1, max = 30 },
        led_color = { table = ledColor, max = #ledColor },
        smart_fan = { table = fanControl, max = #fanControl },
        active_fields = {  }
    }
    return defaults
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}