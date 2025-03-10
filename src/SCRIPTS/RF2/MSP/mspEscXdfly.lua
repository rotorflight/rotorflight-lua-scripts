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
local autoRestart = { [0] = "OFF", "90s" }
local srFunc = { [0] = "ON", "OFF" }
local govMode = { [0] = "ESC Governor", "External Governor" , "Fixed Wing" }

local function getModelName(modelId)
    local escModels = { "RESERVED", "35A", "65A", "85A", "125A", "155A", "130A", "195A", "300A" }
    return "XDFly " .. (escModels[modelId] or "UNKNOWN")
end

local function getFirmwareVersion(version)
    if not version then return "UNKNOWN" end
    return string.format("%d.%d", bit32.rshift(version, 4), bit32.band(version, 0x0F))
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

            data.governor.value = rf2.mspHelper.readU16(buf) -- 1
            data.cell_cutoff.value = rf2.mspHelper.readU16(buf) -- 1
            data.timing.value = rf2.mspHelper.readU16(buf) -- 1
            data.lv_bec_voltage.value = rf2.mspHelper.readU16(buf) -- 0
            data.motor_direction.value = rf2.mspHelper.readU16(buf) --1
            data.gov_p.value = rf2.mspHelper.readU16(buf) -- 1
            data.gov_i.value = rf2.mspHelper.readU16(buf) -- 1
            data.acceleration.value = rf2.mspHelper.readU16(buf) -- 1
            data.auto_restart_time.value = rf2.mspHelper.readU16(buf) -- 1
            data.hv_bec_voltage.value = rf2.mspHelper.readU16(buf) -- 1
            data.startup_power.value = rf2.mspHelper.readU16(buf) -- 1
            data.brake_type.value = rf2.mspHelper.readU16(buf) -- 1
            data.brake_force.value = rf2.mspHelper.readU16(buf) -- 1
            data.sr_function.value = rf2.mspHelper.readU16(buf) -- 1
            data.capacity_correction.value = rf2.mspHelper.readU16(buf) -- 1
            data.motor_poles.value = rf2.mspHelper.readU16(buf) -- 1
            data.led_color.value = rf2.mspHelper.readU16(buf) -- 0
            data.smart_fan.value = rf2.mspHelper.readU16(buf) -- 0
            data.activefields.value = rf2.mspHelper.readU32(buf) -- 0x01FFEE: 00000001 11111111 11101110

            data.modelName = getModelName(data.esc_model.value)
            data.firmwareVersion = getFirmwareVersion(data.esc_version.value)

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
    rf2.mspHelper.writeU16(message.payload, data.gov_p.value)
    rf2.mspHelper.writeU16(message.payload, data.gov_i.value)
    rf2.mspHelper.writeU16(message.payload, data.acceleration.value)
    rf2.mspHelper.writeU16(message.payload, data.auto_restart_time.value)
    rf2.mspHelper.writeU16(message.payload, data.hv_bec_voltage.value)
    rf2.mspHelper.writeU16(message.payload, data.startup_power.value)
    rf2.mspHelper.writeU16(message.payload, data.brake_type.value)
    rf2.mspHelper.writeU16(message.payload, data.brake_force.value)
    rf2.mspHelper.writeU16(message.payload, data.sr_function.value)
    rf2.mspHelper.writeU16(message.payload, data.capacity_correction.value)
    rf2.mspHelper.writeU16(message.payload, data.motor_poles.value)
    rf2.mspHelper.writeU16(message.payload, data.led_color.value)
    rf2.mspHelper.writeU16(message.payload, data.smart_fan.value)
    rf2.mspHelper.writeU32(message.payload, data.activefields.value)
    rf2.mspQueue:add(message)
end

local function getDefaults()
    local defaults = {
        esc_signature = { value = nil },
        esc_command = { value = nil },
        esc_model = { value = nil },
        esc_version = { value = nil },
        governor = { value = nil, table = govMode, max = #govMode },
        cell_cutoff = { value = nil, table = lowVoltage, max = #lowVoltage },
        timing = { value = nil, table = timing, max = #timing },
        lv_bec_voltage = { value = nil, table = becLvVoltage, max = #becLvVoltage },
        motor_direction = { value = nil, table = motorDirection, max = #motorDirection },
        gov_p = { value = nil, min = 1, max = 10 },
        gov_i = { value = nil, min = 1, max = 10 },
        acceleration = { value = nil, table = accel, max = #accel },
        auto_restart_time = { value = nil, table = autoRestart, max = #autoRestart },
        hv_bec_voltage = { value = nil, table = becHvVoltage, max = #becHvVoltage },
        startup_power = { value = nil, table = startupPower, max = #startupPower },
        brake_type = { value = nil, table = brakeType, max = #brakeType },
        brake_force = { value = nil, min = 0, max = 100 },
        sr_function = { value = nil, table = srFunc, max = #srFunc },
        capacity_correction = { value = nil, min = 0, max = 20 }, -- todo: -10..+10
        motor_poles = { value = nil, min = 1, max = 30 },
        led_color = { value = nil, table = ledColor, max = #ledColor },
        smart_fan = { value = nil, table = fanControl, max = #fanControl },
        activefields = { value = nil  }
    }
    return defaults
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}