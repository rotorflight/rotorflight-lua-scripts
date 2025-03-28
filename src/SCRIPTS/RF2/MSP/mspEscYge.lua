local escFlags = {
    spinDirection = 0,
    f3cAuto = 1,
    keepMah = 2,
    bec12v = 3,
}

local escMode = {
    [0] = "Free (Attention!)",
    "Heli Ext Governor",
    "Heli Governor",
    "Heli GovStore",
    "Aero Glider",
    "Aero Motor",
    "Aero F3A"
}

local direction = {
    [0] = "Normal",
    "Reverse"
}

local cuttoff = {
    [0] = "Off",
    "Slow Down",
    "Cutoff"
}

local cuttoffVoltage = {
    [0] = "2.9V",
    "3.0V",
    "3.1V",
    "3.2V",
    "3.3V",
    "3.4V",
}

local offOn = {
    [0] = "Off",
    "On"
}

local startupResponse = {
    [0] = "Normal",
    "Smooth"
}

local throttleResponse = {
    [0] = "Slow",
    "Medium",
    "Fast",
    "Custom (PC defined)"
}

local motorTiming = {
    [0] = "Auto Normal",
    "Auto Efficient",
    "Auto Power",
    "Auto Extreme",
    "0 deg",
    "6 deg",
    "12 deg",
    "18 deg",
    "24 deg",
    "30 deg",
}

local freewheel = {
    [0] = "Off",
    "Auto",
    "*unused*",
    "Always On",
}

local function getDefaults()
    local defaults = {
        esc_signature = nil,
        command = nil,
        unknown1 = nil,
        esc_mode = { min = 0, max = #escMode, table = escMode },
        bec_voltage = { min = 55, max = 84, scale = 10},
        motor_timing = { min = 0, max = #motorTiming, table = motorTiming },
        startup_response = { min = 0, max = #startupResponse, table = startupResponse },
        p_gain = { min = 1, max = 10 },
        i_gain = { min = 1, max = 10 },
        throttle_response = { min = 0, max = #throttleResponse, table = throttleResponse },
        cutoff_handling = { min = 0, max = #cuttoff, table = cuttoff },
        cutoff_cell_voltage = { min = 0, max = #cuttoffVoltage, table = cuttoffVoltage },
        active_freewheel = { min = 0, max = #freewheel, table = freewheel },
        esc_type = nil,
        firmware_version = nil,
        serial_number = nil,
        unknown2 = nil,
        stick_zero = { min = 900, max = 1900 },
        stick_range = { min = 600, max = 1500 },
        unknown3 = nil,
        motor_pole_pairs = { min = 1, max = 100 },
        pinion_teeth = { min = 1, max = 255 },
        main_teeth = { min = 0, max = 1800 },
        min_start_power = { min = 0, max = 26, unit = rf2.units.percentage },
        max_start_power = { min = 0, max = 31, unit = rf2.units.percentage },
        unknown4 = nil,
        flags = nil,
        unknown5 = nil,
        current_limit = { min = 1, max = 65500, scale = 100, mult = 100 },
        unknown6 = nil,
        unknown7 = nil,
        -- derived fields
        escTypeName = nil,
        direction = { min = 0, max = #direction, table = direction },
        f3c_autorotation = { min = 0, max = #offOn, table = offOn },
    }

    return defaults
end

local function mapMotorTimingToUI(value)
    local motorTimingToUI = {
        [0] = 0,
        4,
        5,
        6,
        7,
        8,
        9,
        [16] = 0,
        [17] = 1,
        [18] = 2,
        [19] = 3,
    }
    return motorTimingToUI[value] or 0
end

local function getEscTypeName(value)
    local escTypes = {
        [848]  = "YGE 35 LVT BEC",
        [1616] = "YGE 65 LVT BEC",
        [2128] = "YGE 85 LVT BEC",
        [2384] = "YGE 95 LVT BEC",
        [4944] = "YGE 135 LVT BEC",
        [2304] = "YGE 90 HVT Opto",
        [4608] = "YGE 120 HVT Opto",
        [5712] = "YGE 165 HVT",
        [8272] = "YGE 205 HVT",
        [8273] = "YGE 205 HVT BEC",
        [4177] = "YGE Aureus 105",
        [4179] = "YGE Aureus 105v2",
        [5025] = "YGE Aureus 135",
        [5027] = "YGE Aureus 135v2",
        [5457] = "YGE Saphir 155",
        [5459] = "YGE Saphir 155v2",
        [4689] = "YGE Saphir 125",
        [4928] = "YGE Opto 135",
        [9552] = "YGE Opto 255",
        [16464]= "YGE Opto 405",
    }

    return escTypes[value] or "YGE ESC (" .. value .. ")"
end

local function getEscParameters(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        processReply = function(self, buf)
            local signature = rf2.mspHelper.readU8(buf)
            if signature ~= 165 then
                --rf2.print("warning: Invalid ESC signature: " .. signature)
                return
            end
            data.esc_signature = signature
            data.command = rf2.mspHelper.readU8(buf)
            data.unknown1 = rf2.mspHelper.readU16(buf)
            data.esc_mode.value = rf2.mspHelper.readU16(buf)
            data.bec_voltage.value = rf2.mspHelper.readU16(buf)
            data.motor_timing.value = mapMotorTimingToUI(rf2.mspHelper.readU16(buf))
            data.startup_response.value = rf2.mspHelper.readU16(buf)
            data.p_gain.value = rf2.mspHelper.readU16(buf)
            data.i_gain.value = rf2.mspHelper.readU16(buf)
            data.throttle_response.value = rf2.mspHelper.readU16(buf)
            data.cutoff_handling.value = rf2.mspHelper.readU16(buf)
            data.cutoff_cell_voltage.value = rf2.mspHelper.readU16(buf)
            data.active_freewheel.value = rf2.mspHelper.readU16(buf)
            data.esc_type = rf2.mspHelper.readU16(buf)
            data.firmware_version = rf2.mspHelper.readU32(buf)
            data.serial_number = rf2.mspHelper.readU32(buf)
            data.unknown2 = rf2.mspHelper.readU16(buf)
            data.stick_zero.value = rf2.mspHelper.readU16(buf)
            data.stick_range.value = rf2.mspHelper.readU16(buf)
            data.unknown3 = rf2.mspHelper.readU16(buf)
            data.motor_pole_pairs.value = rf2.mspHelper.readU16(buf)
            data.pinion_teeth.value = rf2.mspHelper.readU16(buf)
            data.main_teeth.value = rf2.mspHelper.readU16(buf)
            data.min_start_power.value = rf2.mspHelper.readU16(buf)
            data.max_start_power.value = rf2.mspHelper.readU16(buf)
            data.unknown4 = rf2.mspHelper.readU16(buf)
            data.flags = rf2.mspHelper.readU8(buf)
            data.unknown5 = rf2.mspHelper.readU8(buf)
            data.current_limit.value = rf2.mspHelper.readU16(buf)
            data.unknown6 = rf2.mspHelper.readU32(buf)
            data.unknown7 = rf2.mspHelper.readU32(buf)

            -- derived fields
            data.escTypeName = getEscTypeName(data.esc_type)
            data.direction.value = bit32.extract(data.flags, escFlags.spinDirection)
            data.f3c_autorotation.value = bit32.extract(data.flags, escFlags.f3cAuto)
            data.bec_voltage.max = bit32.extract(data.flags, escFlags.bec12v) == 0 and 84 or 123

            callback(callbackParam, data)
        end,
        simulatorResponse = { 165, 0, 32, 0, 3, 0, 55, 0, 0, 0, 0, 0, 4, 0, 3, 0, 1, 0, 1, 0, 2, 0, 3, 0, 80, 3, 131, 148, 1, 0, 30, 170, 0, 0, 3, 0, 86, 4, 22, 3, 163, 15, 1, 0, 2, 0, 2, 0, 20, 0, 20, 0, 0, 0, 0, 0, 2, 19, 2, 0, 20, 0, 22, 0, 0, 0 },
        --[[
        simulatorResponse = {
            165,    -- esc signature
            0,      -- command
            32, 0,
            3, 0,   -- esc mode
            55, 0,  -- bec
            0, 0,   -- motor timing
            0, 0,   -- startup response
            4, 0,   -- p-gain
            3, 0,   -- i-gain
            1, 0,   -- throttle response
            1, 0,   -- cutoff handling
            2, 0,   -- cutoff cell voltage
            3, 0,   -- active freewheel
            80, 3,  -- type
            131, 148, 1, 0, -- firmware version
            30, 170, 0, 0,  -- serial number
            3, 0,
            86, 4,  -- stick zero
            22, 3,  -- stick range
            163, 15,
            1, 0,   -- motor pole pairs
            2, 0,   -- pinion teeth
            2, 0,   -- main teeth
            20, 0,  -- min start power
            20, 0,  -- max start power
            0, 0,
            0,      -- esc_flags
            0,
            2, 19,  -- current limit
            2, 0, 20, 0, 22, 0, 0, 0
        },
        --]]
    }
    rf2.mspQueue:add(message)
end

local function mapMotorTimingFromUI(value)
    local motorTimingFromUI = {
        [0] = 0,
        17,
        18,
        19,
        1,
        2,
        3,
        4,
        5,
        6,
    }
    return motorTimingFromUI[value] or 0
end

local function setEscParameters(data)
    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        payload = {},
    }

    -- Update flags
    data.flags = bit32.replace(data.flags, data.direction.value, escFlags.spinDirection)
    data.flags = bit32.replace(data.flags, data.f3c_autorotation.value, escFlags.f3cAuto)

    rf2.mspHelper.writeU8(message.payload, data.esc_signature)
    rf2.mspHelper.writeU8(message.payload, data.command)
    rf2.mspHelper.writeU16(message.payload, data.unknown1)
    rf2.mspHelper.writeU16(message.payload, data.esc_mode.value)
    rf2.mspHelper.writeU16(message.payload, data.bec_voltage.value)
    rf2.mspHelper.writeU16(message.payload, mapMotorTimingFromUI(data.motor_timing.value))
    rf2.mspHelper.writeU16(message.payload, data.startup_response.value)
    rf2.mspHelper.writeU16(message.payload, data.p_gain.value)
    rf2.mspHelper.writeU16(message.payload, data.i_gain.value)
    rf2.mspHelper.writeU16(message.payload, data.throttle_response.value)
    rf2.mspHelper.writeU16(message.payload, data.cutoff_handling.value)
    rf2.mspHelper.writeU16(message.payload, data.cutoff_cell_voltage.value)
    rf2.mspHelper.writeU16(message.payload, data.active_freewheel.value)
    rf2.mspHelper.writeU16(message.payload, data.esc_type)
    rf2.mspHelper.writeU32(message.payload, data.firmware_version)
    rf2.mspHelper.writeU32(message.payload, data.serial_number)
    rf2.mspHelper.writeU16(message.payload, data.unknown2)
    rf2.mspHelper.writeU16(message.payload, data.stick_zero.value)
    rf2.mspHelper.writeU16(message.payload, data.stick_range.value)
    rf2.mspHelper.writeU16(message.payload, data.unknown3)
    rf2.mspHelper.writeU16(message.payload, data.motor_pole_pairs.value)
    rf2.mspHelper.writeU16(message.payload, data.pinion_teeth.value)
    rf2.mspHelper.writeU16(message.payload, data.main_teeth.value)
    rf2.mspHelper.writeU16(message.payload, data.min_start_power.value)
    rf2.mspHelper.writeU16(message.payload, data.max_start_power.value)
    rf2.mspHelper.writeU16(message.payload, data.unknown4)
    rf2.mspHelper.writeU8(message.payload, data.flags)
    rf2.mspHelper.writeU8(message.payload, data.unknown5)
    rf2.mspHelper.writeU16(message.payload, data.current_limit.value)
    rf2.mspHelper.writeU32(message.payload, data.unknown6)
    rf2.mspHelper.writeU32(message.payload, data.unknown7)

    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}