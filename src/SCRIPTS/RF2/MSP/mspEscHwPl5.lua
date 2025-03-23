local flightMode = {
    [0] = "Fixed Wing",
    "Ext Gov",
    "Governor",
    "Gov Store",
}

local lipoCellCount = {
    [0] = "Auto",
    "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "11S", "12S", "13S", "14S",
}

local cutoffType = {
    [0] = "Soft",
    "Hard"
}

local cutoffVoltage = {
    [0] = "Disabled",
    "2.8", "2.9", "3.0", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8",
}

local restartTime = {
    [0] = "1s",
    "1.5s",
    "2s",
    "2.5s",
    "3s",
}

local rotation = {
    [0] = "CW",
    "CCW",
}

local brakeType = {
    [0] = "Disabled",
    "Normal",
    "Proportional",
    "Reverse"
}

local enabledDisabled = {
    [0] = "Enabled",
    "Disabled",
}

local startupPower = {
    [0] = "Level 1",
    "Level 2",
    "Level 3",
    "Level 4",
    "Level 5",
    "Level 6",
    "Level 7",
}

local function getDefaults()
    return {
        esc_signature = {},
        command = {},
        firmware_version = {},
        hardware_version = {},
        esc_type2 = {},
        esc_type = {},
        flight_mode = { min = 0, max = #flightMode, table = flightMode },
        lipo_cell_count = { min = 0, max = #lipoCellCount, table = lipoCellCount },
        cutoff_type = { min = 0, max = #cutoffType, table = cutoffType },
        cutoff_voltage = { min = 0, max = #cutoffVoltage, table = cutoffVoltage },
        bec_voltage = { min = 54, max = 84, scale = 10 },
        startup_time = { min = 4, max = 25 },
        gov_p_gain = { min = 0, max = 9 },
        gov_i_gain = { min = 0, max = 9 },
        auto_restart = { min = 0, max= 90 },
        restart_time = { min = 0, max = #restartTime, table = restartTime },
        brake_type = { min = 0, max = #brakeType, table = brakeType },
        brake_force = { min = 0, max = 100, unit = rf2.units.percentage },
        timing = { min = 0, max = 30, unit = rf2.units.degrees },
        rotation = { min = 0, max = #rotation, table = rotation },
        active_freewheel = { min = 0, max = #enabledDisabled, table = enabledDisabled },
        startup_power = { min = 0, max = #startupPower, table = startupPower },
    }
end

local function getEscParameters(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        processReply = function(self, buf)
            data.esc_signature.value = rf2.mspHelper.readU8(buf)
            if data.esc_signature.value ~= 253 then
                rf2.print("warning: Invalid ESC signature: " .. tostring(data.esc_signature))
                return
            end
            data.command.value = rf2.mspHelper.readU8(buf)
            data.firmware_version.value = rf2.mspHelper.readText(buf, 16)
            data.hardware_version.value = rf2.mspHelper.readText(buf, 16)
            data.esc_type2.value = rf2.mspHelper.readText(buf, 16)
            data.esc_type.value = rf2.mspHelper.readText(buf, 15)
            data.flight_mode.value = rf2.mspHelper.readU8(buf)
            data.lipo_cell_count.value = rf2.mspHelper.readU8(buf)
            data.cutoff_type.value = rf2.mspHelper.readU8(buf)
            data.cutoff_voltage.value = rf2.mspHelper.readU8(buf)
            data.bec_voltage.value = rf2.mspHelper.readU8(buf) + 54
            data.startup_time.value = rf2.mspHelper.readU8(buf) + 4
            data.gov_p_gain.value = rf2.mspHelper.readU8(buf)
            data.gov_i_gain.value = rf2.mspHelper.readU8(buf)
            data.auto_restart.value = rf2.mspHelper.readU8(buf)
            data.restart_time.value = rf2.mspHelper.readU8(buf)
            data.brake_type.value = rf2.mspHelper.readU8(buf)
            data.brake_force.value = rf2.mspHelper.readU8(buf)
            data.timing.value = rf2.mspHelper.readU8(buf)
            data.rotation.value = rf2.mspHelper.readU8(buf)
            data.active_freewheel.value = rf2.mspHelper.readU8(buf)
            data.startup_power.value = rf2.mspHelper.readU8(buf)
            callback(callbackParam, data)
        end,
        simulatorResponse = { 253, 0, 32, 32, 32, 80, 76, 45, 48, 52, 46, 49, 46, 48, 50, 32, 32, 32, 72, 87, 49, 49, 48, 54, 95, 86, 49, 48, 48, 52, 53, 54, 78, 66, 80, 108, 97, 116, 105, 110, 117, 109, 95, 86, 53, 32, 32, 32, 32, 32, 80, 108, 97, 116, 105, 110, 117, 109, 32, 86, 53, 32, 32, 32, 32, 0, 0, 0, 3, 0, 11, 6, 5, 25, 1, 0, 0, 24, 0, 0, 2 },
    }
    rf2.mspQueue:add(message)
end

local function setEscParameters(data)
    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        payload = {}
    }
    rf2.mspHelper.writeU8(message.payload, data.esc_signature.value)
    rf2.mspHelper.writeU8(message.payload, data.command.value)
    rf2.mspHelper.writeText(message.payload, data.firmware_version.value, 16)
    rf2.mspHelper.writeText(message.payload, data.hardware_version.value, 16)
    rf2.mspHelper.writeText(message.payload, data.esc_type2.value, 16)
    rf2.mspHelper.writeText(message.payload, data.esc_type.value, 15)
    rf2.mspHelper.writeU8(message.payload, data.flight_mode.value)
    rf2.mspHelper.writeU8(message.payload, data.lipo_cell_count.value)
    rf2.mspHelper.writeU8(message.payload, data.cutoff_type.value)
    rf2.mspHelper.writeU8(message.payload, data.cutoff_voltage.value)
    rf2.mspHelper.writeU8(message.payload, data.bec_voltage.value - 54)
    rf2.mspHelper.writeU8(message.payload, data.startup_time.value - 4)
    rf2.mspHelper.writeU8(message.payload, data.gov_p_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.gov_i_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.auto_restart.value)
    rf2.mspHelper.writeU8(message.payload, data.restart_time.value)
    rf2.mspHelper.writeU8(message.payload, data.brake_type.value)
    rf2.mspHelper.writeU8(message.payload, data.brake_force.value)
    rf2.mspHelper.writeU8(message.payload, data.timing.value)
    rf2.mspHelper.writeU8(message.payload, data.rotation.value)
    rf2.mspHelper.writeU8(message.payload, data.active_freewheel.value)
    rf2.mspHelper.writeU8(message.payload, data.startup_power.value)
    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}

